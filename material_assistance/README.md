## Material and assistance - Wood supply/production

### Supply

The supply of this NCP is estimated through the average carbon gain in living biomass, values taken from FOEN GHG report(table 6-15, p.366, 2021).As done as well in Schirpke et al. (2019). 

Switzerland is divided in altitude and production regions (see carbon_storage NCP), and the corresponding value of gain in biomass is attributed to each cell of the LULC map that corresponds to "productive forest". 

the file C_gain_XXXX.csv comports the values averaged over the desired time period, and divided to get a value per pixel (as opposed to per hectare; *625/10 000).

the folder "rasters" is copied from the carbon_storage NCP.

### Flow

The Flow of this NCP is estimated through official reports of Wood harvesting in switzerland over the desired period (FOEN, 2020a). Those harvest quantities (in m3) are attributed to Land use categories corresponding to productive forests :

| Code | Name                                      |
| ---- | ----------------------------------------- |
| 9    | Forest fresh cuts                         |
| 10   | Other forest                              |
| 11   | Normal dense forest                       |
| 13   | Open forest (agricultural areas)          |
| 14   | Forest stripes                            |
| 18   | Clusters of trees (on agricultural areas) |
| 19   | Other woods                               |

the value attributed to those pixels is distributed according to the Canton and the production region. This estimation is quite coarse. Comparing the dataset of forest surface from FOEN (2020b) with the surface obtained from the LULC map with those 7 categories: 


| LULC map (ha) | FOEN dataset (ha), average over 1992-1997 | Difference (ha) |
| ------------- | ----------------------------------------- | --------------- |
| 980510        | 1060297                                   | 79787           |




------

FOEN 2021: Switzerland’s Greenhouse Gas Inventory 1990–2019: National Inventory Report
and reporting tables (CRF). Submission of April 2021 under the United Nations Framework
Convention on Climate Change and under the Kyoto Protocol. Federal Office for the
Environment, Bern. http://www.climatereporting.ch

FOEN 2020a: Wood harvest in switzerland in m3, FSO number :	px-x-0703010000_102, retrieved at: https://www.bfs.admin.ch/bfs/en/home/statistics/agriculture-forestry.assetdetail.13167998.html

FOEN 2020b: Surfaces forestières en Suisse, en ha, FSO number : px-x-0703010000_101, retrieved at: https://www.bfs.admin.ch/bfs/fr/home/statistiques/agriculture-sylviculture/sylviculture.assetdetail.13167999.html

Schirpke, U., Candiago, S., Egarter Vigl, L., Jäger, H., Labadini, A., Marsoner, T., Meisch, C., Tasser, E., & Tappeiner, U. (2019). Integrating supply, flow and demand to enhance the understanding of interactions among multiple ecosystem services. Science of The Total Environment, 651, 928–941. https://doi.org/10.1016/j.scitotenv.2018.09.235



