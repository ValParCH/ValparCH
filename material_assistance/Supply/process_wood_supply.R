## This codes will estimate the elemental yearly carbon gain in productive forests



library(data.table)
library(raster)
library(rgdal)
library(stars)

wd<-"C:/Users/kuelling/Documents/VALPAR/ES Assessment/material_assistance/wood_supply"
setwd(wd)

#---- loading local variables

reg<-fread(paste(wd,"Biophysical_tables","c_gain_9297.csv",sep="/")) #carbon gain tables from national GHG inventory
prodreg<- readOGR("C:\\Users\\kuelling\\Documents\\VALPAR\\DATA\\Swiss_Regions_SHP\\PRODREG.shp") #production regions from CH
lulc<- raster("C:\\Users\\kuelling\\Documents\\VALPAR\\DATA\\UNIL_data\\lulc\\LULC_92-95_25.tif")#LULC raster
dem<-raster("C:\\Users\\kuelling\\Documents\\VALPAR\\DATA\\DEM(unil)\\DEM_mean_LV95.tif")
slope<- slope # from unil data slope mean 

scratch<- paste(getwd(), "scratch",sep="/")

#####--- Part 1. :  creating individual rasters based on elevation and region

# reclassification of DEM:

m1<- c(0,600, 1, 
      600,1200, 2,
      1200,Inf, 3)
m11 <- matrix(m1,ncol = 3, byrow=TRUE)

dem_r<-reclassify(dem, m11)

# transforming raster to polygon
dem_p <- sf::as_Spatial(sf::st_as_sf(stars::st_as_stars(dem_r), as_points = FALSE, merge = TRUE)) 


# create new polygon intersecting elevation and region
regelev<- intersect(dem_p, prodreg)


for(i in 1:nrow(regelev@data)){
  regelev@data$regelev_n[i]<-paste(regelev@data$ProdregN_1[i], regelev@data$DEM_mean_LV95[i], sep="")
}

regelev@data$regelev_n<- gsub("Ã©", "e", regelev@data$regelev_n) # removing weird accents
regelev@data$regelev_n<- gsub(" ", "", regelev@data$regelev_n) # removing tabs

#-combining lulc and slope raster, to later keep only forests that arent on slope too steep
#- reclassifying slope pixels that are in a slope < 110%  (47 degree) (Dupire et al. 2015)

l_m <- c(0,47, 0,    #Too steep= value of 1000, ok= Value of 0
         47,Inf,1000)
mat_s <- matrix(l_m,ncol = 3, byrow=TRUE)
s_prac<-reclassify(slope, mat_s)

lulc<-lulc+s_prac #adding to the lulc raster


#----Creating the rasters for each region

list_reg_elev<-data.frame(unique(regelev@data$regelev_n))


for(i in 1:nrow(list_reg_elev)){
  
  name<-list_reg_elev$unique.regelev.data.regelev_n.[i]
  a<-regelev[regelev$regelev_n == name,]
  b<-crop(lulc,a)
  c<-mask(b,a)
  
  writeRaster(c,paste(scratch,"lulc_clip",paste(name,".tif",sep=""),sep="/"), overwrite = TRUE)
  print(paste("raster", name,"created", i, "/",length(unique(regelev@data$regelev_n)),sep =" "))
}



#####-----Part 2. : Attributing average carbon gain values


for(i in 1:nrow(reg)){
  name<-reg$name[i]
  val<-reg$val_px[i]
  
  print(paste(name, ", C value:", val,sep=" "))
  
  list0<-c(20,Inf, 100)
  mat0<- matrix(list0, ncol= 3, byrow= TRUE)
  
  list1<-c(9,val,10,val,11,val,12,0,13,val,14,val,15,0,16,0,18,val,19,val,100,0)
  mat<- matrix(list1,ncol = 2, byrow=TRUE)
  
  namext<-paste(name,".tif",sep="")
  rast<- raster(paste(scratch,"lulc_clip",namext,sep="/"))
  
  newrast0<-reclassify(rast,mat0)
  newrast<-reclassify(newrast0,mat)
  
  exp_name<-paste(name,"reclass",sep="_")
  writeRaster(newrast,(paste(scratch,"rast_reclass",exp_name, sep="/")), format="GTiff")
  
  
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
  nr<-raster(paste(scratch,"rast_reclass",imp_name,sep="/"))
  
  bind<-mosaic(bind,nr,fun=mean,tolerance=0.05)
  print(paste(imp_name, " added"))
}

thecrs<-sp::CRS('+init=epsg:2056')
crs(bind)<- thecrs

writeRaster(bind,(paste(wd,"results","C_gain_92-97", sep="/")), format="GTiff",overwrite = TRUE)

#---- translate to an index 

bind_ind<- bind/maxValue(bind)

writeRaster(bind_ind,(paste(wd,"results","C_gain_92-97_index", sep="/")), format="GTiff",overwrite = TRUE)


