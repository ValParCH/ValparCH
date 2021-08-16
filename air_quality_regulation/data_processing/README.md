Processing scripts for remote sensing data

[Copernicus LAI](https://land.copernicus.eu/global/products/lai), 300m, 2014-2018, mean

[Copernicus Dominant Leaf trait](https://land.copernicus.eu/pan-european/high-resolution-layers/forests/dominant-leaf-type/status-maps/dominant-leaf-type-2018?tab=metadata), 10m, 2018

The "DP_LULC_DLT" script serves to apply the 2018 DLT from copernicus to older maps, by taking value from the copernicus DLT and filling the gaps with rules based on the elevation, in order to have the LULC map with Deciduous/coniferous categories
