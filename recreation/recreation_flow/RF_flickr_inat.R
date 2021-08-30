wd<-setwd("C:/Users/...")
library(data.table)
library(raster)
library(rgdal)
library(dismo)
library(sp)
library(sf)
library(ade4)
library(factoextra)
library(caret)
library(corrplot)
library(MASS)

if (!require("rspatial")) devtools::install_github('rspatial/rspatial')
library(rspatial)

###---- loading variables
#Path to data
datad<-"C:/Users/datapath"
temp<- readRDS(paste(datad,"bioclim25/06-15/mean_temp_annual/ch_bioclim_chclim25_present_pixel_2006-2015_bio1.rds",sep="/"))
rain<- readRDS(paste(datad,"bioclim25/06-15/mean_rain_annual/ch_bioclim_chclim25_present_pixel_2006-2015_bio12.rds",sep="/"))
slope<- readRDS(paste(datad,"slope_mean/ch_topo_alti3d2016_pixel_slope_mean2m.rds",sep="/"))
dem<- readRDS(paste(datad,"dem/ch_topo_alti3d2016_pixel_dem_mean2m.rds",sep="/"))
pop<- readRDS(paste(datad,"pop/ch_popdensity_statpop13_pixel_populationdensity.rds",sep="/"))
wsl<- readRDS(paste(datad,"wsl/CH_lulc_wsl_pixel_wsl_nfi.rds",sep="/"))

agri<- readRDS(paste(datad,"lulc","aggr","ch_lulc_geostat_present_pixel_1992-1997_agriaggr_25.rds",sep="/"))
fore<- readRDS(paste(datad,"lulc","aggr","ch_lulc_geostat_present_pixel_1992-1997_forestaggr_25.rds",sep="/"))
hydr<- readRDS(paste(datad,"lulc","aggr","ch_lulc_geostat_present_pixel_1992-1997_hydroaggr_25.rds",sep="/"))
lowv<- readRDS(paste(datad,"lulc","aggr","ch_lulc_geostat_present_pixel_1992-1997_lowvegaggr_25.rds",sep="/"))
settl<- readRDS(paste(datad,"lulc","aggr","ch_lulc_geostat_present_pixel_1992-1997_seuramaggr_25.rds",sep="/"))

access<- "C:/Users/.../accessibility_crs.tif"
hetero<- "C:/Users/.../ls_hetereogeneity_CH_25m.tif"
rugg<- "C:/Users/.../TerrainRuggednessIndex/TRI_25m_CH.tif"
paths<- "C:/Users/.../dist_path_16.tif"
roads<- "C:/Users/.../dist_road_25.tif"


path<- raster(paths); crs(path)<-crs(tri); extent(path)<-extent(tri)
acc<- raster(access)
het<- raster(hetero)
tri<- raster(rugg)
road<- raster(roads)


#--Preparing the explanatory variables raster stack

predictors<-stack(temp,rain,slope,dem,pop,wsl,path,acc, het,tri,road,agri,fore,hydr,lowv,settl)
names(predictors)<- c("temp", "rain", "slope","dem", "pop", "wsl","path","acc","het","tri","road","agri","fore","hydr","lowv","settl")

#--observations 

#Flickr data
obs<-fread("flickr_un_keyword_06-21.csv")
obs<-na.omit(obs)
obs<-obs[,c(3,4)]

coordinates(obs) <- c("longitude", "latitude")
proj4string(obs) <- CRS("+init=epsg:4326")
obs2<- spTransform(obs, CRS("+init=epsg:2056"))
obs3<-data.frame(obs2)
obs<-obs3

# Inaturalist data
inat<-"C:/Users/.../Inaturalist"

plants<-fread(paste(inat,"export_plants_CH","plants_CH.csv", sep= "/"))
vert<-fread(paste(inat,"export_vertebrates_CH","vertebrates_ch.csv", sep= "/"))
birds<- fread(paste(inat,"export_birds_fish_CH","birds_fish_CH.csv", sep= "/"))

vert<-vert[-which(duplicated(vert$user_id)),]
plants<-plants[-which(duplicated(plants$user_id)),]
birds<-birds[-which(duplicated(birds$user_id))]

obs_inat<-rbind(vert,plants,birds)
obs_inat<-obs_inat[,c(22,23)]

coordinates(obs_inat) <- c("longitude", "latitude")
proj4string(obs_inat) <- CRS("+init=epsg:4326")
obs2<- spTransform(obs_inat, CRS("+init=epsg:2056"))
obs_inat<-data.frame(obs2)

# Merging Inaturalist and flickr data
obs<-rbind(obs,obs_inat)

#-------

#Run only for testing with smaller extent (e.g. here: Park gruyère pays d'Enhaut extent
#gp<-"C:/Users/.../Gruyere_enhaut.shp"
#gph<-st_read(gp)
#pred<-crop(predictors,gph)


# Extracting values of observation points
pred<-predictors # for swiss modelling
bfc <- extract(pred, obs)
bfc<-na.omit(bfc)
colnames(bfc)<-c("temp", "rain", "slope","dem", "pop", "wsl","path","acc","het","tri","road","agri","fore","hydr","lowv","settl")

# generating background points

e <- extent(SpatialPoints(obs[, 1:2]))
#e <- extent(gph) # to use for gph testing
set.seed(0)
bg <- sampleRandom(pred, 10000, ext=e)
dim(bg)

d <- rbind(cbind(pa=1, bfc), cbind(pa=0, bg))
d <- data.frame(d)
dim(d)

#-- Looking at variables correlations

#pca
pca<- dudi.pca(df = d, scannf = FALSE, nf = 5)
fviz_eig(pca) # Scree plot
#correlation circle
fviz_pca_var(pca,
             col.var = "contrib", 
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE     
)

#correlogram

M<-cor(d)
corrplot(M, method="circle", type= "upper")
corrplot(M, method="number", type= "upper")

# remove one of each variables with >0.8 correlation

#slope, temp
d<-d[,-c(2,4)]
pred<- dropLayer(pred, c(1,3))

# dividing in training and testing sets (80/20) (for first run of model)

k <- 5
group <- kfold(d, k)
group[1:10]

unique(group)

e <- list()
for (i in 1:k) {
  train <- d[group != i,] # training set
  test <- d[group == i,] # testing set
}


# - Fitting cart model
library(rpart)
cart <- rpart(pa~., data=d)
printcp(cart)
plotcp(cart)

plot(cart, uniform=TRUE, main="Regression Tree")
#text(cart, use.n=TRUE, all=TRUE, cex=.8)
text(cart, cex=.8, digits=1)


#---- fitting random forest

library(randomForest)

#--classification
fpa <- as.factor(train[, 'pa'])
crf <- randomForest(train[, 2:ncol(train)], fpa)
crf
plot(crf)
varImpPlot(crf)

#--regression

k <- 5
group <- kfold(d, k)
group[1:10]

unique(group)
rf_list<-NA

e <- list()
for (i in 1:k) {
  train <- d[group != i,] # training set
  test <- d[group == i,] # testing set
  
  rrf <- tuneRF(train[, 2:ncol(train)], train[, 'pa'])
  mt <- trf[which.min(trf[,2]), 1]
  rrf <- randomForest(train[, 2:ncol(train)], train[, 'pa'], mtry=mt)
  
  tag<-paste("rrf",i,sep="_")
  assign(tag,rrf)
  rf_list[i]<-tag
  
  e[[i]] <- evaluate(test[test$pa==1, ], test[test$pa==0, ], rrf)
}


plot(rrf)
varImpPlot(rrf)

#-- predicting

proj_crf<- predict(pred, crf,type = "prob")
proj_rrf<- predict(pred,rrf, type ="response")

#--evaluating the models
#rrf
# RMSE

mods<- list(rrf_1,rrf_2,rrf_3,rrf_4,rrf_5)

mean(mods[1]$rsq)

rsq<-NA
for(i in 1:length(mods)){
rsq[i]<-mean(mods[[i]]$rsq)
}

mse<-NA
for(i in 1:length(mods)){
  mse[i]<-mean(mods[[i]]$mse)
}

mean(rsq)#0.44
mean(mse)#0.14


# AUC

print(e)

auc <- sapply(e, function(x){x@auc})
cor_rf<- sapply(e,function(x){x@cor})
mean(auc) # 0.88
mean(cor_rf) # 0.66


#For classification model: 
#require(pROC)
#rf.roc<-roc(train$pa,crf$votes[,2])
#plot(rf.roc)
#auc(rf.roc) # 0.8942

#-- exporting

xd<-"C:/Users/..."
writeRaster(proj_rrf, paste(xd, "RF_rrf_CH_allvar.tif", sep="/"),overwrite = TRUE)

