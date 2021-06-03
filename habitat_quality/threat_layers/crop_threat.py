# -*- coding: utf-8 -*-
# ---------------------------------------------------------------------------
# Crop threat layer
#
# Description: 
# ---------------------------------------------------------------------------


# Import modules

import arcpy, os, string
arcpy.CheckOutExtension("Spatial") #needed for Spatial analyst toolbox
arcpy.env.overwriteOutput = True


# Local variables

lulc = "C:\Users\\kuelling\\Documents\\VALPAR\\DATA\\Data CRS extent ok\\geotif_new_extent\\LULC_95-97.tif"
scratch = "C:\Users\\kuelling\\Documents\\VALPAR\\ES Assessment\\Habitat_quality\\data\\layer_build\\CROP\\scratch"
result = "C:\Users\\kuelling\\Documents\\VALPAR\\ES Assessment\\Habitat_quality\\data\\layer_build\\CROP\\result"
# Replace a layer/table view name with a path to a dataset (which can be a layer file) or create the layer/table view within the script
# The following inputs are layers or table views: "LULC_95-97.tif"

arcpy.gp.ExtractByAttributes_sa(lulc, '"Value" = 71 OR "Value" = 72 OR "Value" = 73 OR  "Value" = 78 OR "Value" = 81 OR "Value" = 82 OR "Value" = 75 ', scratch + "\\extract.tif")

arcpy.MakeRasterLayer_management(scratch + "\\extract.tif", "extract")

arcpy.gp.RasterCalculator_sa('Con(IsNull("extract"),0, "extract")', scratch + "\\extract2.tif")

# Replace a layer/table view name with a path to a dataset (which can be a layer file) or create the layer/table view within the script
# The following inputs are layers or table views: "extract_tif5"
arcpy.gp.Reclassify_sa(scratch + "\\extract2.tif", "Value", "0 0;71 1;72 1;73 1;75 1;78 1;81 1;82 1", result + "\\crop_c.tif", "DATA")

print("threat layer created: crop_c.tif")
