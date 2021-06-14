library(data.table)
library(raster)
library(rgdal)

wd<-setwd("C:/Users/kuelling/Documents/VALPAR/ES Assessment/material_assistance/wood_supply")
reg<-fread(paste(wd,"Biophysical_tables_92-97","c_gain_9297.csv",sep="/"))


#-----Attributing average carbon gain values


for(i in 1:nrow(reg)){
  name<-reg$name[i]
  val<-reg$val_px[i]
  
  print(paste(name, ", C value:", val,sep=" "))
  
  list1<-c(10,val,11,val,13,val,14,val,18,val,19,val,9,val,12,0,15,0,16,0,48,0,81,0,82,0,86,0,96,0,71,0,72,0,73,0,75,0,76,0,78,0,87,0,89,0,97,0,91,0,92,0,95,0,31,0,33,0,34,0,35,0,36,0,37,0,38,0,41,0,61,0,62,0,63,0,64,0,65,0,66,0,45,0,46,0,47,0,49,0,51,0,52,0,53,0,54,0,56,0,67,0,68,0,59,0,90,0,99,0,83,0,84,0,85,0,88,0)
  mat<- matrix(list1,ncol = 2, byrow=TRUE)
  
  namext<-paste(name,".tif",sep="")
  rast<-raster(paste(wd,"rasters",namext,sep="/"))
  newrast<-reclassify(rast,mat)
  
  exp_name<-paste(name,"reclass",sep="_")
  writeRaster(newrast,(paste(wd,"rast_recl",exp_name, sep="/")), format="GTiff")
  
  
  print(paste(exp_name, "done!",sep=" "))
  
  
}

#-----Creating an empty raster layer before merging all datasets

bind<-raster()
crs(bind)<-"+proj=somerc +lat_0=46.9524055555556 +lon_0=7.43958333333333 +k_0=1 +x_0=2600000 +y_0=1200000 +ellps=bessel +units=m +no_defs"
extent(bind)<-c(2480000, 2840000, 1070000, 1300000)
res(bind)<-25
origin(bind)<-0


#------Merging of all raster datasets using mosaic

for(i in 1:nrow(reg)){
  name<-reg$name[i]
  imp_name<-paste(name,"reclass",sep="_")
  imp_name<-paste(imp_name,".tif",sep="")
  nr<-raster(paste(wd,"rast_recl",imp_name,sep="/"))
  
  bind<-mosaic(bind,nr,fun=mean,tolerance=0.05)
  print(paste(imp_name, " added"))
}

thecrs<-sp::CRS('+init=epsg:2056')
crs(bind)<- thecrs

writeRaster(bind,(paste(wd,"results","C_gain_92-97", sep="/")), format="GTiff",overwrite = TRUE)

#---- translate to an index 

bind_ind<- bind/maxValue(bind)

writeRaster(bind_ind,(paste(wd,"results","C_gain_92-97_index", sep="/")), format="GTiff",overwrite = TRUE)




