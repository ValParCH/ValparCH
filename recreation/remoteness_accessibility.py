# -*- coding: utf-8 -*-
# ---------------------------------------------------------------------------
# Recreation potential 
#
# Description: The process goes in the following steps:
#   0) Loading required data and values
#   1) Creating a raster with the distance to the roads
#   2) Creating a raster with the distance from main settlments (25ha)
#   3) Combining the two rasters
# ---------------------------------------------------------------------------



# Import arcpy module

import arcpy, os, string
from arcpy.sa import *
from arcpy import env
arcpy.CheckOutExtension("Spatial") #needed for Spatial analyst toolbox
arcpy.env.overwriteOutput = True

############################### 0) Loading required data and values

#workspaces: 
scratch = "C:\Users\kuelling\Documents\VALPAR\\ES Assessment\\Recreation - estimap\\Automatisation\\scratch"
scratch2 = "C:\Users\kuelling\Documents\VALPAR\\ES Assessment\\Recreation - estimap\\Automatisation\\scratch2"
scratch3 = "C:\Users\kuelling\Documents\VALPAR\\ES Assessment\\Recreation - estimap\\Automatisation\\scratch3"
result = "C:\Users\kuelling\Documents\VALPAR\\ES Assessment\\Recreation - estimap\\Automatisation\\results"
print("scratch workspace at: " + scratch)
print("result workspace at: " + result)

                    ## Variables for part 1
        
# Roads vector (created from TLM3D, containing categories 8,9,10 and 11   !!!!!! CH1903 !!!!
TLM_roads_891011 = "C:\\Users\\kuelling\\Documents\\VALPAR\\DATA\\TLM3D\\roads_8_9_10_11\\TLM_roads_891011.shp"
# Swiss boundaries
swissBOUNDARIES3D_1_3_TLM_LANDESGEBIET = "C:\\Users\\kuelling\\Documents\\VALPAR\\DATA\\Swiss boundaries\\swissBOUNDARIES3D_1_3_TLM_LANDESGEBIET.shp"
#Values (to modify acording to study design, here reclassification of distance to road in 4 classes)
myRemapRange = RemapRange([[0, 500, 1], [500, 2500, 2], [2500, 5000, 3],[5000, 13000, 4]])

                    ## Variables for part 2

# LULC raster map
gs25lv95_tif = "C:\Users\kuelling\Documents\VALPAR\\DATA\\Data CRS extent ok\\geotif_new_extent\\geotif_new_extent\\gs25lv95.tif"
# DEM raster
DHM200_asc = "C:\Users\kuelling\Documents\VALPAR\\DATA\\DEM(unil)\\DEM_mean_LV95.tif"
# Lake Shapefile (from TLM3D)
Lakes = "C:\Users\kuelling\\Documents\\VALPAR\\ES Assessment\\Recreation - estimap\\data\\lakes\\lakes_TLM.shp"

print("Local variables loaded")

################################ 1) Creating a raster with the distance to the roads
print("1.: distance from roads")
# Process: Euclidean Distance
arcpy.gp.EucDistance_sa(TLM_roads_891011, scratch2 + "\\dist_road.tif", "", "25", "", "PLANAR", "", "")
print("1.1: distance from roads computed")
# Process: Clip
arcpy.Clip_management(in_raster=scratch2 + "\\dist_road.tif", rectangle="2485410,215 1075268,13625 2833857,72375 1295933,6975", out_raster=scratch2 + "\\dist_road2.tif", in_template_dataset=swissBOUNDARIES3D_1_3_TLM_LANDESGEBIET, nodata_value="-3,402823e+38", clipping_geometry="ClippingGeometry", maintain_clipping_extent="NO_MAINTAIN_EXTENT")
print("1.2: raster output clipped")
# Process: Reclassify
dist_road_22 = scratch2+"\\dist_road2.tif"

arcpy.MakeRasterLayer_management(dist_road_22, "dr2")
    
env.workspace = "C:\Users\kuelling\Documents\VALPAR\ES Assessment\Recreation - estimap\Automatisation\scratch_r"
outreclass = Reclassify("dr2", "VALUE", myRemapRange)
outreclass.save(scratch2+ "\\dist_road3.tif")
print("1.3: raster reclassified, chosen classification:" + str(myRemapRange))
print("................................................")

################################ 2) Creating a raster with the distance from main settlements (25ha)  
print("2.: distance from main settlements")
# Process: Select Layer By Attribute
arcpy.MakeRasterLayer_management(gs25lv95_tif, "lu")
arcpy.SelectLayerByAttribute_management("lu", "NEW_SELECTION", "\"Value\" = 25 OR\"Value\" = 26 OR\"Value\" = 27 OR\"Value\" = 29 OR\"Value\" = 45 OR\"Value\" = 46 OR\"Value\" = 47 OR\"Value\" = 49 ")

# Process: Raster to Polygon

arcpy.RasterToPolygon_conversion ("lu", scratch + "\\res_area.shp", "SIMPLIFY", "Value")
print("2.1: Lulc raster converted to polygon (residential areas)")
# Process: Aggregate Polygons
arcpy.AggregatePolygons_cartography(scratch + "\\res_area.shp", scratch + "\\agregate_res2.shp", "150 Meters", "0 SquareMeters", "0 SquareMeters", "NON_ORTHOGONAL", "")
print("2.2: Polygons aggregated (value= 150m)")
# Process: Add Field
arcpy.AddField_management(scratch + "\\agregate_res2.shp", "area", "LONG", "", "", "", "", "NULLABLE", "NON_REQUIRED", "")

# Process: Calculate Field
arcpy.CalculateField_management(scratch + "\\agregate_res2.shp", "area", "!shape.area@hectares!", "PYTHON_9.3", "")

# Process: Select
arcpy.Select_analysis(scratch + "\\agregate_res2.shp", scratch + "\\res_select.shp", "\"area\" >=25")
print("2.3: Settlements of >= 25 ha selected")
    # Process: Path Distance
#creating the cost raster, based on slope and lakes:
#slope:
arcpy.gp.Slope_sa(DHM200_asc, scratch + "\\slope", "DEGREE", "1", "PLANAR", "METER")

arcpy.gp.Reclassify_sa(scratch + "\\slope", "VALUE", "0 4,522124 1;4,522124 11,479237 2;11,479237 18,436350 3;18,436350 25,045608 4;25,045608 31,307010 5;31,307010 37,916267 6;37,916267 45,569092 7;45,569092 55,309050 8;55,309050 88,703194 9", scratch2 + "\\slope_reclas", "DATA")


#slope22 = scratch + "\\slope"

#arcpy.MakeRasterLayer_management(slope22, "s2")
#slope_range = RemapRange([[0, 4, 1], [4, 11, 2], [11, 18, 3],[18, 25, 4],[25, 31, 5],[31, 38, 6],[38, 45, 7],[45, 55, 8],[55, 89, 9]])

#slope_range = RemapRange([[0, 10, 1], [10, 24, 2], [24, 39, 3],[39, 89, 4]])

#outreclass = Reclassify("s2", "VALUE", slope_range,"NODATA")
#outreclass.save(scratch+ "\\dist_road3.tif")

##### TEMPORARY !!! UNTIL I FIX RECLASS ISSUE WITH SLOPE
#sloperec= scratch + "\\Reclass_slop21.tif"
#arcpy.MakeRasterLayer_management(sloperec, "Reclass_Slop1")
########################################################

print("2.4: Slope raster created")
#Lakes !!!! choose cell size according to DEM
arcpy.PolygonToRaster_conversion(Lakes, value_field="FID", out_rasterdataset= scratch + "\\lakes_rast", cell_assignment="CELL_CENTER", priority_field="NONE", cellsize="25")
arcpy.gp.Reclassify_sa(scratch + "\\lakes_rast", "Value", "0 3260,825649 10;NODATA 0", scratch + "\\reclas_lakes", "DATA")
print("2.5: Lake raster created")
#Merging lakes and slope, giving frction value of 10 for lakes and 1-9 for slope
#arcpy.MakeRasterLayer_management(scratch + "\\slope_reclas", "Reclass_Slop1")
arcpy.MakeRasterLayer_management(scratch + "\\reclas_lakes", "Reclass_lake2")

arcpy.gp.RasterCalculator_sa('"Reclass_Slop1" + "Reclass_lake2"', scratch + "\\slope_lake")
arcpy.gp.Reclassify_sa(scratch + "\\slope_lake", "Value", "1 1;2 2;3 3;4 4;5 5;6 6;7 7;8 8;9 9;10 19 10", scratch + "\\slope_lake2", "DATA")
print("2.6: Friction raster created based on slope and lakes")
##Cost distance using slope + lake as a friction layer, and Agregate_res2 (residential area >25 ha) as a source)
print("2.7: Creating cost distance raster, based on residential areas, with slope and lakes as friction raster...")
arcpy.gp.CostDistance_sa(scratch + "\\res_select.shp", scratch + "\\slope_lake2", scratch + "\\res_dist_cost", "", "", "", "", "", "", "")
print("...done!")
#clippin at desired extent

#arcpy.Clip_management(in_raster=scratch + "\\res_dist_cost", rectangle= "485410,215000002 75268,1362499983 833857,723749999 295933,697500002",  out_raster=scratch + "\\res_dist_cl", in_template_dataset=swissBOUNDARIES3D_1_3_TLM_LANDESGEBIET, nodata_value="-3,402823e+38", clipping_geometry="ClippingGeometry",maintain_clipping_extent= "NO_MAINTAIN_EXTENT")

# Reclassify according to study design vlaues
res_values = "0 5000 1;5000 10000 2;10000 25000 3;25000 50000 4;50000 90000 5"
arcpy.gp.Reclassify_sa(scratch + "\\res_dist_cost", "VALUE",res_values , scratch + "\\res_final", "DATA")

print("2.8: new cost distance raster clipped and reclassified (ESTIMAP values)")
print("................................................")
      
################################ 3) Combining the two rasters (
print("3.: combining distance from roads and distance from settlements rasters")
# Raster calculator to sum the distance from road layer with the distance from residential area layer
arcpy.MakeRasterLayer_management(scratch2+ "\\dist_road3.tif", "roads_reclass")
arcpy.MakeRasterLayer_management(scratch + "\\res_final", "resid_reclas")

arcpy.gp.RasterCalculator_sa('"resid_reclas"*1000+"roads_reclass"', scratch3 + "\\Accessibility")

arcpy.gp.Reclassify_sa(scratch3 + "\\Accessibility", "Value", "1001 1;1002 2;1003 2;2001 2;2002 2;2003 2;2004 4;3001 3;3002 3;3003 3;3004 4;4001 3;4002 4;4003 4;4004 4;5001 4;5002 4;5003 4;5004 5", result + "\\Accessibility.tif", "DATA")

print("3.1: Raster combined and reclassified (ESTIMAP values)")
print("output \"accessibility\" available at :" + result + "\\Accessibility.tif" )
