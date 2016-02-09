
# My re-usable variables
my.colors = c('orange','yellow','blue','red','green','brown','cyan','purple','black')
println = function(){
    paste(rep('-',218),collapse='')
}

# Import the fuel data
fueldata = read.csv("fueldata.csv")

"Initial Features"
# Show first 12 records to have a look at the data
head(fueldata,12)
# View summary statistics to get an overview of the data
"Summary Statistics"
println()
summary(fueldata)

"A closer look at the variety of transmision systems"
k=as.data.frame(t(t(table(fueldata$TRANS))))
k$Var2=NULL
names(k) <- c('Transmission','Frequency')
k
#summary(k)
barplot(k$Frequency,main="Frequency of Transmission Systems",
                    col=rainbow(length(k$Transmission)),names.arg=rep('',length(k$Transmission)))

axis(1, at=seq(1, length(k$Transmission), by=1)*1.18, labels = FALSE)
text(seq(1, length(k$Transmission), by=1)*1.18,-10 , labels = k$Transmission, srt = 35, pos = 1, xpd = TRUE)


# Split Original Transmission Column into additional features (Type,IsCVT, No of Gears)
fuelTransmissions=apply(as.matrix(fueldata$TRAN),1,function(mx){
    li = (strsplit(mx,split="")[[1]])
    if(length(li)==1){ # Cases where transmission is only automatic/manual
        li = c(li,'','')
    }else
    if(length(li)==2){ # cases where only transmission and no. of grears is specified
        if(grepl('[0-9]',paste(li,collapse=''))){
            li = c(li[1],'',li[2])
        }else{
            li = c(li,'')
        }
        
    }
    return (li)
})
fuelTransmissions=as.data.frame(t(fuelTransmissions))


#CVT - http://cars.about.com/od/thingsyouneedtoknow/a/CVT.htm
transmission_labels = c('Transmission_Type','CVT','Gears')
names(fuelTransmissions) <- transmission_labels
"First 5 Transmissions"
head(fuelTransmissions)
"Summary Statistics for Transmissions"
summary(fuelTransmissions)
"Distribution of Transmissions across groups"
par(mfrow=c(1,3))
for(label in transmission_labels){
    barplot(table(fuelTransmissions[label]), 
         main=paste('Distribution of',label),
         xlab=label,
         col=my.colors)
}

# adding new transmissions data
#create copy
fueldata2 = fueldata
for(label in transmission_labels){
    fueldata2[label]=fuelTransmissions[label]
}
"Merged With Transmission Data"
head(fueldata2)

#Look at distribution of cars over unique class combos
cls.freq = table(fueldata$CLASS)


lablist=names(cls.freq)
barplot(cls.freq,names.arg=rep('',length(lablist)),
        horiz=T,
        col=rainbow(length(lablist)),
        xlim=c(-50,160),
        main="Distribution of cars across class combinations",xlab="Frequency",ylab="Class")
par(las=2)
#axis(2, at=seq(1, length(lablist)*2, by=1), labels = FALSE)
text(2,seq(1, length(lablist), by=1)*1.15,offset=0.6 , labels = lablist, srt = 24, pos = 2, xpd = T)


uniqueClassCombos = unique(fueldata$CLASS)
paste("Unique Combination of Classes (",length(uniqueClassCombos),")",collapse='')
uniqueClassCombos

summary(fueldata$CLASS)

# getting unique classes then recode into binary data
#classes = paste(fueldata$CLASS,collapse=' ')
k=gsub("-", "", fueldata$CLASS)
k = gsub("  ", " ", k)
k=paste(k,collapse=' ')
uniqueClasses=unique(strsplit(k,' ')[[1]])
"Unique Classes"
paste("Unique Classes (",length(uniqueClasses),")",collapse='')
uniqueClasses
#NB TOFO: replace FULLSIZE with FULL-SIZE before doing queries

#Recording Data and adding to fueldata
# Determines if a VECTOR value contains the value in subClass
containsSubClass = function(value, subClass="CLASS"){
    return (grepl(subClass,value))
}
for(unClass in uniqueClasses){
    cleanTemp = gsub("-", "", fueldata2$CLASS)
    cleanTemp = gsub("  ", " ", cleanTemp)
    fueldata2[sprintf('is%s',unClass)]= apply(as.matrix(cleanTemp),1,FUN=containsSubClass,subClass=unClass)
}
"Data with Recoded Values"
head(fueldata2)

# Taking a closer look at fuel consumption per year to detemine suitable classes
"Summary Statistics for Fuel Data"
summary(fueldata$FUEL_L_YR)
plot(fueldata$FUEL_L_YR,main="Fuel Consumption Per Year For Each Car",
                        xlab="Car",
                        ylab="Fuel Consumption",col=c('blue'))
# Question, was the driver and their lifestyle an impact on the fuel consumption of the recorded car? 
# Based on the data, we cannot answer the above
 

print("Using the Distribution of Data to identify possible classes for features")
for(feature in c('FUEL_L_YR','CITY_L','HWY_L','CITY_MI','HWY_MI','CO2')){
    title = paste("Distribution of ",feature)
    par(mfrow=c(2,1))
    hist(fueldata[,feature],freq=F,main=title,xlab=feature)
    plot(density(fueldata[,feature]),main=paste('Density Curve for',feature),xlab=feature)
}

# Based on the density distribution, Possible classes include
#-  0-1000 --> 1
#-  1000-1500 --> 2
#-  1500-2000 --> 3
#-  2000-2500 --> 4
#-  2500-3000 --> 5
#-  3000-4000 --> 6
#-  4000-5000 --> 7
# Will create factors based on ranges
group_bounds = c(
    0, #1
    999, # 2
    1499, #3
    1999, #4
    2499, #5
    2999, #6
    3999 #7
    ,5000 #7
)

classification=cut(fueldata2$FUEL_L_YR,labels=F,breaks=group_bounds)
sprintf("No of groups attained: %s",length(unique(classification)))
"Labels for groups attained"
unique(classification)
# create copy of fueldata and add groups
fueldata3 = fueldata2
fueldata3$consume = classification

paste("Classification and Observations are equal? ",length(classification) == length(fueldata$FUEL_L_YR) )
hist(fueldata3$consume,col=c('blue'),main="Distribution of Cars based on consumption",
                       xlab="Consumption Class",
                       ylab="Frequency")

# Include rpart library
library(rpart)

# Let's describe the data a bit more to help R
factorColumns = c('YR','BRAND','MODEL','CLASS','ENG','CYLINDERS','TRANS','FUEL','CITY_L','HWY_L','CITY_MI','HWY_MI','FUEL_L_YR','CO2' )
# Remove spaces and hyphens in CLASS
fueldata4 = fueldata3
fueldata4$CLASS=gsub(" ","",gsub("-", "", fueldata3$CLASS))
#cdata[,factorColumns] = lapply(cdata[,factorColumns] , factor)

head(fueldata4)


allfeatures=names(fueldata4)
"All features that may be considered"
allfeatures

#fueldata4[,-match(c('YR','consume'),allfeatures)]
#fueldata4[,!allfeatures %in% c('YR','consume')]

#Implementing K-Fold Validation

number_of_observations = nrow(fueldata4) # number of observations
no_of_folds = 10 # To Perform 10-fold validation
block_size = number_of_observations%/%no_of_folds
set.seed(23) #ensure the following steps will remain consistent
random_keys = runif(number_of_observations) # random value column 
ranks = rank(random_keys)
block = (ranks -1)%/%block_size + 1
#block
block=as.factor(block)
plot(block,main=sprintf("Distribution of %d-folds of size (%d)",no_of_folds,block_size),
        xlab="Groups",ylab="Group Count")
#summary(block)


#Testing implemented K-Fold Validation
all.err = numeric(0)
for(k in 1:no_of_folds){

    train_data = fueldata4[block != k,]
    #print(paste("Training Data size : ",nrow(train_data)))
    test_data = fueldata4[block == k,]
    #print(paste('Test Data size : ',nrow(test_data)))
    model = rpart("consume ~ ENG+CLASS+FUEL+CYLINDERS",data=train_data,method="class")
    #plotcp(model)
    pred = predict(model,newdata=test_data,type="class")
    mc = table(test_data$consume,pred)
    print(paste("Confusion Matrix for Fold ",k))
    print(mc)
    #print(paste("% Correct for fold",k," : ",sum(test_data$consume == pred)))
    err = 1.0 - sum(test_data$consume == pred)/sum(mc)
    
    all.err = rbind(all.err,err)
}
data.frame(error_in_group=all.err)
"Average Error in Model"
mean(all.err)

possible_models = c(
    #'consume ~ BRAND + MODEL + CLASS + ENG + CYLINDERS + FUEL + Transmission_Type + CVT + Gears + CO2',
    'consume ~ ENG+CLASS+FUEL+CYLINDERS + Transmission_Type + CVT + Gears',
    'consume ~ ENG+CLASS+FUEL+CYLINDERS',
    'consume ~ CITY_L + HWY_L + CITY_MI + HWY_MI + CO2'
    #,'consume ~ BRAND + MODEL + CLASS + ENG + CYLINDERS + FUEL + Transmission_Type + CVT + Gears + CO2 + CITY_L + HWY_L + CITY_MI + HWY_MI'
)

possible_models_per_class = c(
    'consume ~ ENG+FUEL+CYLINDERS + Transmission_Type + CVT + Gears',
    'consume ~ ENG+FUEL+CYLINDERS',
    'consume ~ CITY_L + HWY_L + CITY_MI + HWY_MI + CO2'
)

head(fueldata4[,1:17])


get_mean_error_using_k_fold=function (df,modelfunc="consume ~ ENG+CLASS+FUEL+CYLINDERS",no_of_folds = 10,
                                     rand_seed=23,
                                     plot_group_distribution=F,
                                     plot_models=F,
                                     show_confusion_matrices=F,
                                     show_error_per_groups=F,
                                     show_average_error=F,
                                     min_split=100)
{
    number_of_observations = nrow(df) # number of observations
    
    block_size = number_of_observations%/%no_of_folds
    set.seed(rand_seed) #ensure the following steps will remain consistent
    random_keys = runif(number_of_observations) # random value column 
    ranks = rank(random_keys)
    block = (ranks -1)%/%block_size + 1
    #block
    block=as.factor(block)
    
    if(plot_group_distribution ==T){
        plot(block,main=sprintf("Distribution of %d-folds of size (%d)",no_of_folds,block_size),
             xlab="Groups",ylab="Group Count")
    }
    
    all.err = numeric(0)
    for(k in 1:no_of_folds){
        
        train_data = fueldata4[block != k,]
        #print(paste("Training Data size : ",nrow(train_data)))
        test_data = fueldata4[block == k,]
        #print(paste('Test Data size : ',nrow(test_data)))
        model = rpart(modelfunc,data=train_data,method="class",control=rpart.control(minsplit=min_split))
        if(plot_models == T){
            plotcp(model)
        }
        pred = predict(model,newdata=test_data,type="class")
        mc = table(test_data$consume,pred)
        if(show_confusion_matrices == T){
            print(paste("Confusion Matrix for Fold ",k))
            print(mc)
        }
        #print(paste("% Correct for fold",k," : ",sum(test_data$consume == pred)))
        err = 1.0 - sum(test_data$consume == pred)/sum(mc)
        
        all.err = rbind(all.err,err)
    }
    if(show_error_per_groups == T){
        data.frame(error_in_group=all.err)
    }
    mean_err=mean(all.err)
    if(show_average_error == T){
        print(paste("Average Error in Model '",modelfunc,"' = ",mean_err))
    }
    return (mean_err)
}

# NO longer in use, rpart performs cross validation
model_errors = c()
for(possible_model in possible_models){
    break 
    model_errors=c(
                   model_errors,
                   get_mean_error_using_k_fold(fueldata4,modelfunc=possible_model,
                                                plot_group_distribution=T,
                                     plot_models=T,
                                     show_confusion_matrices=T,
                                     show_error_per_groups=T,
                                     show_average_error=T))
}
#"Error in Each Model"
#data.frame(Error=model_errors,Model=possible_models)

library(sqldf)

model_errors = c()
vars_used  = c()
fueldata5 = fueldata4
no_of_observations = nrow(fueldata4)
fueldata5$recordId = seq(1,no_of_observations)
percent_split=0.8
train_data = fueldata5[sample(1:no_of_observations,size = as.integer(percent_split * no_of_observations)),]
query= sprintf("select * from fueldata5 where recordId not in (%s)",paste(train_data$recordId,collapse=','))

test_data = sqldf(query)
print(paste('No of Test : ',nrow(test_data),' | No in Train : ',nrow(train_data),' | % Split :',
            (percent_split*100),'%'))
println()
for(possible_model in possible_models){
        print(paste('Model : ',possible_model))
        
        model = rpart(possible_model,data=train_data,method="class",
                      control=rpart.control(
                          minsplit=100,
                          minbucket=100,
                          xval=10 #10 Fold Validation
                      ))
        vars_used = c(vars_used,paste(unique(model$frame$var),collapse=',')) #collects vars used in model in important order
        plotcp(model,main="",sub=possible_model)
        box("outer")
        printcp(model)
        plot(model, uniform=TRUE)
        title(main=sprintf("Classification Tree "),sub=possible_model)
        text(model, use.n=TRUE, all=TRUE, cex=.8)
        box("outer")
        println()

        pred = predict(model,newdata=test_data,type="class")
        mc = table(test_data$consume,pred)

        println()
        print(paste("Confusion Matrix for ",possible_model))
        print(mc)

        err = 1.0 - sum(test_data$consume == pred)/sum(mc)
        print(paste('Error in model "',possible_model,'":',err))
        println()
        model_errors=c(model_errors, err)   
}


"Error in Each Model"
data.frame(Error=model_errors,Model=possible_models,Critical_Features=vars_used)


#Based on the critical features identified in the above models a better model overall may be
"<center><h3>Composite Model</h3></center>"
possible_model='consume ~ ENG + CLASS + CITY_L + CO2'
        print(paste('Model : ',possible_model))
        
        model = rpart(possible_model,data=train_data,method="class",
                      control=rpart.control(
                          minsplit=50,
                         # minbucket=100,
                          xval=10 #10 Fold Validation
                      ))
        vars_used = c(vars_used,paste(unique(model$frame$var),collapse=',')) #collects vars used in model in important order
        plotcp(model,main="",sub=possible_model)
        box("outer")
        printcp(model)
        plot(model, uniform=TRUE)
        title(main=sprintf("Classification Tree "),sub=possible_model)
        text(model, use.n=TRUE, all=TRUE, cex=.8)
        box("outer")
        println()

        pred = predict(model,newdata=test_data,type="class")
        mc = table(test_data$consume,pred)

        println()
        print(paste("Confusion Matrix for ",possible_model))
        print(mc)

        err = 1.0 - sum(test_data$consume == pred)/sum(mc)
        print(paste('Error in model "',possible_model,'":',err))
        println()
        model_errors=c(model_errors, err)

model_errors = c()


println()
for(fuelgroup in unique(fueldata5$CLASS)){
    fuelgroupdata = subset(fueldata5,CLASS==fuelgroup)
    #sqldf(sprintf("select * from fueldata5 where CLASS='%s'",fuelgroup))
    fuelgroupsize = nrow(fuelgroupdata)
    print(paste('Possible Models for ',fuelgroup,' - ',fuelgroupsize,' observation(s)'))
   
    if(fuelgroupsize == 0){
        
        break
    }
    
    for(possible_model in possible_models_per_class){
        print(paste('Model : ',possible_model))
        
        model = rpart(possible_model,data=fuelgroupdata,method="class",
                      control=rpart.control(
                          #minsplit=0.1*fuelgroupsize
                          #minbucket=100,
                          #xval=10 #10 Fold Validation
                      ))
        plotcp(model,main="",sub=possible_model)
        if(fuelgroupsize > 30){
            box("outer",col="green")
        }else{
            box("outer",col="red")
        }
        
        printcp(model)
        plot(model, uniform=TRUE)
        title(main=sprintf("Classification Tree "),sub=possible_model)
        text(model, use.n=TRUE, all=TRUE, cex=.8)
        if(fuelgroupsize > 30){
            box("outer",col="green")
        }else{
            box("outer",col="red")
        }
        println()

          
   }
  
}


