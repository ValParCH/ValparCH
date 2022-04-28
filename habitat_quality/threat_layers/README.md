# Habitat quality - Threat layers

Here are the codes designed to produce the "threat layers" needed for the natcap InVEST habitat quality model. The layers used are:

1. ### **primary_roads**

   composed of highways and main roads (TLM3D codes: 2,8,9,20,21)

2. ### **secondary_roads**

   composed of secondary roads (TLM3D codes: 10,11)

3. ### **residential**

   comprises the following LULC categories: 

| Code | Name                                                 |
| ---- | ---------------------------------------------------- |
| 1    | Industrial and commercial buildings                  |
| 2    | Surroundings of industrial and commercial  buildings |
| 3    | One- and two-family houses                           |
| 4    | Surroundings of one- and two-family houses           |
| 5    | Terraced houses                                      |
| 6    | Surroundings of terraced houses                      |
| 7    | Blocks of flats                                      |
| 8    | Surroundings of blocks of flats                      |
| 9    | Public buildings                                     |
| 10   | Surroundings of public buildings                     |
| 11   | Agricultural buildings                               |
| 12   | Surroundings of agricultural buildings               |
| 13   | Unspecified buildings                                |
| 14   | Surroundings of unspecified buildings                |


   And is defined as being part of a municipality with either a population density of >100/km2 OR >10 000 inhabitants

4. ### **rural_residential**

   Comprises the same categories as urban but is defined as being part of a municipality with either a population density of <100/km2 OR <10 000 inhabitants

5. ### **crops**

   comprises the following LULC categories:
   
| Code | Name               |
| ---- | ------------------ |
| 37   | Intensive orchards |
| 38   | Field fruit trees  |
| 39   | Vineyards          |
| 40   | Horticulture       |
| 41   | Arable land        |


   

------

Layers roads are all produced together (same script), the same goes for urban and rural_residential.

