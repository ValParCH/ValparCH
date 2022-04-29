library(raster)
library(rgdal)
library(sf)

wd<-"C:/Users/kuelling/Documents/VALPAR/ES Assessment/Carbon sequestration/FINAL/SUPPLY/CODE"
setwd(wd)


#--- folders for each temporal analysis

#data
fold97<-paste(wd,"scratch/Invest_models/97",sep="/")
fold09<-paste(wd,"scratch/Invest_models/09",sep="/")
fold18<-paste(wd,"scratch/Invest_models/18",sep="/")

#results

res97<-"C:/Users/kuelling/Documents/VALPAR/ES Assessment/Carbon sequestration/FINAL/SUPPLY/97"
res09<-"C:/Users/kuelling/Documents/VALPAR/ES Assessment/Carbon sequestration/FINAL/SUPPLY/09"
res18<-"C:/Users/kuelling/Documents/VALPAR/ES Assessment/Carbon sequestration/FINAL/SUPPLY/18"

#output names

n97<-"CAR_S_CH_97.tif"
n09<-"CAR_S_CH_09.tif"
n18<-"CAR_S_CH_18.tif"


#--- Function to do for each time period

carbon_process_3<-function(in_folder, results, name_out){


#--- move all final outputs to new folder

list_files<-list.files(in_folder)
dir.create(paste(in_folder,"tot_c_united",sep="/"))

print("directory created")

for(i in 1:length(list_files)){
  print(list_files[i])
  
  path1<- paste(in_folder,list_files[i],sep="/")
  name<- paste("tot_c_cur_", list_files[i],".tif",sep="")
  path2<- paste(path1,name,sep="/")
  file.copy(path2,paste(in_folder,"tot_c_united",sep="/"))
}

print("files copied")

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

writeRaster(bind,(paste(results,name_out, sep="/")), format="GTiff",overwrite = TRUE)

print("final raster written")
}

#--- Applying for each period

carbon_process_3(fold97,res97,n97)
carbon_process_3(fold09,res09,n09)
carbon_process_3(fold18,res18,n18)
