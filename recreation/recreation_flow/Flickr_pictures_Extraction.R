library(progress)


wd<-setwd("C:/Users/kuelling/Documents/VALPAR/ES Assessment/Recreation/Pictures/other")

#photosearcher package

devtools::install_github("nfox29/photosearcher")
library(photosearcher)

api_key = "206413bd47bac2634aa8d667cf28b968"


# Setting research terms
datestart = "2006-01-01"
datestop = "2021-01-01"
bb = "5.835645,45.73923,10.64321,47.83945" # swiss bounding box
tag_list = c("mountains","montagn*", "berg*", "foret*", "foresta", "wald", "natur*", "landschaft", "paysage", "paesaggio", "landscape")

#bb= "6.443481,46.491168,6.778564,46.623299" # Lausanne




list_query<-NA

for(i in 1:length(tag_list)){
  a<-tag_list[i]
  b<- photo_search(
    mindate_taken = datestart,
    maxdate_taken = datestop,
    text = a,
    bbox = bb,
    has_geo = TRUE) 
  list_query<-rbind(list_query,b)
 print(paste(((i*100)/length(tag_list)),"%",sep=" "))
  
}


list_unique<-list_query[-which(duplicated(list_query$owner)),]
exp<- list_unique[c(2,20,21)]
write.csv(exp,paste(wd,"flickr_un_keyword_06-21.csv",sep="/"))











