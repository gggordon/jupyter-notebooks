
## Week 06 In Class Assignment
### Regression, SVM, Neural Networks in R
#### Author: G. Gordon

NB. In class references have been used as requested including code


```R
# Import the Data
train.data = read.csv("homeworkTrain.csv", header=F)
test.data = read.csv("homeworkTest.csv", header=F)
```


```R
# Have a look at the data
"Training Set"
head(train.data)
"Test Set"
head(test.data)
```




'Training Set'






<table>
<thead><tr><th></th><th scope=col>V1</th><th scope=col>V2</th><th scope=col>V3</th><th scope=col>V4</th></tr></thead>
<tbody>
	<tr><th scope=row>1</th><td>0.2879303</td><td>0.7341361</td><td>0.7556002</td><td>16.54247</td></tr>
	<tr><th scope=row>2</th><td>0.2909103</td><td>0.3172334</td><td>0.6802567</td><td>13.04822</td></tr>
	<tr><th scope=row>3</th><td>0.9694784</td><td>0.5068852</td><td>0.4053819</td><td>15.67479</td></tr>
	<tr><th scope=row>4</th><td>0.186544</td><td>0.148853</td><td>0.9125063</td><td>12.6434</td></tr>
	<tr><th scope=row>5</th><td>0.3336404</td><td>0.2991701</td><td>0.8440536</td><td>13.21514</td></tr>
	<tr><th scope=row>6</th><td>0.3456881</td><td>0.6626665</td><td>0.8340489</td><td>15.75158</td></tr>
</tbody>
</table>







'Test Set'






<table>
<thead><tr><th></th><th scope=col>V1</th><th scope=col>V2</th><th scope=col>V3</th><th scope=col>V4</th></tr></thead>
<tbody>
	<tr><th scope=row>1</th><td>0.1735165</td><td>0.6124014</td><td>0.05369461</td><td>15.58912</td></tr>
	<tr><th scope=row>2</th><td>0.6262476</td><td>0.4952835</td><td>0.6988383</td><td>16.00405</td></tr>
	<tr><th scope=row>3</th><td>0.1048847</td><td>0.9719626</td><td>0.5514053</td><td>22.20358</td></tr>
	<tr><th scope=row>4</th><td>0.5676899</td><td>0.2416946</td><td>0.8891438</td><td>15.02003</td></tr>
	<tr><th scope=row>5</th><td>0.5628262</td><td>0.5149687</td><td>0.03190279</td><td>15.15275</td></tr>
	<tr><th scope=row>6</th><td>0.6102789</td><td>0.5169022</td><td>0.3068901</td><td>15.60651</td></tr>
</tbody>
</table>





```R
"Summary Statistcs for Test and Training Set"
# Have a look at the data
"Training Set"
head(summary(train.data))
"Test Set"
head((test.data))
```




'Summary Statistcs'






'Training Set'






<table>
<thead><tr><th></th><th scope=col>      V1</th><th scope=col>      V2</th><th scope=col>      V3</th><th scope=col>      V4</th></tr></thead>
<tbody>
	<tr><th scope=row></th><td>Min.   :0.00416   </td><td>Min.   :0.03183   </td><td>Min.   :0.002938  </td><td>Min.   :12.21     </td></tr>
	<tr><th scope=row></th><td>1st Qu.:0.25213   </td><td>1st Qu.:0.20035   </td><td>1st Qu.:0.221765  </td><td>1st Qu.:13.17     </td></tr>
	<tr><th scope=row></th><td>Median :0.46899   </td><td>Median :0.51933   </td><td>Median :0.495974  </td><td>Median :14.55     </td></tr>
	<tr><th scope=row></th><td>Mean   :0.46602   </td><td>Mean   :0.48569   </td><td>Mean   :0.502073  </td><td>Mean   :15.37     </td></tr>
	<tr><th scope=row></th><td>3rd Qu.:0.65901   </td><td>3rd Qu.:0.73277   </td><td>3rd Qu.:0.770337  </td><td>3rd Qu.:16.75     </td></tr>
	<tr><th scope=row></th><td>Max.   :0.98034   </td><td>Max.   :0.96962   </td><td>Max.   :0.987168  </td><td>Max.   :23.91     </td></tr>
</tbody>
</table>







'Test Set'






<table>
<thead><tr><th></th><th scope=col>V1</th><th scope=col>V2</th><th scope=col>V3</th><th scope=col>V4</th></tr></thead>
<tbody>
	<tr><th scope=row>1</th><td>0.1735165</td><td>0.6124014</td><td>0.05369461</td><td>15.58912</td></tr>
	<tr><th scope=row>2</th><td>0.6262476</td><td>0.4952835</td><td>0.6988383</td><td>16.00405</td></tr>
	<tr><th scope=row>3</th><td>0.1048847</td><td>0.9719626</td><td>0.5514053</td><td>22.20358</td></tr>
	<tr><th scope=row>4</th><td>0.5676899</td><td>0.2416946</td><td>0.8891438</td><td>15.02003</td></tr>
	<tr><th scope=row>5</th><td>0.5628262</td><td>0.5149687</td><td>0.03190279</td><td>15.15275</td></tr>
	<tr><th scope=row>6</th><td>0.6102789</td><td>0.5169022</td><td>0.3068901</td><td>15.60651</td></tr>
</tbody>
</table>





```R
par(mfrow=c(2,2))
for(i in 1:ncol(train.data)){
    plot(density(train.data[,i]),main=paste("Train Data : Distribution of Column ",i))
}
```


![svg](output_4_0.png)


### Simple Linear Regression

Regression models operate based on assumptions and are 
better applied when the assumption of each type of regression is met and verified.
Visualizations and other means to identify relationships between variables and variable data types
also assist this process. However, this assignment only requests the use of a blind model 
i.e. assuming all features are important and that the model is indeed linear


```R
train.regression.fit = lm(V4 ~ ., data=train.data)
```


```R
"Possible Model"
summary(train.regression.fit)
par(mfrow=c(2,2))
plot(train.regression.fit)
```




'Possible Model'






    
    Call:
    lm(formula = V4 ~ ., data = train.data)
    
    Residuals:
        Min      1Q  Median      3Q     Max 
    -1.4951 -0.9749 -0.1416  0.8869  3.3303 
    
    Coefficients:
                Estimate Std. Error t value Pr(>|t|)    
    (Intercept)  10.0597     0.3238  31.070  < 2e-16 ***
    V1            1.9786     0.4059   4.874 4.32e-06 ***
    V2            8.1718     0.3834  21.316  < 2e-16 ***
    V3            0.8273     0.3704   2.233   0.0279 *  
    ---
    Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
    
    Residual standard error: 1.092 on 96 degrees of freedom
    Multiple R-squared:  0.8478,	Adjusted R-squared:  0.843 
    F-statistic: 178.2 on 3 and 96 DF,  p-value: < 2.2e-16





![svg](output_7_2.png)



```R
# Predict on test data set using regression model
train.regression.pred = predict(train.regression.fit,test.data[,1:3])
# Determine the mean absolute percentage error
model.regression.error=mean(100*abs(test.data[,4] - train.regression.pred)/test.data[,4])
paste('Mean Absolute % Error for Regression Model : ',model.regression.error,'%')
```




'Mean Absolute % Error for Regression Model :  7.55434149593883 %'



### Support Vector Machines


```R
library(e1071) # Load svm from library

```


```R
#Build SVM Model
train.svm.fit = svm(train.data[,1:3],train.data[,4])
plot(train.svm.fit,train.data[,1:3],"V1 ~ V2")
# Predict using test data
train.svm.pred = predict(train.svm.fit,test.data[,1:3])
# Determine the mean absolute percentage error
model.svm.error=mean(100*abs(test.data[,4] - train.svm.pred)/test.data[,4])
paste('Mean Absolute % Error for SVM : ',model.svm.error,'%')
```




'Mean Absolute % Error for SVM :  6.54579535777083 %'



### Neural Networks


```R
library(neuralnet)
```

    Loading required package: grid



```R
train.nn.fit = neuralnet(V4~V1+V2+V3,data=train.data,hidden=4,learningrate=0.01,algorithm="backprop")
train.nn.pred = compute(train.nn.fit,test.data[,1:3])$net.result
model.nn.error=mean(100*abs(test.data[,4] - train.nn.pred)/test.data[,4])
paste('Mean Absolute % Error for Neural Network (4 hidden) : ',model.nn.error,'%')
```




'Mean Absolute % Error for Neural Network (4 hidden) :  10.7505596129476 %'




```R
train.nn.fit = neuralnet(V4~V1+V2+V3,data=train.data,hidden=0,learningrate=0.01,algorithm="backprop")
```


```R
library(RSNNS)
library('devtools')
#(Source : )
source_url('https://gist.githubusercontent.com/fawda123/7471137/raw/466c1474d0a505ff044412703516c34f1a4684a5/nnet_plot_update.r')

```

    SHA-1 hash of file is 74c80bd5ddbc17ab3ae5ece9c0ed9beb612e87ef



```R
set.seed(23)
plot.nnet(train.nn.fit)
```


![svg](output_17_0.png)



```R
train.nn.pred = compute(train.nn.fit,test.data[,1:3])$net.result
```


```R
model.nn.error=mean(100*abs(test.data[,4] - train.nn.pred)/test.data[,4])
paste('Mean Absolute % Error for Neural Network (0 hidden) : ',model.nn.error,'%')
```




'Mean Absolute % Error for Neural Network (0 hidden) :  7.55398572590002 %'



### Conclusion

All models typically performed well on the test data with SVM performing the best.
The mean absolute error starting with best performance:
1. SVM = 6.54% 
2. Neural Network (0 hidden) = 7.5539857 %
3. Linear Regression =  7.55434149 %
4. Neural Network (4 hidden) with 10.75% .

The difference between the error of the neural network model (4 hidden) and the other models imply that the data is more linear.


```R

```
