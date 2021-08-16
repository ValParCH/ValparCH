library(utils)
library(raster)
library(sp)

wd<-setwd("C:/Users/kuelling/Documents/VALPAR/DATA/LULC_DLT")
scratch<-paste(wd, "scratch", sep="/")
#-- AIM
# attributing a category to each "forest" LULC class, whether broadleaf or deciduous.
# When there is no overlap, attribute according to the elevation

#--Loading necessary variables

#LULC
lu<-raster("C:/Users/kuelling/Documents/VALPAR/DATA/UNIL_data/lulc/LULC_92-95_25.tif")
#DEM
dem<-DEM
#DLT (copernicus10m resampled)
dlt<-DLT_25 #1= deciduous, 2= coniferous



#--changing values of DLT file

# Lulc categories that can potentially be forest: 10,11,12,13,14,18,19
# those categories will be changed to either: deciduous trees or coniferous trees

m2 <- c(10,100,11,100,12,100,13,100,14,100,18,100,19,100)
recl_mat <-matrix(m2, ncol=2, byrow=TRUE)
lu_r<- reclassify(lu, recl_mat)

rasterVis::levelplot(dlt)

#now adding the value of the DLT map
# the value 10 becomes deciduous, the value 11 becomes coniferous
new_lu<- lu_r + dlt

m3 <- c(101,10, 102, 11)
recl_mat_2 <-matrix(m3, ncol=2, byrow=TRUE)
lu_dlt<- reclassify(new_lu, recl_mat_2)

# As the DLT map is from 2018, there are a few discrepancies regarding the LULC map. 
# Those pixels have the value "100", and i will attribute them as: 
# coniferous if >850m alt, otherwise deciduous

# reclassifying the DEM 

m4<-  c(0, 850, 10, 850, Inf, 11)
recl_mat_elev<-matrix(m4, ncol=3, byrow=TRUE)

dem_dlt<-reclassify(dem, recl_mat_elev)

# transforming lulc values that are == 100 as NA

m5<- c(100, NA)
recl_na <-matrix(m5, ncol=2, byrow=TRUE)
lu_dlt_2<- reclassify(lu_dlt, recl_na)

lu_dlt_3<- cover(lu_dlt_2, dem_dlt)

#--changing NA values from Lulc file

m <- c(200, Inf, NA)
n_mat <- matrix(m, ncol=3, byrow=TRUE)
lu_dlt_4 <- reclassify(lu_dlt_3, n_mat)

plot(lu_dlt_4)

#-- Export

writeRaster(lu_dlt_4, paste(scratch, "lu_dlt_test_2.tif",sep="/"))
