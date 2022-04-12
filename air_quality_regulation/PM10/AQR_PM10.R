library(raster)
library(utils)
library(sp)


#-- Paths

wd<-"C:/.../CODE"
setwd(wd)

flowfold<-"C:/.../FLOW"
supplyfold<-"C:/.../SUPPLY"

#-- Local variables 

#-LULC rasters

lulc97<- raster("C:/Users/.../LU-CH_1997.tif")#LULC raster
lulc09<- raster("C:/Users/.../LU-CH_2009.tif")#LULC raster
lulc18<- raster("C:/Users/.../LU-CH_2018.tif")#LULC raster

#-LAI layers

lai97<-readRDS("C:/Users/kuelling/Documents/VALPAR/DATA/copernicus/processed_data/LAI_mean_25_14-18.rds")
lai09<-readRDS("C:/Users/kuelling/Documents/VALPAR/DATA/copernicus/processed_data/LAI_mean_25_14-18.rds")
lai18<-readRDS("C:/.../LAI_mean_25_14-18.rds")

#-Pollution layers (pm10)(i chose modeled pm10 with 200m resolution, after discussing with data responsible)

pm10_97<-(raster("C:/.../pm10_mav98-01.tif")/10)
pm10_09<-(raster("C:/.../pm10_mav04-09.tif")/10)
pm10_18<-(raster("C:/.../pm10_mav13-18.tif")/10)

#-DLT layer #1= deciduous, 2= coniferous

DLT<-readRDS("C:/Users/.../DLT_25_18_LV95.rds")

#-DEM

dem<-readRDS("C:/Users/.../ch_topo_alti3d2016_pixel_dem_mean2m.rds")


###########################
#
# 
#
###########################


AQR_LULC_1<-function(lulc,year){
  
  lu<-lulc
  #-- setting the right extent
  
  lu<-extend(lu,DLT)
  
  #-- ensuring NAs are "0" in the lulc file: 
  m_lu<- c(NA,0)
  rcl<-matrix(m_lu, ncol=2, byrow=TRUE)
  lu<- reclassify(lu, rcl)
  
  #--changing values of DLT file (transforming "0" into NAs, changing 1 and 2 in 100 and 200)
  
  m_dl<- c(0,NA,
           1,100,
           2,200)
  rc<-matrix(m_dl, ncol=2, byrow=TRUE)
  dlt<- reclassify(DLT, rc)
  
  print("DLT map reclassified")
  #-- Lulc categories that represent a forest are changed to either deciduous or coniferous tree
  #- those categories are: 37, 38, 50:60 
  
  m2 <- c(36,38,NA,
          49,60,NA)
  recl_mat <-matrix(m2, ncol=3, byrow=TRUE)
  lu_r<- reclassify(lu, recl_mat)
  
  print("LULC map reclassified")
  #--Replacing created "NAs" by the corresponding value in DLT : 
  
  lu_r_d<- cover(lu_r, dlt)
  
  print("DLT added to LULC map")
  
  #-- As the DLT map is from 2018, there are a few discrepancies regarding the LULC map for different years. 
  #- Those pixels that are "forest" categories, are still "NA" right now., and i will attribute them as: 
  #- coniferous if >850m alt, otherwise deciduous
  
  m4<-  c(0, 850, 100, 850, Inf, 200)
  recl_mat_elev<-matrix(m4, ncol=3, byrow=TRUE)
  
  dem_dlt<-reclassify(dem, recl_mat_elev)
  
  print("DEM reclassified")
  #--Replacing "NA's" with the values of the DEM, that are converted to 100 and 200: 
  
  lu_r_e<- cover(lu_r_d, dem_dlt)
  
  print("LULC-DLT map filled with elevation data")
  #2)-- Generating needed categories: 
  #-i.coniferous forest
  #-ii.broadleaf forest
  #-iii.heath, peatland, grassland, cropland and other nature
  #-iiii.water and urban and infrastructure land covers.
  
  #i.coniferous forest
  
  c_v<-0
  m <- c(-Inf,150,NA,
         150,200,c_v)
  n_mat <- matrix(m, ncol=3, byrow=TRUE)
  coniferous <- reclassify(lu_r_e, n_mat)
  
  #ii. broadleaf forest
  
  c_v<-0
  m <- c(-Inf,99,NA,
         99,100,c_v,
         100,200,NA)
  n_mat <- matrix(m, ncol=3, byrow=TRUE)
  broadleaf <- reclassify(lu_r_e, n_mat)
  print("layer created:")
  print("broadleaf")
  #iii. heath, peatland, grassland, cropland and other nature
  #chosen categories (from lulc map):
  
  c_v<-0 #Value chosen for this cat. 
  m <- c(-Inf,15,NA,
         15,16,c_v,
         16,17,NA,
         17,18,c_v,
         18,30,NA,
         30,31,c_v,
         31,32,NA,
         32,33,c_v,
         33,38,NA,
         38,39,c_v,
         39,40,NA,
         40,49,c_v,
         49,63,NA,
         63,65,c_v,
         65,66,NA,
         66,67,c_v,
         67,Inf,NA) 
  n_mat <- matrix(m, ncol=3, byrow=TRUE)
  lowveg <- reclassify(lu_r_e, n_mat)
  print("low vegetation")
  #iiii.water and urban and infrastructure land covers = all the rest = 0 
  
  c_o<-0 #Value chosen for this cat. 
  m <- c(-Inf,0,NA,
         0,15,c_o,
         15,16,NA,
         16,17,c_o,
         17,18,NA,
         18,30,c_o,
         30,31,NA,
         31,32,c_o,
         32,33,NA,
         33,36,c_o,
         36,39,NA,
         39,40,c_o,
         40,60,NA,
         60,63,c_o,
         63,65,NA,
         65,66,c_o,
         66,67,NA,
         67,72,c_o,
         72,Inf,NA)
         
  o_mat <- matrix(m, ncol=3, byrow=TRUE)
  others <- reclassify(lu_r_e, o_mat)
  print("others (urban)")
  #--Pollutants dry deposition velocities(from Remme et al. 2014, powe & willis 2004), in m/s
  
  coni<- 0.0080
  broad<- 0.0032
  nat<- 0.0010
  
  #Loading correct LAI and pollution maps
  
  lai<-get(paste("lai",year,sep=""))
  pm10_25<-get(paste("pm10_",year,sep=""))
  
  
  #- correcting pm10 extent
  
  pm10_25<-extend(pm10_25, extent(lai))
  
  #-- coniferous
  
  AQR_con_F<-pm10_25 * coni * lai * 1 * 0.5
  AQR_con<-AQR_con_F + coniferous
  
  print("AQR coniferous: done")
  
  #-- Broadleaf
  
  AQR_br_F<-pm10_25 * broad * lai * 1 * 0.5
  AQR_br<-AQR_br_F + broadleaf
  
  print("AQR broadleaf: done")
  #--Other nature
  
  AQR_nat_F<-pm10_25 * nat * lai * 1 * 0.5
  AQR_nat<-AQR_nat_F + lowveg
  
  print("AQR other (urban): done")
  # Binding them together (/!/ order-sensitive) 
  
  AQR<-merge(AQR_con, AQR_br, AQR_nat, others, overlap = TRUE)
  
  print("layer merged")
  
  #--> AQR in ug/m^2
  
  # Changing values to an index
  
  AQR_index<-(AQR * 1) / max(values(AQR), na.rm = T)
  
  exname<-paste("AQR_F_CH_",year,".tif",sep="")
  exname_ind<-paste("AQR_F_CH_",year,"_index.tif",sep="")
  
  writeRaster(AQR,paste(flowfold,year,exname,sep="/"), overwrite=TRUE)
  writeRaster(AQR_index,paste(flowfold,year,exname_ind,sep="/"), overwrite=TRUE)
  
  print("export flow done")
  return(AQR)
}

ludlt18<-AQR_LULC_1(lulc18,"18")
