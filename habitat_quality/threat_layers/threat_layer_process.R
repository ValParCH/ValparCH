library(raster)
library(terra)
library(rgdal)
library(sf)


#########################################################################
##--- Creating threat raster layers for Habitat quality module InVEST
##--- These are based on LULC maps and municipalities polygons
#########################################################################
wd<-"C:/Users/kuelling/Documents/VALPAR/ES Assessment/Habitat_quality/FINAL/SUPPLY/CODE/BPTABLE/layer_build"
setwd(wd)

out_fold<-paste(wd,"LAYERPROD",sep="/")

#-- Loading LULC maps

lulc97<- raster("C:/Users/kuelling/Documents/VALPAR/DATA/OFS25_DS/1997/results/LU-CH_1997.tif")#LULC raster
lulc09<- raster("C:/Users/kuelling/Documents/VALPAR/DATA/OFS25_DS/2009/results/LU-CH_2009.tif")#LULC raster
lulc18<- raster("C:/Users/kuelling/Documents/VALPAR/DATA/OFS25_DS/2018/results/LU-CH_2018.tif")#LULC raster

#-- Loading municipalities variable

swiss_mun<-readOGR("C:/Users/kuelling/Documents/VALPAR/DATA/Swiss boundaries/swissBOUNDARIES3D_1_3_TLM_HOHEITSGEBIET.shp")


#### 1) processing of the municipality layer -- adding a population density column to the municpalities

swiss_mun@data$EINWOHNERZ<-as.numeric(swiss_mun@data$EINWOHNERZ)
swiss_mun$density<-swiss_mun$EINWOHNERZ/(swiss_mun$GEM_FLAECH/100)

swiss_mun<-swiss_mun[-which(is.na(swiss_mun@data$density)),]

#-- making the distinction between rural residential and urban residential (rural: <10000 habitants OR density <100)

rur_res<-swiss_mun[swiss_mun$EINWOHNERZ < 10000 | swiss_mun$density <100,] # For rural residential


#### 2) Function to generate threat layers (crops, urban and rural residential)

threat_hab<-function(lulc,year){

timestart<-Sys.time()   
#-Crop threat layer

c1<- c(0,36,0, 
       36,41,1,
       41,100,0)
mc1<- matrix(c1,ncol = 3, byrow=TRUE)
crop<- reclassify(lulc, mc1)

cropname<-paste(year,"_crop_c.tif",sep="")
writeRaster(crop,paste(out_fold,cropname,sep="/"),overwrite=TRUE) # Export
print(paste(cropname," layer created",sep=""))

###-Rural residential

rur<-aggregate(rur_res)#dissolving polygon of rural areas
rur_lu<-raster::crop(lulc,rur)
rur_lulc<-mask(rur_lu,rur)

#-selecting residential areas 

r1<-c(1,14,1,
      14,100,0)

mr1<-matrix(r1, ncol= 3, byrow= TRUE)
rures<-reclassify(rur_lulc, mr1)
exp_rr<-reclassify(rures, cbind(NA, 0)) #filling gaps with 0 on entire extent

rrname<-paste(year,"_rures_c.tif",sep="")
writeRaster(exp_rr,paste(out_fold,rrname,sep="/"),overwrite=TRUE) # Export
print(paste(rrname," layer created",sep=""))
###-urban

outline<-aggregate(swiss_mun) #getting Switzerland blank canvas
urb_res<-raster::erase(outline, rur) #remove all rural residential areas, leaving us with urban residential

urb_lu<-raster::crop(lulc,urb_res)
urb_lulc<-mask(rur_lu,urb_res)

urbres<-reclassify(urb_lulc,mr1) #reclassify using same scheme as for rural residential
exp_ur<-reclassify(urbres, cbind(NA,0)) # filling gaps with 0 on all extent

urname<-paste(year, "_urban_c.tif",sep="")
writeRaster(exp_ur,paste(out_fold,urname,sep="/"),overwrite=TRUE) #Export
print(paste(urname," layer created"))
timestop<-Sys.time()
elapsed<-difftime(timestop,timestart, units= "mins")
print(paste("duration: ",elapsed[[1]]," mins",sep=""))

}


#### 3) Applying the function to desired time period. 

threat_hab(lulc97,"97")
threat_hab(lulc09,"09")
threat_hab(lulc18,"18")
