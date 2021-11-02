library(data.table)
library(tidyverse)
library(raster)
library(stars)
library(rgdal)
library(sf)
library(ggplot2)

wd<-"C:/Users/kuelling/Documents/VALPAR/ES Assessment/Annual water yield/Z_parameter"
setwd(wd)
scratch<- paste(wd, "scratch", sep="/")



####
list_st<-fread("C:/Users/kuelling/Documents/VALPAR/DATA/weather_stations/liste_stations.csv")
data<-fread("normes_climatologiques_81-2010.csv")

dem<- raster("C:\\Users\\kuelling\\Documents\\VALPAR\\DATA\\DEM(unil)\\DEM_mean_LV95.tif")
prodreg<- readOGR("C:\\Users\\kuelling\\Documents\\VALPAR\\DATA\\Swiss_Regions_SHP\\PRODREG.shp") #production regions from CH

sheds<-readOGR("C:/Users/kuelling/Documents/VALPAR/ES Assessment/Annual water yield/older/HADES/Medium_watershed/a0201_bilanzv1_0.shp")

####


#---- Creating a shapefile with each wheater station and corresponding number of days of rain (annual)
list_st$Z<-NA

for(i in 1:nrow(list_st)){
  a<-noquote(list_st$name[i])
  b<-grep(a,data$Station)
  if(length(b)==0){
    print(i)
    next
  }
  if(length(b)>1){
    print(a)
    x<- as.numeric(readline(paste("choose between \n 1.",data$Station[b[1]]," \n 2.",data$Station[b[2]],sep=" ")))
    b<-b[x]
  }
  else{
  list_st$Z[i]<-data$Ann.[b]}
}


st<-list_st[complete.cases(list_st$Z),]


st_shp<-st
coordinates(st_shp)=~chx+chy
proj4string(st_shp)<- CRS("+proj=somerc +lat_0=46.9524055555556 +lon_0=7.43958333333333 +k_0=1 +x_0=2600000 +y_0=1200000 +ellps=bessel +units=m +no_defs"
)

raster::shapefile(st_shp, "z_param.shp") # export

#--- comparing Z parameters for each watershed
#converting to actual Z parameter (*0.2)

st_shp$ndays<-st_shp$Z
st_shp$Z<-st_shp$Z*0.2

proj4string(st_shp)<- CRS("+proj=somerc +lat_0=46.9524055555556 +lon_0=7.43958333333333 +k_0=1 +x_0=2600000 +y_0=1200000 +ellps=bessel +units=m +no_defs")
proj4string(sheds)<- CRS("+proj=somerc +lat_0=46.9524055555556 +lon_0=7.43958333333333 +k_0=1 +x_0=2600000 +y_0=1200000 +ellps=bessel +units=m +no_defs")
points(st_shp)
a.data <- over(sheds, st_shp[,"Z"], fn="mean")

hist(a.data$Z)
range(a.data$Z, na.rm =TRUE)
mean(a.data$Z, na.rm =TRUE)
median(a.data$Z, na.rm =TRUE)
nshp<-sheds


#---plotting

# generate a unique ID for each polygon
nshp@data$seq_id <- seq(1:nrow(nshp@data))

# fortify the data
nshp@data$id <- rownames(nshp@data)# create a data.frame from our spatial object
nshpdata <- fortify(nshp, region = "id")# merge the "fortified" data with the data from our spatial object
nshp_df <- merge(nshpdata, nshp@data,
                   by = "id")

p0<-ggplot(data = nshp_df, aes(x=long, y = lat, group = group, fill = Z)) +
  geom_polygon()+
  geom_path(color = "white", size = 0.05)+
  coord_equal()+
  theme(panel.background = element_blank())+
  theme(panel.background = element_rect(color="black"))+
  theme(axis.title = element_blank(), axis.text= element_blank())+
  theme_bw()+
  labs(title= "Z parameter estimate by subwatershed")


 
png(paste(wd,"fig","subwsheds_Z.png", sep="/"),width = 1400, height = 1000)
p0 
dev.off()
