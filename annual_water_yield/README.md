# Annual Water Yield NCP /ES

This ES is computed using the [InVEST annual water yield model](https://storage.googleapis.com/releases.naturalcapitalproject.org/invest-userguide/latest/annual_water_yield.html). 

The data used in this model is the following: 

| Data                            | Source                                                      |
| ------------------------------- | ----------------------------------------------------------- |
| Evapotranspiration Raster layer | CHclim25-Broennimann / evapotranspiration using Turc method |
| LULC                            | Downscaled LULC map (25m) A. Lehmann                        |
| Plants available water content  | OFAG: Soil aptitudes                                        |
| Root restricting depth          | OFAG: Soil aptitudes                                        |
| Annual precipitations           | Bioclim Bio12, downscaled 25m (O. Broennimann)              |
| Seasonality constant (z)        | see below                                                   |
| Sub watersheds vector           | HADES A02 - medium catchments                               |
| watersheds vector               | HADES A03 - river basins                                    |
| Biophysical table               | see below                                                   |

### Seasonality constant (Z)

the seasonality constant has been shown to not affect greatly the output of the model for values above 15 (Hamel et al., 2015). The Z value has been computed based on observation data from [meteosuisse](https://www.meteosuisse.admin.ch/product/input/climate-data/normwerte-pro-messgroesse/np8110/nvrep_np8110_rsd010m0_f.pdf) : 

Z Value per subwatershed: 

| Metric | value         |
| ------ | ------------- |
| mean   | 25.82372      |
| median | 26.61         |
| range  | 15.16 - 33.49 |

plot: 
