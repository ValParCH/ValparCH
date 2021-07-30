library(utils)
library(raster)
library(sp)


#--Local

wd<-setwd("C:/Users/kuelling/Documents/VALPAR/DATA/copernicus/DLT")
dlt<-raster(paste(wd,"Export_DLT_2018","DLT_2018_CH_10m.tif",sep ="/"))
output<-paste(wd,"Export_DLT_2018","LV95",sep="/")
#Loading a template with right coordinates and extent (here, called "template")

#--reprojecting to swiss grid (takes very long to do, ended up doing it in qgis)

#DLT_CH_25 <- projectRaster(from = dlt, to= template, method= "ngb")

dlt<-raster(paste(wd,"Export_DLT_2018","LV95", "DLT_25_18_LV95.tif",sep ="/"))

compareRaster(dlt, template)

#--Export

writeRaster(dlt, paste(output,"DLT_25_18.tif",sep="/"))
saveRDS(dlt, file = paste(output,"DLT_25_18_LV95.rds",sep="/"))
