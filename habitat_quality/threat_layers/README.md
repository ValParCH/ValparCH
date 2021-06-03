# Habitat quality - Threat layers

Here are the codes designed to produce the "threat layers" needed for the natcap InVEST habitat quality model. The layers used are:

1. **primary_roads**

   composed of highways and main roads (TLM3D codes: 2,8,9,20,21)

2. **secondary_roads**

   composed of secondary roads (TLM3D codes: 10,11)

3. **urban**

   comprises the following LULC categories: 

   | Code | Name                                        |
   | ---- | ------------------------------------------- |
   | 34   | Parking areas                               |
   | 35   | Railway station grounds                     |
   | 38   | Airfields, green airport environs           |
   | 41   | Industrial ground                           |
   | 45   | Land around 25 (One- and two family houses) |
   | 46   | Land around 26 (Terraced houses)            |
   | 47   | Land around 27 (Blocks of flats)            |
   | 48   | Land around 28 (Agricultural buildings)     |
   | 49   | Land around 29 (Unspecified buildings)      |
   | 53   | Camping, caravan sites                      |

   And is defined as being part of a municipality with either a population density of >100/km2 OR >10 000 inhabitants

4. **rural_residential**

   Comprises the same categories as urban but is defined as being part of a municipality with either a population density of <100/km2 OR <10 000 inhabitants

5. **crops**

   comprises the following LULC categories:

   | Code | Name                               |
   | ---- | ---------------------------------- |
   | 71   | Regular vineyards                  |
   | 72   | "Pergola" vineyards                |
   | 73   | Extensive vines                    |
   | 75   | Intensive orchards                 |
   | 78   | Horticulture                       |
   | 81   | Favourable arable land and meadows |
   | 82   | Other arable land and meadows      |

   

------

Layers roads are all produced together (same script), the same goes for urban and rural_residential.

The codes are written in python 2.7 using the arcpy module
