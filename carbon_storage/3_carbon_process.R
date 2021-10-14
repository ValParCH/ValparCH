library(raster)
library(rgdal)
library(sf)

wd<-"C:/Users/kuelling/Documents/VALPAR/ES Assessment/Carbon sequestration/Automatisation/git"
setwd(wd)


#--- Load local variables and paths
#folder containing Invest models
in_folder<- "C:/Users/kuelling/Documents/VALPAR/ES Assessment/Carbon sequestration/Automatisation/git/scratch/Invest_models"
results<- paste(wd, "results", sep="/")

#--- move all final outputs to new folder

list_files<-list.files(in_folder)
dir.create(paste(in_folder,"tot_c_united",sep="/"))


for(i in 1:length(list_files)){
  print(list_files[i])
  
  path1<- paste(in_folder,list_files[i],sep="/")
  name<- paste("tot_c_cur_", list_files[i],".tif",sep="")
  path2<- paste(path1,name,sep="/")
  file.copy(path2,paste(in_folder,"tot_c_united",sep="/"))
}


#--- bind together each file

#creating empty raster to fill
bind<-raster()
crs(bind)<-"+proj=somerc +lat_0=46.9524055555556 +lon_0=7.43958333333333 +k_0=1 +x_0=2600000 +y_0=1200000 +ellps=bessel +units=m +no_defs"
extent(bind)<-c(2480000, 2840000, 1070000, 1300000)
res(bind)<-25
origin(bind)<-0

#merging each raster

list_lu<- list.files(paste(in_folder,"tot_c_united",sep="/"))


#### PROBLEM IN THE BINDING; linked to the NA values, need to calibrate the mosaic function



for(i in 1:length(list_lu)){
  name<-list_lu[i]
  nr<-raster(paste(in_folder,"tot_c_united",name,sep="/"))
  bind<-mosaic(bind,nr,fun=max,tolerance=0.05)
  print(paste(name, " added"))
}

thecrs<-sp::CRS('+init=epsg:2056')
crs(bind)<- thecrs

writeRaster(bind,(paste(wd,"results","carbon_stored_92-97.tif", sep="/")), format="GTiff",overwrite = TRUE)
