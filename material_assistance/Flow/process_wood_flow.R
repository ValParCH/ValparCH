library(sf)
library(raster)
library(rgdal)
library(pxR)

wd<-"C:/Users/kuelling/Documents/VALPAR/ES Assessment/material_assistance/wood_flow"
setwd(wd)



#--- Define scratch and result workspace

scratch<- paste(wd,"scratch",sep="/")
dir.create(paste(scratch,"lulc_clip",sep="/"))
result<- paste(wd,"results", sep="/")


#--- Loading local variables

# for part 1: 
prodreg<- readOGR("C:\\Users\\kuelling\\Documents\\VALPAR\\DATA\\Swiss_Regions_SHP\\PRODREG.shp") #production regions from CH
lulc<- raster("C:\\Users\\kuelling\\Documents\\VALPAR\\DATA\\UNIL_data\\lulc\\LULC_92-95_25.tif")#LULC raster
cantons<- readOGR("C:\\Users\\kuelling\\Documents\\VALPAR\\DATA\\Swiss boundaries\\swissBOUNDARIES3D_1_3_TLM_KANTONSGEBIET.shp") #cantons boundaries

# for part 2:

pt<- "C:/Users/kuelling/Documents/VALPAR/DATA/forestry_CH" #BNS forestry file, ref "px-x-0703010000_102.px", wood harvest in m^3


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
reg_cant@data$reg_cant_n[i]<-paste(reg_cant@data$ProdregN_1[i], reg_cant@data$KANTONSNUM[i], sep="_")
}

reg_cant@data$reg_cant_n<- gsub("Ã©", "e", reg_cant@data$reg_cant_n) # removing weird accents
reg_cant@data$reg_cant_n<- gsub(" ", "", reg_cant@data$reg_cant_n) # removing tabs


#--- clipping lulc raster to each production region and canton

list_reg_cant<-data.frame(unique(reg_cant@data$reg_cant_n))


for(i in 1:nrow(list_reg_cant)){
  
  name<-list_reg_cant$unique.reg_cant.data.reg_cant_n.[i]
  a<-reg_cant[reg_cant$reg_cant_n == name,]
  b<-crop(lulc,a)
  c<-mask(b,a)
  
  writeRaster(c,paste(scratch,"lulc_clip",paste(name,".tif",sep=""),sep="/"))
  print(paste("raster", name,"created", i, "/",length(unique(reg_cant@data$reg_cant_n)),sep =" "))
}



################################################################################
#### ---- Part 2: Extracting values of wood harvest from Statistical office data
################################################################################


#--- Import px file (needs some adjustement due to format)

file<-"px-x-0703010000_102.px"

#Read in file and convert encoding
x <- iconv(readLines(paste(pt, file, sep="/"), encoding="CP1252 "), from="CP1252 ", to="Latin1", sub="")

#Replace missings to workaround a bug in pxR.
x <- gsub("\"......\"", "\"....\"", x, fixed = TRUE)
x <- gsub("\".....\"", "\"....\"", x, fixed = TRUE)

#Write the file with the changes
fileConn<-file(paste(pt, file, sep="/"))
writeLines(x, con=fileConn, useBytes = TRUE)
close(fileConn)

data = read.px(paste(pt,file,sep="/"), na.strings = c('"."','".."','"..."','"...."','"....."','"....."','":"'))
table= as.data.frame(data, use.codes = TRUE) # use.codes = F to see the names (in DE)
names(table) <- c("observation_unit", "wood_sp_group","owner_type","canton", "forest_zone","year","value")

table2= as.data.frame(data, use.codes = FALSE) # use.codes = F to see the names (in DE)
list_cantons<- unique(table2$Kanton)


#--- Get cantonal values for year 92-97

# setting the data frame by keeping only useful values

subs<- subset(table, table$year == "1992" | table$year == "1993" | table$year == "1994" | table$year == "1995" | table$year == "1996" | table$year == "1997")
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
  
  namext<-paste(name,".tif",sep="")
  rast<-raster(paste(wd,"process","scratch","rasters",namext,sep="/"))
  area_siz<-tapply(area(rast), rast[], sum)
  
  wood_surface<-sum(area_siz[c("9","10","11","13","14","18","19")],na.rm=TRUE)
  val<-(val_prod*625)/wood_surface
  
  list1<-c(10,val,11,val,13,val,14,val,18,val,19,val,9,val,12,0,15,0,16,0,48,0,81,0,82,0,86,0,96,0,71,0,72,0,73,0,75,0,76,0,78,0,87,0,89,0,97,0,91,0,92,0,95,0,31,0,33,0,34,0,35,0,36,0,37,0,38,0,41,0,61,0,62,0,63,0,64,0,65,0,66,0,45,0,46,0,47,0,49,0,51,0,52,0,53,0,54,0,56,0,67,0,68,0,59,0,90,0,99,0,83,0,84,0,85,0,88,0)
  mat<- matrix(list1,ncol = 2, byrow=TRUE)
  
  newrast<-reclassify(rast,mat)
  
  exp_name<-paste(name,"reclass",sep="_")
  writeRaster(newrast,(paste(wd,"rast_recl",exp_name, sep="/")), format="GTiff")
  
  
  print(paste(exp_name, "done",sep=" "))
  print(paste("process done at ", round((i*100)/nrow(output_tab)),"%"))
  
  
}


#-----Creating an empty raster layer before merging all datasets

bind<-raster()
crs(bind)<-"+proj=somerc +lat_0=46.9524055555556 +lon_0=7.43958333333333 +k_0=1 +x_0=2600000 +y_0=1200000 +ellps=bessel +units=m +no_defs"
extent(bind)<-c(2480000, 2840000, 1070000, 1300000)
res(bind)<-25
origin(bind)<-0

#------Merging of all raster datasets using mosaic

for(i in 1:nrow(output_tab)){
  name<-output_tab$cant_reg[i]
  imp_name<-paste(name,"reclass",sep="_")
  imp_name<-paste(imp_name,".tif",sep="")
  nr<-raster(paste(wd,"rast_recl",imp_name,sep="/"))
  
  bind<-mosaic(bind,nr,fun=mean,tolerance=0.05)
  print(paste(imp_name, " added"))
  print(paste("process done at ", round((i*100)/nrow(output_tab)),"%"))
}

thecrs<-sp::CRS('+init=epsg:2056')
crs(bind)<- thecrs

writeRaster(bind,(paste(wd,"results","Wood_harvest_92-97", sep="/")), format="GTiff",overwrite = TRUE)

#----translating to an index:

bind_ind<- bind/maxValue(bind)
writeRaster(bind_ind,(paste(wd,"results","Wood_harvest_92-97_index", sep="/")), format="GTiff",overwrite = TRUE)
