library(utils)
library(raster)
library(sp)

#-- Local 

wd<-setwd("C:/Users/kuelling/Documents/VALPAR/DATA/copernicus")
fold<-paste(wd, "Export_LAI_14-18", sep="/")
outfold<-paste(wd, "data_process", sep="/")
repo<-paste(wd, "grouped_data", sep= "/")
output<- paste(wd,"processed_data", sep="/")

#--- Lists

ziplist<- list.files(fold)

obs_date<-NA
date_list<-as.data.frame(obs_date)


#--- exctracting files of interest from the original download

for(i in 1:length(ziplist)){
  unzip(paste(fold,ziplist[i], sep="/"), exdir = outfold )
  
  #substr the date from the file extracted, appending it to a list of dates for data checking
  date_string<-substr(ziplist[i], 14,21)
  ds<-data.frame(date_string)
  names(ds)<-"obs_date"
  date_list<-rbind(date_list,ds)
  
  subfiles<- list.files(paste(outfold,date_string, sep="/" ))
  temp_fold<-paste(outfold,date_string, sep="/" )
  name<-subfiles[grep("LAI_",subfiles)]
  temp_file<- paste(temp_fold, name, sep="/")
  
  file.copy(from = temp_file, to= paste(repo, name, sep="/") )
  
  print(paste("extracted:",date_string,i,"of",length(ziplist),sep=" "))
}

date_list$obs_date<-as.Date(date_list$obs_date, format= "%Y%m%d")
date_list<-na.omit(date_list)
date_list$timedif<-NA

i<-2
while(i <= nrow(date_list)){
  date_list$timedif[i]<-difftime(date_list$obs_date[i],date_list$obs_date[i-1])
  i<-i+1
}

range(date_list$obs_date)#"2014-01-10" "2018-12-31"
range(date_list$timedif, na.rm = TRUE) # ranges between 8 and 11 days

#-- Deleting temporary folders and files

unlink(paste(outfold, list.files(outfold), sep = "/"),recursive = TRUE)

####-- Computing summary statistics over the entire period

#-Paths

#--loading LAI rasters

r_list<-list.files(repo,full.names = TRUE)
r_stack<-raster::stack(r_list)

#--Computing summary statistics over the entire period. 

LAI_mean<-calc(r_stack, fun= mean, na.rm = TRUE)
LAI_median<-calc(r_stack, fun= median, na.rm = TRUE)
LAI_max<-calc(r_stack, fun = max, na.rm = TRUE)
LAI_min<-calc(r_stack, fun = min, na.rm = TRUE)

par(mfrow=c(2,2))
plot(LAI_mean ,main= "mean")
plot(LAI_median, main= "median")
plot(LAI_max, main ="max")
plot(LAI_min, main= "min")


#-- Transforming to swiss coordinates and extent, resampling to 25m 
#/!\ at this point load a file with the correct resolution, crs and extent, mine's called template

memory.limit(90000)

LAI_mean_lv95 <- projectRaster(from = LAI_mean, to= template)
LAI_median_lv95 <- projectRaster(from = LAI_median, to= template)
LAI_min_lv95 <- projectRaster(from = LAI_min, to= template)
LAI_max_lv95 <- projectRaster(from = LAI_max, to= template)

par(mfrow=c(2,2))
plot(LAI_mean_lv95 ,main= "mean")
plot(LAI_median_lv95, main= "median")
plot(LAI_max_lv95, main ="max")
plot(LAI_min_lv95, main= "min")

#-- Export

writeRaster(LAI_mean_lv95, paste(output,"LAI_mean_25_14-18.tif",sep="/"))
writeRaster(LAI_median_lv95, paste(output,"LAI_median_25_14-18.tif",sep="/"))
writeRaster(LAI_max_lv95, paste(output,"LAI_max_25_14-18.tif",sep="/"))
writeRaster(LAI_min_lv95, paste(output,"LAI_min_25_14-18.tif",sep="/"))

saveRDS(LAI_mean_lv95, file = paste(output,"LAI_mean_25_14-18.rds",sep="/"))
saveRDS(LAI_median_lv95, file = paste(output,"LAI_median_25_14-18.rds",sep="/"))
saveRDS(LAI_min_lv95, file = paste(output,"LAI_min_25_14-18.rds",sep="/"))
saveRDS(LAI_max_lv95, file = paste(output,"LAI_max_25_14-18.rds",sep="/"))

#-- Deleting redundant files

unlink(paste(repo, list.files(repo), sep = "/"),recursive = TRUE)
