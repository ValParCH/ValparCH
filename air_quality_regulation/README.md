# Air quality regulation NCP 

This ES/NCP is computed based on the ability from the environment to filter particulate matter (PM10, PM2,5) and pollutant gas (O3). Following the methodologies from (Braun et al., 2018; Manes et al., 2016; Nowak, Crane, & Stevens, 2006; Nowak, et al., 2013)

For now, only PM10 removal has been modeled. 

Data needs: 

| Name                                      | Unit   | Resolution                                                   | Source                                                       |
| ----------------------------------------- | ------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Annual PM10 concentration                 | µg/m^3 | 200m (interpoled, 98-2020); 20m (modeled, 2015)              | [Meteotest](https://www.bafu.admin.ch/bafu/fr/home/themes/air/etat/donnees/pollution-de-l_air--modeles-et-scenarios.html) |
| Annual PM2.5 concentration                | µg/m^3 | 20m (modeled, 2015); 200m (derived from PM2.5 share in PM10, 98-2020) | [Meteotest](https://www.bafu.admin.ch/bafu/fr/home/themes/air/etat/donnees/pollution-de-l_air--modeles-et-scenarios.html) |
| Ozone, maximal monthly 98th percentile    | µg/m^3 | 200m (interpoled, 98-2020)                                   | [Meteotest](https://www.bafu.admin.ch/bafu/en/home/topics/air/state/data/historical-data/maps-of-annual-values.html) |
| Annual Leaf-area Index (LAI, mean)        | -      | 300m                                                         | [Copernicus](https://land.copernicus.eu/global/sites/cgls.vito.be/files/products/GIOGL1_PUM_LAI300m-V1_I1.60.pdf) |
| Dominant Leaf type (coniferous/broadleaf) | -      | 10m (2018)                                                   | [Copernicus](https://land.copernicus.eu/pan-european/high-resolution-layers/forests/dominant-leaf-type/status-maps/dominant-leaf-type-2018) |
| Land-use Land cover map                   | -      | 25m (92-97)                                                  |                                                              |

| Name                                             | PM10                                      | PM2.5            | O3                 |
| ------------------------------------------------ | ----------------------------------------- | ---------------- | ------------------ |
| **Dry deposition velocity**                      |                                           |                  |                    |
| needle-leaved forest                             | 0.0080 m/s                                | 0,0097786 m/s    |                    |
| broad-leaved forest                              | 0.0032 m/s                                | 0,002525 m/s     |                    |
| other nature (crops, shrubs, meadows, pastures ) | 0.0010 m/s                                |                  |                    |
| urban, water bodies, bare rock                   | 0 m/s                                     |                  |                    |
| sources                                          | Remme et al., 2014; Powe and Willis, 2004 | Yin et al., 2019 |                    |
| **Resuspension rate**                            | 0.5                                       |                  |                    |
| source                                           | Zinke 1967                                |                  |                    |
| **Stomatal conductance to water vapor**          | -                                         | -                |                    |
| source                                           |                                           |                  | Manes et al., 2016 |



### PM10 removal

The data has been resampled to the same extent, projection and resolution (Swiss grid, LV95, 25m). The final result is a map of PM10 rate of removal, the process has been performed on R [see script](https://github.com/ValParCH/ValparCH/blob/main/air_quality_regulation/PM10/AQR_PM10.R):

![](https://github.com/ValParCH/ValparCH/blob/main/air_quality_regulation/figs/AQR_value_PM10.png)



------

REFERENCES

Baró, F., Chaparro, L., Gómez-Baggethun, E., Langemeyer, J., Nowak, D. J., & Terradas, J. (2014). Contribution of Ecosystem Services to Air Quality and Climate Change Mitigation Policies: The Case of Urban Forests in Barcelona, Spain. *AMBIO*, *43*(4), 466–479. doi: 10.1007/s13280-014-0507-x

Braun, D., Damm, A., Hein, L., Petchey, O. L., & Schaepman, M. E. (2018). Spatio-temporal trends and trade-offs in ecosystem services: An Earth observation based assessment for Switzerland between 2004 and 2014. *Ecological Indicators*, *89*, 828–839. doi: 10.1016/j.ecolind.2017.10.016

Manes, F., Marando, F., Capotorti, G., Blasi, C., Salvatori, E., Fusaro, L., … Munafò, M. (2016). Regulating Ecosystem Services of forests in ten Italian Metropolitan Cities: Air quality improvement by PM10 and O3 removal. *Ecological Indicators*, *67*, 425–440. doi: 10.1016/j.ecolind.2016.03.009

Nowak, D. J., Crane, D. E., & Stevens, J. C. (2006). Air pollution removal by urban trees and shrubs in the United States. *Urban Forestry & Urban Greening*, *4*(3), 115–123. doi: 10.1016/j.ufug.2006.01.007

Nowak, D. J., Hirabayashi, S., Bodine, A., & Hoehn, R. (2013). Modeled PM2.5 removal by trees in ten U.S. cities and associated health effects. *Environmental Pollution*, *178*, 395–402. doi: 10.1016/j.envpol.2013.03.050

Powe, N. A., & Willis, K. G. (2004). Mortality and morbidity benefits of air pollution (SO2 and PM10) absorption attributable to woodland in Britain. *Journal of Environmental Management*, *70*(2), 119–128. doi: 10.1016/j.jenvman.2003.11.003

Remme, R. P., Schröter, M., & Hein, L. (2014). Developing spatial biophysical accounting for multiple ecosystem services. *Ecosystem Services*, *10*, 6–18. doi: 10.1016/j.ecoser.2014.07.006

Yin, S., Zhang, X., Yu, A., Sun, N., Lyu, J., Zhu, P., & Liu, C. (2019). Determining PM2.5 dry deposition velocity on plant leaves: An indirect experimental method. *Urban Forestry & Urban Greening*, *46*, 126467. doi: 10.1016/j.ufug.2019.126467

Zinke, P. J., 1967, Forest interception studies in the United States, in: Forest Hydrology, Pergamon Press, Oxford.
