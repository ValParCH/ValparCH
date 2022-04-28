library(sf)
library(raster)
library(rgdal)
library(pxR)

wd<-"C:/Users/...CODE"
setwd(wd)

#--local paths
scratch<- paste(getwd(), "scratch",sep="/")
#dir.create(paste(scratch,"lulc_clip_f",sep="/"))
#dir.create(paste(scratch,"rast_reclass_f",sep="/"))
result<- "C:/Users/.../FLOW"

#--local variables

prodreg<- readOGR("C:\\Users\\...\\PRODREG.shp") #production regions from CH
cantons<- readOGR("C:\\Users\\...\\swissBOUNDARIES3D_1_3_TLM_KANTONSGEBIET.shp") #cantons boundaries
slope<- readRDS("C:/Users/.../ch_topo_alti3d2016_pixel_slope_mean2m.rds")

lulc97<- raster("C:/Users/.../LU-CH_1997.tif")#LULC raster
lulc09<- raster("C:/Users/.../LU-CH_2009.tif")#LULC raster
lulc18<- raster("C:/Users/.../LU-CH_2018.tif")#LULC raster

pt<- "C:/Users/.../forestry_CH" #BNS forestry file, ref "px-x-0703010000_102.px", wood harvest in m^3

# Function that processes all input files and generates output raster maps.

mat_f<-function(lulc,year){
  
####################################################################################
#### ---- Part 1: creating separated raster files corresponding to production region
####################################################################################

#--- Overlay of cantons and production regions, creating new shapfile

reg_cant<-intersect(prodreg, cantons)

#--- Process: processing of attribute table
# i.    Creating a new column reg_cant table(reg_cant_n), containing Region + canton number
# ii.   Filling the new column with concatenation of Region + canton
# iii.  remove accents

for(i in 1:nrow(reg_cant@data)){
  reg_cant@data$reg_cant_n[i]<-paste(reg_cant@data$ProdregN_1[i], reg_cant@data$KANTONSNUM[i], sep="")
}

#Check that symbols have not changed (happens when not saved in utf-8)

reg_cant@data$reg_cant_n<- gsub("Ã©", "e", reg_cant@data$reg_cant_n) # removing weird accents
reg_cant@data$reg_cant_n<- gsub(" ", "", reg_cant@data$reg_cant_n) # removing tabs

#--- combining lulc and slope raster, to later keep only forests that arent on slope too steep


#- reclassifying slope pixels that are in a slope < 110%  (47 degree) (Dupire et al. 2015)

l_m <- c(0,47, 0,    #Too steep= value of 1000, ok= Value of 0
         47,Inf,1000)
mat_s <- matrix(l_m,ncol = 3, byrow=TRUE)
s_prac<-reclassify(slope, mat_s)

lulc<-lulc+s_prac #adding to the lulc raster


#--- clipping lulc raster to each production region and canton

list_reg_cant<-data.frame(unique(reg_cant@data$reg_cant_n))

print("generating lulc clips")
for(i in 1:nrow(list_reg_cant)){
  
  name<-list_reg_cant$unique.reg_cant.data.reg_cant_n.[i]
  a<-reg_cant[reg_cant$reg_cant_n == name,]
  b<-crop(lulc,a)
  c<-mask(b,a)
  
  name2<-paste(year,name,sep="_")
  
  saveRDS(readAll(c),paste(scratch,"lulc_clip_f",paste(name2,".rds",sep=""),sep="/"))
  print(paste("raster", name,"created", i, "/",length(unique(reg_cant@data$reg_cant_n)),sep =" "))
}


################################################################################
#### ---- Part 2: Extracting values of wood harvest from Statistical office data
################################################################################


#--- Import px file (needs some adjustement due to format)

file<-"px-x-0703010000_102.px"

###-- adjustments only need to be done once on original file
#Read in file and convert encoding
#x <- iconv(readLines(paste(pt, file, sep="/"), encoding="UTF-8"), from="UTF-8", to="Latin1", sub="")

#Replace missings to workaround a bug in pxR.
#x <- gsub("\"......\"", "\"....\"", x, fixed = TRUE)
#x <- gsub("\".....\"", "\"....\"", x, fixed = TRUE)

#Write the file with the changes
#fileConn<-file(paste(pt, file, sep="/"))
#writeLines(x, con=fileConn, useBytes = TRUE)
#close(fileConn)


data = read.px(paste(pt,file,sep="/"), na.strings = c('"."','".."','"..."','"...."','"....."','"....."','":"'))
table= as.data.frame(data, use.codes = TRUE) # use.codes = F to see the names (in DE)
names(table) <- c("observation_unit", "wood_sp_group","owner_type","canton", "forest_zone","year","value")

table2= as.data.frame(data, use.codes = FALSE) # use.codes = F to see the names (in DE)
list_cantons<- unique(table2$Kanton)

print("OFS data imported")
#--- Get cantonal values for wished year

# setting the data frame by keeping only useful values


if(year=="97"){a<-"1992"; b<-"1993"; c<-"1994"; d<-"1995"; e<-"1996"; f<-"1997"; print("year selected: 97")}
if(year=="09"){a<-"2004"; b<-"2005"; c<-"2006"; d<-"2007"; e<-"2008"; f<-"2009"; print("year selected: 09")}
if(year=="18"){a<-"2013"; b<-"2014"; c<-"2015"; d<-"2016"; e<-"2017"; f<-"2018"; print("year selected: 18")}
              

subs<- subset(table, table$year == a | table$year == b | table$year == c | table$year == d | table$year == e | table$year == f)
subs<- subset(subs, subs$owner_type == 0)# meaning both private and public
subs<- subset(subs, subs$wood_sp_group == 0) # meaning both deciduous and coniferous
subs<- subset(subs, subs$observation_unit == "_1" | subs$observation_unit == "_2")#wood for timber or industry (not energy)
subs<- subset(subs, subs$canton != 0) # "0" means all switzerland, so we remove it (redundant)
subs<- subset(subs, subs$forest_zone != 0) # "0" means all switzerland, so we remove it


# creating and empty data frame with a row per canton

cant<-c(1:26)
prod_reg1<-NA
prod_reg2<-NA
prod_reg3<-NA
prod_reg4<-NA
prod_reg5<-NA
tot_prod<-NA

ndf<-data.frame(cant,prod_reg1,prod_reg2, prod_reg3, prod_reg4, prod_reg5, tot_prod)

#--summing values of wood harvest for each canton for each production region

for(i in 1:nrow(ndf)){
  a<-ndf$cant[i]
  b<-subset(subs, subs$canton == a) 
  b$sum<-NA
  reg1<-subset(b, b$forest_zone == 1)
  reg2<-subset(b, b$forest_zone == 2)
  reg3<-subset(b, b$forest_zone == 3)
  reg4<-subset(b, b$forest_zone == 4)
  reg5<-subset(b, b$forest_zone == 5)
  ndf$prod_reg1[i]<- sum(reg1$value)/(nrow(reg1)/2)
  ndf$prod_reg2[i]<- sum(reg2$value)/(nrow(reg2)/2)
  ndf$prod_reg3[i]<- sum(reg3$value)/(nrow(reg3)/2)
  ndf$prod_reg4[i]<- sum(reg4$value)/(nrow(reg4)/2)
  ndf$prod_reg5[i]<- sum(reg5$value)/(nrow(reg5)/2)
  
  ndf$tot_prod[i]<- rowSums(ndf[i,2:6], na.rm=TRUE)
}


#---Creating a new df with 3 columns, and one row per Canton/prodreg/value of wood

colnames(ndf)<- c("cant", "jura", "plateau", "prealpes", "alpes", "suddesalpes", "tot_prod")
cantProd<-c("Jura", "Plateau", "Prealpes", "Alpes", "SuddesAlpes")
cant<-c(1:26)
prodreg<-NA
value<-NA
new_df<-data.frame(expand.grid(cantProd, cant))
new_df$value<-NA
colnames(new_df)<-c("prodreg", "cant", "value")

#--- Filling the wood values
print("retrieving wood values")
for(i in 1:nrow(ndf)){
  a<- subset(ndf, ndf$cant == i)
  for(ii in 1:nrow(new_df)){
    if(new_df$cant[ii] == a$cant & new_df$prodreg[ii] == "Jura"){ new_df$value[ii]<- a$jura}
    if(new_df$cant[ii] == a$cant & new_df$prodreg[ii] == "Plateau"){ new_df$value[ii]<- a$plateau}
    if(new_df$cant[ii] == a$cant & new_df$prodreg[ii] == "Prealpes"){ new_df$value[ii]<- a$prealpes}
    if(new_df$cant[ii] == a$cant & new_df$prodreg[ii] == "Alpes"){ new_df$value[ii]<- a$alpes}
    if(new_df$cant[ii] == a$cant & new_df$prodreg[ii] == "SuddesAlpes"){ new_df$value[ii]<- a$suddesalpes
    }
  }
}

#Remove NAs
output_tab<-na.omit(new_df)
output_tab<-subset(output_tab,output_tab$value!=0)
output_tab$cant_reg<-NA #creating a tag column
for(i in 1:nrow(output_tab)){output_tab$cant_reg[i]<-paste(output_tab$prodreg[i], output_tab$cant[i], sep= "")}


################################################################################
#### ---- Part 3: Attributing to each raster layer and forest category the corresponding wood value, weighed
################################################################################
#### /!!!!!!!\ we give all forest pixel a divided value of production. this is a very rough spatial approximation 



for(i in 1:nrow(output_tab)){
  
  
  name<-output_tab$cant_reg[i]
  val_prod<-output_tab$value[i]
  
  print(paste(name, ", wood qtity (m^3):", val_prod,sep=" "))
  
  namext<-paste(year,"_",name,".rds",sep="")
  rast<-readRDS(paste(wd,"scratch","lulc_clip_f",namext,sep="/"))
  area_siz<-tapply(area(rast), rast[], sum)
  
  wood_surface<-sum(area_siz[c("50","51","52","53","54","55","58","59")],na.rm=TRUE)
  val<-(val_prod*625)/wood_surface
  
  list0<-c(0,49,0,
           49,55,val,
           55,57,0,
           57,59,val,
           59,Inf, 0)
  mat0<- matrix(list0, ncol= 3, byrow= TRUE)
  newrast0<-reclassify(rast,mat0)

  exp_name<-paste(year,"_",name,"_reclass.rds",sep="")
  saveRDS(readAll(newrast0),(paste(scratch,"rast_reclass_f",exp_name, sep="/")))
  
  print(paste(exp_name, "done",sep=" "))
  print(paste("process done at ", round((i*100)/nrow(output_tab)),"%"))
  
  
}

print("lulc maps filled with wood values")


#------Merging of all raster datasets using mosaic
#Reading each file related to the corresponding year

print("generating mosaic raster")

ts = list.files(paste(scratch,"rast_reclass_f",sep="/"),paste("^",year,"_",sep=""))

dat_list = lapply(ts, function (x)readRDS(paste(scratch,"rast_reclass_f",x,sep="/")))
dat_list$fun<-mean

bind <- do.call(mosaic, dat_list) 

w_extent<-c(2480000, 2840000, 1070000, 1300000)
bind<-extend(bind,w_extent)

print("mosaic raster done")

thecrs<-sp::CRS('+init=epsg:2056')
crs(bind)<- thecrs

expname<-paste("MAT_F_CH_",year,".tif",sep="")
expname_ind<-paste("MAT_F_CH_",year,"_index.tif",sep="")

writeRaster(bind,(paste(result,year,expname, sep="/")), format="GTiff",overwrite = TRUE)

print("raster absolute values exported")
#----translating to an index:

bind_ind<- bind/maxValue(bind)
writeRaster(bind_ind,(paste(result,year,expname_ind, sep="/")), format="GTiff",overwrite = TRUE)
print("raster index exported")

}


mat_f(lulc97,"97")
mat_f(lulc09,"09")
mat_f(lulc18,"18")
