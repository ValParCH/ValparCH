library(data.table)
library(raster)
library(ggplot2)

setwd("C:/Users/.../")

#Load lulc map

fold<-"C:/Users/.../"

lulc<-raster(paste(fold,"LULC_92-95_25.tif",sep="/"))

#Load labels for LULC map

lab<-fread("C:/Users/.../LULC_labels.csv")


#Inat
fold_i<-"C:/Users/.../Inaturalist"
data_inat<-fread(paste(fold_i,"inat_10-21_CH.csv",sep="/"))
bfc <- extract(lulc, data_inat)
inat<-cbind(data_inat,bfc)
colnames(inat)<-c("long","lat","lulc")
newdf<-as.data.frame(table(inat$lulc))


#Flickr
fold_f<-"C:/Users/.../Flickr"
data_flickr<-fread(paste(fold_f, "Flickr_keyword_06-21_LV95.csv",sep="/"))
bfc_f <- extract(lulc, data_flickr)

flick<-cbind(data_flickr,bfc_f)

colnames(flick)<-c("long","lat","lulc")
newdf2<-as.data.frame(table(flick$lulc))

#attributing labels to lulc classes
newdf<-merge(newdf,lab,by.x= "Var1", by.y= "LULC")
newdf2<-merge(newdf2,lab,by.x= "Var1", by.y= "LULC")

#differenciating the two data sources 
a<-newdf
b<-newdf2

a$source<-"Inaturalist"
b$source<-"Flickr"

c<-rbind(a,b)

p_diff<-ggplot(c,aes(x =Freq ,y = reorder(NAME, Freq))) + 
  ggtitle("Geolocalised photo correspondence with LULC map")+
  xlab("Frequency (Inaturalist, n= 9849; Flickr, n= 5556)")+
  ylab("LULC category")+
  geom_bar(aes(fill = source),stat = "identity",position = "dodge")+
  scale_fill_manual(values=c("#99d8c9","#006d2c"))+
  theme_bw()+
  theme(axis.text.x = element_text(hjust = 1))

ggsave("Flickr_inat_LULC_sep.png", width = 11, height = 8)
