# Recreation

This model was created based on ESTIMAP's recreation model (European Commission, 2013)

It relies on different components to try and assess the recreation potential of the landscape, as well as the accessibility to this recreation. 

### Components of the model

#### Degree of naturalness (DN)

The DN is based on the attribution of naturality values to LULC categories. The attribution is done with a correspondence table with values taken from expert knwoledge (personal communication from Pascal Martin)

#### Natural areas component (NA)

This layer is based on "Protected areas" from TLMRegio, coupled with Emerald sites from Swisstopo and Pro Natura reserves (personal communication)

#### Water component (WC)

This layer is based on the "lakes" from TLMRegio, using an impedence function on a buffer of 2km around lakes (Paracchini et al., 2014). 

#### Remoteness from settlements

This layer represent the relative distance to main settlements

1. Selecting LULC categories 25,26,27,29,45,46,47,49 (corresponding to residential areas), creating polygons around those and selecting polygons larger than 25 ha (European Commission, 2013).
2. Creating a friction raster based on slope (DEM 25m) and lakes layer (TLMRegio) and using a cost distance function from the polygons selected at step 1.

#### Accessibility from roads

This layer represents the relative distance (euclidean distance) from roads, based on the road layer from TLM3D (exluding highways)

#### General accessibility to recreation

Combining "remoteness from settlements" and "accessibility from roads" based on values provided by European Commission (2013) divided by 2 to account for the density of Switzerland.

Remoteness from settlements is reclassified as such (columns = distance from roads, rows = distance from urban areas)

|                | <0.5 km | 0.5-2.5 km | 2.5-5 km | >5 km |
| :------------: | :-----: | :--------: | :------: | :---: |
|  **<2.5 km**   |    1    |     2      |    2     |   4   |
|  **2.5-5 km**  |    2    |     2      |    2     |   4   |
| **5-12.5 km**  |    3    |     3      |    3     |   4   |
| **12.5-25 km** |    3    |     4      |    4     |   4   |
|   **>25 km**   |    4    |     4      |    4     |   5   |



------

European Commission. Joint Research Centre. Institute for Environment and Sustainability. (2013). *ESTIMAP: Ecosystem services mapping at European scale.* LU: Publications Office. Retrieved from https://data.europa.eu/doi/10.2788/64369

Paracchini, M. L., Zulian, G., Kopperoinen, L., Maes, J., Schägner, J. P., Termansen, M., … Bidoglio, G. (2014). Mapping cultural ecosystem services: A framework to assess the potential for outdoor recreation across the EU. *Ecological Indicators*, *45*, 371–385. doi: 10.1016/j.ecolind.2014.04.018
