# Carbon storage - InVEST model

Here is the code and main references used to process data and run natcap InVEST carbon model.

### Workflow

The swiss territory is divided in 3 categories, relative to altitude (<601m, 601-1200m,>1200m) and then again in 5 categories, relative to swiss production regions ("Alpes, Plateau, Sud des Alpes, Préalpes and Jura") (CAR_S_CH_1.R)

Individual InVEST models are run on each area (altitude + production region) (CAR_S_YEAR_CH_2.py) and then bonded together (CAR_S_CH_3.R). 

#### Biophysical table.csv

Individual biophysical tables are generated for each altitude + production region (biophysical_tables.zip), based on data from the *Switzerland's Greenhouse Gas Inventory* (table 6-4, FOEN, 2020a)

The land use / land cover categories are reclassified based on (table 6-6, FOEN, 2020a) reclassification. 

#### Digital elevation model.asc

The digital elevation model was retrieved from swisstopo. swissALTI3D (2010)

#### Swiss production regions

The swiss production region shapefile was retrieved from FOEN (2020b)

#### LULC map

the maps used are OFS LULC downscaled to 25 m (Giuliani et al., 2022) for three time periods (1992-1997, 2004-2009, 2013-2018)

------

References 

FOEN. (2020a). Switzerland’s Greenhouse Gas Inventory 1990–2018. Retrieved from https://www.bafu.admin.ch/bafu/en/home/topics/climate/state/data/climate-reporting/latest-ghg-inventory.html

FOEN. (2020b). Production regions NFI. Retrieved from https://opendata.swiss/en/dataset/produktionsregionen-lfi

Giuliani, G.; Rodila, D.; Külling, N.; Maggini, R.; Lehmann, A. Downscaling Switzerland Land Use/Land Cover Data Using Nearest Neighbors and an Expert System. Land 2022, 11, 615. https://doi.org/10.3390/land11050615 

Sharp, R., Douglass, J., Wolny, S., Arkema, K., Bernhardt, J., Bierbower, W., Chaumont, N., Denu, D., Fisher, D., Glowinski, K., Griffin, R., Guannel, G., Guerry, A., Johnson, J., Hamel, P., Kennedy, C., Kim, C.K., Lacayo, M., Lonsdorf, E., Mandle, L., Rogers, L., Silver, J., Toft, J., Verutes, G., Vogl, A. L., Wood, S, and Wyatt, K. 2020, InVEST 3.9.0.post156+ug.g13ead8f User’s Guide. The Natural Capital Project, Stanford University, University of Minnesota, The Nature Conservancy, and World Wildlife Fund.

swisstopo. (2010). SwissAlti3D. Retrieved from https://www.swisstopo.admin.ch/en/geodata/height/alti3d.html
