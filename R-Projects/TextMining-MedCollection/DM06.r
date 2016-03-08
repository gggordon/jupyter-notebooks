
library(tm)

medCollection=Corpus(DirSource("medCollection"))
medCollection[["2.txt"]]
# inspect(medCollection)

medCollection=tm_map(medCollection,removePunctuation)

medCollection=tm_map(medCollection,stripWhitespace)

#medCollection=tm_map(medCollection,tolower)

medCollection=tm_map(medCollection,removeWords,stopwords("english"))

medCollection=tm_map(medCollection,stemDocument)

#inspect(medCollection)
medCollection["2.txt"]

dtmMedCollection = DocumentTermMatrix(medCollection)

#inspect(dtmMedCollection[,30:35])

head(findFreqTerms(dtmMedCollection,5),45)

findAssocs(dtmMedCollection,"data",0.9)

findAssocs(dtmMedCollection,"data",0.25)

library(wordcloud)

m=as.matrix(dtmMedCollection)

v=sort(colSums(m),decreasing=TRUE)

myNames = names(v)

d=data.frame(word=myNames,freq=v)

wordcloud(d$word,d$freq,min.freq=2)


