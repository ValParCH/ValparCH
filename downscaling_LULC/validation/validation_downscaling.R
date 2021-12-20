library(terra)
library(ggplot2)
library(dismo)
library(sf)
library(data.table)
library(RColorBrewer)
library(pals)

wd<-"C:/Users/kuelling/Documents/VALPAR/Downscaling/validation"

setwd(wd)


#-1 data to load

#Downscaled map to test
lu25<-raster("C:/Users/kuelling/Documents/VALPAR/Downscaling/results/2018/LULC_25_2018_v3.tif")

#OFS statistiques de la superficie (GEOSTAT)
areal<-fread("C:/Users/kuelling/Documents/VALPAR/Downscaling/Nathan/OFS/gd-b-00.03-36-noas04P/AREA_NOAS04_72_191202.csv")

#Labels from 72 categories GEOSTAT
labels<-fread("C:/Users/kuelling/Documents/VALPAR/DATA/OFS_GEOSTAT/labels_EN.csv")

#-2 Data processing

areal<-areal[,c("E","N","AS18_72")]
colnames(labels)<-c("LU_NUM","NAME")

#extract random points from areal data

nbpt<-500000 # number of points to sample (500K runs fine)

set.seed(00001)
vdata<-areal[sample(nrow(areal), nbpt), ] #select random points
coordinates(vdata)<-c("E","N")

tdata<-data.frame(extract(lu25,vdata)) #extract from downscaled map
colnames(tdata)<-"lu25"

data<-cbind(vdata,tdata)@data #merging extracted data (LU25) with observation points (AS18)

#-3 Percentage of correspondance 

tab<-table(data$AS18_72 == data$lu25)
per_cor<-round(tab[2]/nrow(data),2)

per_cor # % of points rightly classified



#-4 Investingating misattributed data points

data_f<-data[which(data$AS18_72!=data$lu25),] #Removing datapoints that are the same in LU25 and AS18

nbmispt<-nrow(data_f) #number of falsely attributed points

comp<-data.frame(table(data_f$AS18_72,data_f$lu25))
comp<-comp[comp$Freq!=0,] #removing LU25 categories that have no correspondence in AS18 (categories that were not msiclassified)
colnames(comp)<-c("AS18","LU25","freq")

comp_trim<-comp

#-4.1 Creating a new dataframe for visualisation of missatributed categories 

#-4.2 generating name for each column (based on label data)

labels$LU_NUM<-as.character(labels$LU_NUM)

comp_trim$LU25<-as.character(comp_trim$LU25)
comp_trim$AS18<-as.character(comp_trim$AS18)

comp_trim$AS18_NAME<-NA
comp_trim$LU25_NAME<-NA

for(i in 1:nrow(comp_trim)){
a<-comp_trim$AS18[i]
b<-comp_trim$LU25[i]

comp_trim$AS18_NAME[i]<-labels$NAME[as.numeric(a)]
comp_trim$LU25_NAME[i]<-labels$NAME[as.numeric(b)]
  
}

#-4.3 removing those with frequency <10 --> meaning that those categories were misattributed only a few times, not worth showing on graph
#/!\ depends on the number of data points. for >500K, we can use freq >10

fr_trim<-10 # defining the threshold

sum(comp_trim[comp_trim$freq<=fr_trim,]$freq) #2381 misattributions
sum(comp_trim[comp_trim$freq>fr_trim,]$freq) #95046 misattributions

comp_trim<-comp_trim[comp_trim$freq>fr_trim,]

#-4.4 Generating frequencies of misattributions for display (method 2 below)

comp_trim$freq_tot<-NA
comp_trim$freq_tot_LU25<-NA

list_AS18<-unique(comp_trim$AS18)

for(i in 1:length(list_AS18)){
  a<-list_AS18[i]
  b<-comp_trim[comp_trim$AS18==a,]
  c<-sum(b$freq)
  comp_trim[comp_trim$AS18 == a,]$freq_tot<-c
}

list_LU25<-data.frame(unique(comp_trim$LU25))
list_LU25$freq<-NA
list_LU25$newcat<-list_LU25$unique.comp_trim.LU25.

for(i in 1:nrow(list_LU25)){
  a<-list_LU25$unique.comp_trim.LU25.[i]
  b<-comp_trim[comp_trim$LU25==a,]
  c<-sum(b$freq)
  list_LU25$freq[i]<-c
  comp_trim[comp_trim$LU25 == a,]$freq_tot_LU25<-c
}

list_LU25[list_LU25$freq<=600,]$newcat<-0

comp_trim$LU25_nw<-NA

for(i in 1:nrow(list_LU25)){
  a<-list_LU25$unique.comp_trim.LU25.[i]
  comp_trim[comp_trim$LU25==a,]$LU25_nw<-list_LU25$newcat[i]
  
}

comp_trim$LU25_NAME_nw<-comp_trim$LU25_NAME
comp_trim[comp_trim$LU25_nw==0,]$LU25_NAME_nw<-"Other categories"

#-5 Visualise: 2 methods


#-5.1 stacked barplot with legend 

# Stacked barplot

p_d<-ggplot(comp_trim, aes(fill=reorder(LU25_NAME_nw,freq_tot_LU25), y=reorder(AS18_NAME, freq_tot), x=freq)) + 
  ggtitle(paste("Recurring false points attributions (total points: ",round(nbpt,10),", misattributed: ",as.character(nbmispt),", overall correspondence: ",per_cor,")",sep=""))+
  xlab("downscaled category attributed (frequency)")+
  ylab("AS18 original points observations")+
  geom_bar(position="stack", stat="identity")+
  theme_bw()+
  theme(legend.position=c(0.6,0.6))+
  scale_fill_manual(values=as.vector(alphabet(length(table(comp_trim$LU25_NAME_nw)))))

p_d

#-5.2 grouped barplot with text for most represented categories
# (difficult to display) 

comp_trim2<-comp_trim[comp_trim$freq_tot>3500,]
comp_trim2$LU25_NAME_nw<-as.factor(comp_trim2$LU25_NAME_nw)

p_dif<-ggplot(comp_trim2, aes(fill=LU25_NAME_nw, y=reorder(AS18_NAME, freq_tot), x=freq)) + 
  ggtitle("Recurring false points attributions ")+
  xlab("downscaled category attributed (frequency)")+
  ylab("AS18 original points observations")+
  geom_bar(aes(fill = LU25_NAME_nw),stat = "identity", position = position_dodge(0.9))+
  geom_text(data = comp_trim2,aes(x = freq, group=LU25_NAME_nw, reorder(AS18_NAME, freq_tot), label = LU25_NAME_nw),position = position_dodge(0.9),vjust=.4, hjust=-.02, size=2)+
  theme_bw()+
  theme(legend.position = "none")

p_dif


#-5.3 Export

png("ds_comparison.png",width=1200, height=1000)

p_d #plot name

dev.off()

png("ds_comparison.png",width=2000, height=1500)

p_dif #plot name

dev.off()
