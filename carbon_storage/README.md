# Carbon storage - InVEST model

Here is the code and main references used to process data and run natcap InVEST carbon model.

### Workflow

The swiss territory is divided in 3 categories, relative to altitude (<601m, 601-1200m,>1200m) and then again in 5 categories, relative to swiss production regions ("Alpes, Plateau, Sud des Alpes, Préalpes and Jura") (1_Process_carbon.R)

Individual InVEST models are run on each area (altitude + production region) (2_InVEST_carbon.py) and then bonded together (3_Process_carbon.R). 

#### Biophysical table.csv

Individual biophysical tables are generated for each altitude + production region (biophysical_tables.zip), based on data from the *Switzerland's Greenhouse Gas Inventory* (table 6-4, FOEN, 2020a)

The land use / land cover categories are reclassified based on (table 6-6, FOEN, 2020a) reclassification. 

#### Digital elevation model.asc

The digital elevation model was retrieved from swisstopo. swissALTI3D (2010)

#### Swiss production regions

The swiss production region shapefile was retrieved from FOEN (2020b)

------

References 

FOEN. (2020a). Switzerland’s Greenhouse Gas Inventory 1990–2018. Retrieved from https://www.bafu.admin.ch/bafu/en/home/topics/climate/state/data/climate-reporting/latest-ghg-inventory.html

FOEN. (2020b). Production regions NFI. Retrieved from https://opendata.swiss/en/dataset/produktionsregionen-lfi

Sharp, R., Douglass, J., Wolny, S., Arkema, K., Bernhardt, J., Bierbower, W., Chaumont, N., Denu, D., Fisher, D., Glowinski, K., Griffin, R., Guannel, G., Guerry, A., Johnson, J., Hamel, P., Kennedy, C., Kim, C.K., Lacayo, M., Lonsdorf, E., Mandle, L., Rogers, L., Silver, J., Toft, J., Verutes, G., Vogl, A. L., Wood, S, and Wyatt, K. 2020, InVEST 3.9.0.post156+ug.g13ead8f User’s Guide. The Natural Capital Project, Stanford University, University of Minnesota, The Nature Conservancy, and World Wildlife Fund.

swisstopo. (2010). SwissAlti3D. Retrieved from https://www.swisstopo.admin.ch/en/geodata/height/alti3d.html
