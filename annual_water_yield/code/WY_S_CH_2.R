library(raster)

#-------------
# This piece of code is solely to divide the invest wateryield output value by 10 to obtain actual mm/year
# values, and then export it to the right folder.
#-------------

wd<-"C:/Users/..."
setwd(wd)

fold<-"C:/Users/..."

proc<-function(year){
  
  name<-paste("wyield_",year,".tif",sep="")
  
  a<-raster(paste(wd,"INVEST",year,"output","per_pixel",name,sep="/"))
  a<-a/10

  name2<-paste("WY_S_CH_",year,".tif",sep="")
  path<-paste(fold,year,name2,sep="/")

  writeRaster(a,path)
  
  return(a)
}


wy_97<-proc("97")
wy_09<-proc("09")
wy_18<-proc("18")
