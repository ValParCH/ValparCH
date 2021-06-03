# -*- coding: utf-8 -*-
# ---------------------------------------------------------------------------
# rural residential threat layer
#               AND
# urban residential threat layer
#
# Description: 
# ---------------------------------------------------------------------------


# Import modules

import arcpy, os, string
arcpy.CheckOutExtension("Spatial") #needed for Spatial analyst toolbox
arcpy.env.overwriteOutput = True


# Local variables

lulc = "C:\Users\\kuelling\\Documents\\VALPAR\\DATA\\Data CRS extent ok\\geotif_new_extent\\LULC_95-97.tif"
swiss_bounds = "C:\\Users\\kuelling\\Documents\\VALPAR\\DATA\\Swiss boundaries\\swissBOUNDARIES3D_1_3_TLM_HOHEITSGEBIET.shp"
scratch = "C:\Users\\kuelling\\Documents\\VALPAR\\ES Assessment\\Habitat_quality\\data\\layer_build\\RURAL_RES\\scratch"
result = "C:\Users\\kuelling\\Documents\\VALPAR\\ES Assessment\\Habitat_quality\\data\\layer_build\\RURAL_RES\\result"

# Process

# Replace a layer/table view name with a path to a dataset (which can be a layer file) or create the layer/table view within the script
# The following inputs are layers or table views: "swissBOUNDARIES3D_1_3_TLM_HOHEITSGEBIET"
arcpy.CopyFeatures_management(in_features= swiss_bounds, out_feature_class=scratch + "\\bound", config_keyword="", spatial_grid_1="0", spatial_grid_2="0", spatial_grid_3="0")

arcpy.MakeFeatureLayer_management(scratch + "\\bound.shp", "boundaries")

arcpy.SelectLayerByAttribute_management(in_layer_or_view="boundaries", selection_type="NEW_SELECTION", where_clause="GEM_FLAECH <>0")

arcpy.AddField_management("boundaries", "density", "SHORT")

arcpy.CalculateField_management(in_table="boundaries", field="density", expression="[EINWOHNERZ]/( [GEM_FLAECH]/100)", expression_type="VB", code_block="")

arcpy.SelectLayerByAttribute_management("boundaries", "CLEAR_SELECTION")

arcpy.Select_analysis(in_features="boundaries", out_feature_class=scratch + "\\rur_sel", where_clause="EINWOHNERZ <10000 OR density <100")

arcpy.Dissolve_management(in_features=scratch + "\\rur_sel.shp", out_feature_class=scratch + "\\rur_sel2", dissolve_field="", statistics_fields="", multi_part="MULTI_PART", unsplit_lines="DISSOLVE_LINES")

arcpy.Clip_management(in_raster=lulc, rectangle="2485410,215 1075268,1363 2833857,7238 1295933,6975", out_raster=scratch + "\\clip_rur", in_template_dataset=scratch + "\\rur_sel2.shp", nodata_value="255", clipping_geometry="ClippingGeometry", maintain_clipping_extent="NO_MAINTAIN_EXTENT")

#Selecting/extracting rural residential areas:

arcpy.gp.ExtractByAttributes_sa(scratch + "\\clip_rur", '"Value" = 34 OR "Value" = 35 OR "Value" = 38 OR  "Value" = 41 OR "Value" = 45 OR "Value" = 46 OR "Value" = 47 OR "Value" = 48 OR "Value" = 49 OR "Value" = 53', scratch + "\\extract_rr.tif")

arcpy.MakeRasterLayer_management(scratch + "\\extract_rr.tif", "extract")

arcpy.gp.RasterCalculator_sa('Con(IsNull("extract"),0, "extract")', scratch + "\\extract2.tif")

arcpy.gp.Reclassify_sa(scratch + "\\extract2.tif", "Value", "0 0;34 1;35 1;38 1;41 1;45 1;46 1;47 1;48 1;49 1;53 1", result + "\\rures_c.tif", "DATA")

print("threat layer created: rures_c.tif")


# Creating urban layer by taking the opposite selection:

arcpy.Dissolve_management(in_features=swiss_bounds, out_feature_class=scratch + "\\swiss_bounds2", dissolve_field="", statistics_fields="", multi_part="MULTI_PART", unsplit_lines="DISSOLVE_LINES")

arcpy.Erase_analysis(in_features=scratch + "\\swiss_bounds2.shp", erase_features=scratch + "\\rur_sel2.shp", out_feature_class=scratch+ "\\urb_sel", cluster_tolerance="25 Meters")

arcpy.Clip_management(in_raster=lulc, rectangle="2485410,215 1075268,1363 2833857,7238 1295933,6975", out_raster=scratch + "\\clip_urb", in_template_dataset=scratch + "\\urb_sel.shp", nodata_value="255", clipping_geometry="ClippingGeometry", maintain_clipping_extent="NO_MAINTAIN_EXTENT")

arcpy.gp.ExtractByAttributes_sa(scratch + "\\clip_urb", '"Value" = 34 OR "Value" = 35 OR "Value" = 38 OR  "Value" = 41 OR "Value" = 45 OR "Value" = 46 OR "Value" = 47 OR "Value" = 48 OR "Value" = 49 OR "Value" = 53', scratch + "\\extract_ur.tif")

arcpy.MakeRasterLayer_management(scratch + "\\extract_ur.tif", "extract")

arcpy.gp.RasterCalculator_sa('Con(IsNull("extract"),0, "extract")', scratch + "\\extract_u2.tif")

arcpy.gp.Reclassify_sa(scratch + "\\extract_u2.tif", "Value", "0 0;34 1;35 1;38 1;41 1;45 1;46 1;47 1;48 1;49 1;53 1", result + "\\urban_c.tif", "DATA")

print("threat layer created: urban_c.tif")




