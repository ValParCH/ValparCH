
library(raster)
library(stars)
library(rgdal)
library(sf)


#--- Folder paths

wd<-"C:/Users/kuelling/Documents/VALPAR/ES Assessment/Carbon sequestration/FINAL/SUPPLY/CODE"
setwd(wd)

dir.create(paste(scratch,"lulc_clip",sep="/"))

scratch<-paste(wd,"scratch",sep="/")

dir.create(paste(scratch,"lulc_clip","97",sep="/"))
dir.create(paste(scratch,"lulc_clip","09",sep="/"))
dir.create(paste(scratch,"lulc_clip","18",sep="/"))
dir.create(paste(scratch,"Invest_models",sep="/"))


#--- loading Local variables STATIC

dem<- raster("C:\\Users\\kuelling\\Documents\\VALPAR\\DATA\\DEM(unil)\\DEM_mean_LV95.tif")
prodreg<- readOGR("C:\\Users\\kuelling\\Documents\\VALPAR\\DATA\\Swiss_Regions_SHP\\PRODREG.shp") #production regions from CH

#--- loading Local variables TEMPORAL

lulc97<- raster("C:/Users/kuelling/Documents/VALPAR/DATA/OFS25_DS/1997/results/LU-CH_1997.tif")#LULC raster
lulc09<- raster("C:/Users/kuelling/Documents/VALPAR/DATA/OFS25_DS/2009/results/LU-CH_2009.tif")#LULC raster
lulc18<- raster("C:/Users/kuelling/Documents/VALPAR/DATA/OFS25_DS/2018/results/LU-CH_2018.tif")#LULC raster

#--- reclassify DEM 

m1<- c(0,600, 1, 
       600,1200, 2,
       1200,Inf, 3)
m11 <- matrix(m1,ncol = 3, byrow=TRUE)
dem_r<-reclassify(dem, m11)

#--- raster to polygon 

dem_p <- sf::as_Spatial(sf::st_as_sf(stars::st_as_stars(dem_r), as_points = FALSE, merge = TRUE)) 

#--- intersect of elevation and production region

regelev<- intersect(dem_p, prodreg)

#--- creating new column with region + elevation class in the attribute table of regelev

for(i in 1:nrow(regelev@data)){
  regelev@data$regelev_n[i]<-paste(regelev@data$ProdregN_1[i], regelev@data$DEM_mean_LV95[i], sep="")
}

#WARNING: the first character will not be saved by R, has to be rewritten

regelev@data$regelev_n<- gsub("????", "e", regelev@data$regelev_n) # removing weird accents
regelev@data$regelev_n<- gsub(" ", "", regelev@data$regelev_n) # removing tabs


# Function to apply to each LULC map
#--- reclassifying the lulc map in 18 categories

rast_function_regelev<-function(lulc,year){

m<-c(0,0,1,12,2,12,3,12,4,12,5,12,6,12,7,12,8,12,9,12,10,12,11,12,12,12,13,12,14,12,15,12,16,13,17,12,18,13,19,12,20,12,21,13,22,12,23,13,24,12,25,12,26,12,27,12,28,12,29,12,30,12,31,15,32,13,33,13,34,13,35,13,36,13,37,7,38,7,39,5,40,3,41,3,42,18,43,18,44,4,45,18,46,18,47,4,48,8,49,18,50,1,51,1,52,0,53,1,54,1,55,1,56,2,57,2,58,2,59,1,60,2,61,10,62,10,63,12,64,4,65,9,66,12,67,11,68,9,69,16,70,16,71,18,72,16)

m1 <- matrix(m,ncol = 2, byrow=TRUE)

lulc_r<-reclassify(lulc, m1)

#--- Creating the rasters for each region

list_reg_elev<-data.frame(unique(regelev@data$regelev_n))

for(i in 1:nrow(list_reg_elev)){
  
  name<-list_reg_elev$unique.regelev.data.regelev_n.[i]
  a<-regelev[regelev$regelev_n == name,]
  b<-crop(lulc_r,a)
  c<-mask(b,a)
  
  NAvalue(c)<-255
  
  writeRaster(c,paste(scratch,"lulc_clip",year,paste(name,".tif",sep=""),sep="/"), overwrite = TRUE, NAflag  = 255)
  print(paste("raster", name,"created", i, "/",length(unique(regelev@data$regelev_n)),sep =" "))
}
}

#----Applying function to each year, runtine 10min each

rast_function_regelev(lulc97,"97")
rast_function_regelev(lulc09,"09")
rast_function_regelev(lulc18,"18")
