wd<-setwd("C:/Users/kuelling/Documents/VALPAR/ES Assessment/Air quality regulation/AQR")

#-- Local variables (some rds files)

pm10<-raster("C:/Users/.../pm10_2015_20m_modeled.tif")
lai<-LAI_mean
#forest<-DLT_25_18 #1= deciduous, 2= coniferous, this is no longer used as coniferous/broadleaf are integrated in Lulc classes (see data processing_LULC script)
lulc<-raster("C:/Users/...LULC_92-97_DLT.tif")

template<-lulc
#-- Result folder

output<- paste(wd, "result", sep="/")

#-- Resampling pollutant raster

pm10_25<-resample(pm10, template)

#1)-- Generating needed categories: 
#-i.coniferous forest
#-ii.broadleaf forest
#-iii.heath, peatland, grassland, cropland and other nature
#-iiii.water and urban and infrastructure land covers.

#i.coniferous forest

c_v<-0
m <- c(1,NA,2,c_v,10,NA,11,NA,13,NA,14,NA,18,NA,19,NA,9,NA,12,NA,15,NA,16,NA,48,NA,81,NA,82,NA,86,NA,96,NA,71,NA,72,NA,73,NA,75,NA,76,NA,78,NA,87,NA,89,NA,97,NA,91,NA,92,NA,95,NA,31,NA,33,NA,34,NA,35,NA,36,NA,37,NA,38,NA,41,NA,61,NA,62,NA,63,NA,64,NA,65,NA,66,NA,45,NA,46,NA,47,NA,49,NA,51,NA,52,NA,53,NA,54,NA,56,NA,67,NA,68,NA,59,NA,90,NA,99,NA,83,NA,84,NA,85,NA,88,NA,255,NA)
n_mat <- matrix(m, ncol=2, byrow=TRUE)
coniferous <- reclassify(lulc, n_mat)

#ii. broadleaf forest

c_v<-0
m <- c(1,c_v,2,NA,10,NA,11,NA,13,NA,14,NA,18,NA,19,NA,9,NA,12,NA,15,NA,16,NA,48,NA,81,NA,82,NA,86,NA,96,NA,71,NA,72,NA,73,NA,75,NA,76,NA,78,NA,87,NA,89,NA,97,NA,91,NA,92,NA,95,NA,31,NA,33,NA,34,NA,35,NA,36,NA,37,NA,38,NA,41,NA,61,NA,62,NA,63,NA,64,NA,65,NA,66,NA,45,NA,46,NA,47,NA,49,NA,51,NA,52,NA,53,NA,54,NA,56,NA,67,NA,68,NA,59,NA,90,NA,99,NA,83,NA,84,NA,85,NA,88,NA,255,NA)
n_mat <- matrix(m, ncol=2, byrow=TRUE)
broadleaf <- reclassify(lulc, n_mat)

#iii. heath, peatland, grassland, cropland and other nature
#chosen categories (from lulc map): 9,15,16,18,59,67,68,71,71,73,81,82,83,84,85,86,87,88,89,95,96,97

c_v<-0 #Value chosen for this cat. 
m <- c(1,NA,2,NA,10,NA,11,NA,13,NA,14,NA,18,c_v,19,NA,9,c_v,12,NA,15,c_v,16,c_v,48,NA,81,c_v,82,c_v,86,c_v,96,c_v,71,c_v,72,c_v,73,c_v,75,NA,76,NA,78,NA,87,c_v,89,NA,97,c_v,91,NA,92,NA,95,c_v,31,NA,33,NA,34,NA,35,NA,36,NA,37,NA,38,NA,41,NA,61,NA,62,NA,63,NA,64,NA,65,NA,66,NA,45,NA,46,NA,47,NA,49,NA,51,NA,52,NA,53,NA,54,NA,56,NA,67,c_v,68,c_v,59,c_v,90,NA,99,NA,83,c_v,84,c_v,85,c_v,88,c_v,255,NA)
n_mat <- matrix(m, ncol=2, byrow=TRUE)
lowveg <- reclassify(lulc, n_mat)

#iiii.water and urban and infrastructure land covers = all the rest = 0 

c_o<-0 #Value chosen for this cat. 
m <- c(1,NA,2,NA,10,c_o,11,c_o,13,c_o,14,c_o,18,NA,19,c_o,9,NA,12,c_o,15,NA,16,NA,48,c_o,81,NA,82,NA,86,NA,96,NA,71,NA,72,NA,73,NA,75,c_o,76,c_o,78,c_o,87,NA,89,c_o,97,NA,91,c_o,92,c_o,95,NA,31,c_o,33,c_o,34,c_o,35,c_o,36,c_o,37,c_o,38,c_o,41,c_o,61,c_o,62,c_o,63,c_o,64,c_o,65,c_o,66,c_o,45,c_o,46,c_o,47,c_o,49,c_o,51,c_o,52,c_o,53,c_o,54,c_o,56,c_o,67,NA,68,NA,59,NA,90,c_o,99,c_o,83,NA,84,NA,85,NA,88,NA,255,NA)
o_mat <- matrix(m, ncol=2, byrow=TRUE)
others <- reclassify(lulc, o_mat)

#--Pollutants dry deposition velocities(from Remme et al. 2014, powe & willis 2004), in m/s

coni<- 0.0080
broad<- 0.0032
nat<- 0.0010

#applying formula

#-- coniferous

AQR_con_F<-pm10_25 * coni * lai * 1 * 0.5
AQR_con<-AQR_con_F + coniferous

#-- Broadleaf

AQR_br_F<-pm10_25 * broad * lai * 1 * 0.5
AQR_br<-AQR_br_F + broadleaf

#--Other nature

AQR_nat_F<-pm10_25 * nat * lai * 1 * 0.5
AQR_nat<-AQR_nat_F + lowveg

# Binding them together (/!/ order-sensitive) 

AQR<-merge(AQR_con, AQR_br, AQR_nat, others, overlap = TRUE)
#--> AQR in ug/m^2

# Changing values to an index

AQR_index<-(AQR * 1) / max(values(AQR), na.rm = T)


#---- Export

writeRaster(AQR_index, paste(output,"AQR_CH_LULC_92_index.tif",sep="/"))
writeRaster(AQR, paste(output,"AQR_CH_LULC_92.tif",sep="/"))

saveRDS(dlt, file = paste(output,"DLT_25_18_LV95.rds",sep="/"))



