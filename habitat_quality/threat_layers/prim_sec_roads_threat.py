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
primary ="C:\Users\\kuelling\\Documents\\VALPAR\\ES Assessment\\Habitat_quality\\data\\layer_build\\ROADS\\TLM_DATA\\PRIMARY_ROAD.shp"
secondary = "C:\Users\\kuelling\\Documents\\VALPAR\\ES Assessment\\Habitat_quality\\data\\layer_build\\ROADS\\TLM_DATA\\SECONDARY_ROAD.shp"
swiss_bounds = "C:\\Users\\kuelling\\Documents\\VALPAR\\DATA\\Swiss boundaries\\swissBOUNDARIES3D_1_3_TLM_HOHEITSGEBIET.shp"
scratch = "C:\Users\\kuelling\\Documents\\VALPAR\\ES Assessment\\Habitat_quality\\data\\layer_build\\ROADS\\scratch"
result = "C:\Users\\kuelling\\Documents\\VALPAR\\ES Assessment\\Habitat_quality\\data\\layer_build\\ROADS\\result"

#Primary roads:

arcpy.PolylineToRaster_conversion(in_features=primary, value_field="FID", out_rasterdataset=scratch + "\\primary.tif", cell_assignment="MAXIMUM_LENGTH", priority_field="NONE", cellsize="25")

arcpy.MakeRasterLayer_management(scratch + "\\primary.tif", "pr_rd")

arcpy.gp.Reclassify_sa("pr_rd", "Value", "0 1000000 1;NODATA 0", result + "\\PRIMARY_ROAD.tif", "DATA")

#secondary roads:

arcpy.PolylineToRaster_conversion(in_features=secondary, value_field="FID", out_rasterdataset=scratch + "\\secondary.tif", cell_assignment="MAXIMUM_LENGTH", priority_field="NONE", cellsize="25")

arcpy.MakeRasterLayer_management(scratch + "\\secondary.tif", "se_rd")

arcpy.gp.Reclassify_sa("se_rd", "Value", "0 1000000 1;NODATA 0", result + "\\SECONDARY_ROAD.tif", "DATA")
