# Habitat quality - InVEST model

Here is the code and main references used to run  and calibrate natcap InVEST habitat quality model.

### Tables building

#### Sensitivity.csv

Each land use class “**HABITAT**” column was filled based on the naturality index created thanks to expert knowledge classification. Based on the naturality classification, a score of 0.81-1 was considered habitat and kept as is,  and a score below this threshold was assigned “0”. Categories referring to habitats set on agricultural lands (e.g. cluster of trees, rows of fruit trees) were also assigned “0”.

PRIMARY ROADS (pr_rd_c) and SECONDARY ROADS (sc_rd_c) were set based on (Berta Aneseyee et al., 2020; Forman & Deblinger, 2000; Palomino & Carrascal, 2007; Shilling & Waetjen, 2012)

URBAN (urban_c), RURAL RESIDENTIAL (rures_c), and CROPS (crop_c) were set according to (Gong et al., 2019)

#### Threats.csv

Values for the threats table (maximum distance of influence, weights, decay) were based on litterature review using the following studies 

MAX_DIST: Berta Aneseyee et al., 2020; Forman & Deblinger, 2000; Palomino & Carrascal, 2007; Shilling & Waetjen, 2012

DECAY: Berta Aneseyee et al., 2020

WEIGHT: Terrado et al., 2016

#### Half saturation constant

A first run of the model using the half saturation constant of **0.5** was performed. The maximal degradation of habitat coefficient was then 0.15, and a new model was run based on half this maximum coefficient **(0.075)** as suggested by Sharp et al., 2020 (InVEST user guide)



------

References 

Berta Aneseyee, A., Noszczyk, T., Soromessa, T., & Elias, E. (2020). The InVEST Habitat Quality Model Associated with Land Use/Cover Changes: A Qualitative Case Study of the Winike Watershed in the Omo-Gibe Basin, Southwest Ethiopia. *Remote Sensing*, *12*(7), 1103. https://doi.org/10.3390/rs12071103

Forman, R. T. T., & Deblinger, R. D. (2000). The Ecological Road-Effect Zone of a Massachusetts (U.S.A.) Suburban Highway. *Conservation Biology*, *14*(1), 36–46. https://doi.org/10.1046/j.1523-1739.2000.99088.x

Gong, J., Xie, Y., Cao, E., Huang, Q., & Li, H. (2019). Integration of InVEST-habitat quality model with landscape pattern indexes to assess mountain plant biodiversity change: A case study of Bailongjiang watershed in Gansu Province. *Journal of Geographical Sciences*, *29*(7), 1193–1210. https://doi.org/10.1007/s11442-019-1653-7

Palomino, D., & Carrascal, L. M. (2007). Threshold distances to nearby cities and roads influence the bird community of a mosaic landscape. *Biological Conservation*, *140*(1), 100–109. https://doi.org/10.1016/j.biocon.2007.07.029

Sharp, R., Douglass, J., Wolny, S., Arkema, K., Bernhardt, J., Bierbower, W., Chaumont, N., Denu, D., Fisher, D., Glowinski, K., Griffin, R., Guannel, G., Guerry, A., Johnson, J., Hamel, P., Kennedy, C., Kim, C.K., Lacayo, M., Lonsdorf, E., Mandle, L., Rogers, L., Silver, J., Toft, J., Verutes, G., Vogl, A. L., Wood, S, and Wyatt, K. 2020, InVEST 3.9.0.post156+ug.g13ead8f User’s Guide. The Natural Capital Project, Stanford University, University of Minnesota, The Nature Conservancy, and World Wildlife Fund.

Shilling, F. M., & Waetjen, D. P. (2012). *The Road Effect Zone GIS Model*. https://escholarship.org/uc/item/4537d6vj

Terrado, M., Sabater, S., Chaplin-Kramer, B., Mandle, L., Ziv, G., & Acuña, V. (2016). Model development for the assessment of terrestrial and aquatic habitat quality in conservation planning. *Science of The Total Environment*, *540*, 63–70. https://doi.org/10.1016/j.scitotenv.2015.03.064

