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
  
  list1<-c(1,val,2,0,3,0,4,0,5,0,6,0,7,0,8,0,9,0,10,0,11,0,12,0,13,0,14,0,15,0,16,0,17,0,18,0)
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


