# Recreation - Flow modelling

To get an estimation of the flow (or use) of the outdoor recreation NCP, a distribution model is created based on [observation data](https://github.com/ValParCH/ValparCH/blob/main/recreation/recreation_flow/data) from two picture sharing websites (Flickr, Inaturalist) using a Random Forest regression. Photo sharing apps are often used to get an idea of recreational places in ecosystem services assessment. The two chosen apps are very different in their aim, one (Flickr) is a hosting service for pictures, whereas the other (Inaturalist) aims at sharing nature observations and agreeing upon species classification. Nevertheless, both occur in similar locations, and [this graph](https://github.com/ValParCH/ValparCH/blob/main/recreation/recreation_flow/barplot_LULC_photo_freq.R) gives an insight of main correspondences of photo locations and LULC classes: 

![Flickr_inat_LULC_sep](https://github.com/ValParCH/ValparCH/blob/main/recreation/recreation_flow/figs/Flickr_inat_LULC_sep.png)

### Data acquisition - Flickr

The geolocation of Flickr pictures is scraped for all of Switzerland and for the entire period (2006-2021) using R. This step requires an API key that is freely available on request on Flickr website. 

The pictures are gathered using keywords in French, German, Italian and English, that are determined based on most frequently used keywords related to "nature". Here is the list of the selected keywords: 

"mountains","montagn", "berg", "foret", "foresta", "wald", "natur", "landschaft", "paysage", "paesaggio", "landscape"

The data is then filtered to keep only one observation per user. The process is accessible in the [R script of this folder](https://github.com/ValParCH/ValparCH/blob/main/recreation/recreation_flow/Flickr_pictures_Extraction.R). 

### Data acquisition - Inaturalist

The data is acquired through the [Inaturalist.org](https://www.inaturalist.org/) website, exporting data of observations for mammals, birds, fish and plants. The data is then filtered to keep only one observation per user ID. 

### Modelling

The model is then created (see [script](https://github.com/ValParCH/ValparCH/blob/main/recreation/recreation_flow/RF_flickr_inat.R)) by training a RF algorithm with several environmental variables on the response data. The original variables were selected using a correlation matrix to remove variables with >.8 correlation. 

| Response variable     | Flickr + Inaturalist photo locations                         |
| --------------------- | ------------------------------------------------------------ |
| sample                | *n =* 15345 pictures location, 10000 generated pseudo-absence. |
| Explanatory variables | ·    Mean annual precipitations                              |
|                       | ·    Mean DEM                                                |
|                       | ·    Population density                                      |
|                       | ·    Forest cover (WSL)                                      |
|                       | ·    Distance to paths (cat. 16, TLM3D, transformed to raster) |
|                       | ·    Accessibility (see recreation supply ES)                |
|                       | ·    Terrain heterogeneity (number of LULC classes on a 1km^2 window, |
|                       | ·    Terrain ruggedness index                                |
|                       | ·    Distance to roads (cats. 8-9-10-11, TLM3D, transformed to raster) |
|                       | ·    LULC aggregated, 25 m focal window: Agriculture, forest,hydro, low vegetation, settlements |

The goodness of fit of the model was assessed by testing the prediction on 20% of the dataset, and computing common metrics from which there are some:  

| Correlation coefficient | 0.67 |
| ----------------------- | ---- |
| AUC of ROC                     | 0.88 |
| R^2                     | 0.44 |
| MSE                    | 0.14 | 

### Correlation between the predictors

![](https://github.com/ValParCH/ValparCH/blob/main/recreation/recreation_flow/figs/cor_circle.png)

![](https://github.com/ValParCH/ValparCH/blob/main/recreation/recreation_flow/figs/correlogram.png)

As displayed, the annual mean temperature as well as the slope variables were correlated above the chosen threshold, so they were removed for the analysis. 

Here are the importance of the variables in the model prediction: 

![VarimpPlot](https://github.com/ValParCH/ValparCH/blob/main/recreation/recreation_flow/figs/VarimpPlot.png)

The transportation network (paths and roads) as well as the settlement areas seem to be the most influencial for picture taking probability. 
