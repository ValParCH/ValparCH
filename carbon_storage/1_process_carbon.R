
library(raster)
library(stars)
library(rgdal)
library(sf)


wd<-"C:/Users/kuelling/Documents/VALPAR/ES Assessment/Carbon sequestration/Automatisation/git"
setwd(wd)

#--- loading Local variables

dem<- raster("C:\\Users\\kuelling\\Documents\\VALPAR\\DATA\\DEM(unil)\\DEM_mean_LV95.tif")
prodreg<- readOGR("C:\\Users\\kuelling\\Documents\\VALPAR\\DATA\\Swiss_Regions_SHP\\PRODREG.shp") #production regions from CH
lulc<- raster("C:\\Users\\kuelling\\Documents\\VALPAR\\DATA\\UNIL_data\\lulc\\LULC_92-95_25.tif")#LULC raster


scratch<- paste(wd, "scratch", sep="/")
dir.create(paste(scratch,"lulc_clip",sep="/"))
results<- paste(wd, "results", sep="/")

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

regelev@data$regelev_n<- gsub("é", "e", regelev@data$regelev_n) # removing weird accents
regelev@data$regelev_n<- gsub(" ", "", regelev@data$regelev_n) # removing tabs

#--- reclassifying the lulc map in 18 categories

m<-c(9,1,10,1,11,1,12,2,13,1,14,1,15,2,16,1,17,1,18,6,19,1,20,17,21,12,23,12,24,12,25,12,26,12,27,12,28,12,29,12,31,12,32,13,33,12,34,12,35,12,36,12,37,12,38,13,41,12,45,12,46,12,47,12,48,12,49,12,51,13,52,14,53,13,54,13,56,13,59,15,61,12,62,12,63,12,64,12,65,12,66,12,67,13,68,13,69,17,71,5,72,5,73,5,75,7,76,7,77,7,78,7,81,18,82,3,83,18,84,4,85,18,86,4,87,18,88,18,89,13,90,16,91,10,92,10,93,12,95,11,96,13,97,9,98,12,99,16)
m1 <- matrix(m,ncol = 2, byrow=TRUE)

lulc_r<-reclassify(lulc, m1)

#--- Creating the rasters for each region

list_reg_elev<-data.frame(unique(regelev@data$regelev_n))


for(i in 1:nrow(list_reg_elev)){
  
  name<-list_reg_elev$unique.regelev.data.regelev_n.[i]
  a<-regelev[regelev$regelev_n == name,]
  b<-crop(lulc_r,a)
  c<-mask(b,a)
  
  writeRaster(c,paste(scratch,"lulc_clip",paste(name,".tif",sep=""),sep="/"), overwrite = TRUE)
  print(paste("raster", name,"created", i, "/",length(unique(regelev@data$regelev_n)),sep =" "))
}




