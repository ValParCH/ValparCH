# -*- coding: utf-8 -*-
# ---------------------------------------------------------------------------

# 
# ---------------------------------------------------------------------------


# Import modules

import arcpy, os, string
arcpy.CheckOutExtension("Spatial") #needed for Spatial analyst toolbox
arcpy.env.overwriteOutput = True


#----- Define paths to variables

# Path to Swiss national regions 
PRODREG_shp = "C:\\Users\\kuelling\\Documents\\VALPAR\\DATA\\Swiss_Regions_SHP\\PRODREG.shp" # provide a default value if unspecified
# Path to LULC map
gs25lv95_tif = "C:\\Users\\kuelling\\Documents\\VALPAR\\DATA\\Data CRS extent ok\\geotif_new_extent\\LULC_95-97.tif"
# Path to scratch workspace
scratch = "C:\\Users\\kuelling\\Documents\\VALPAR\\ES Assessment\\material_assistance\\wood_supply\\scratch"
# Path to a DEM
DHM200_asc = "C:\\Users\\kuelling\\Documents\\VALPAR\\DATA\\DEM (200_free_swisstopo)\\DHM200.asc" # provide a default value if unspecified

# Local variables:
reclass = scratch + "\\reclass" 
DEM_polygon_shp = scratch + "\\DEM_polygon.shp"
NFI_overlay_shp = scratch + "\\NFI_overlay.shp"

#----- Processing
# Process: Reclassify
arcpy.gp.Reclassify_sa(DHM200_asc, "VALUE", "193 600 1;600 1200 2;1200 4556,625000 3", reclass, "DATA") # Reclassifying DEM raw values in 3 altitude classes 

print("Reclassification of DEM: done")

# Process: Raster to Polygon : transforming Dem raster in a polygon
tempEnvironment0 = arcpy.env.outputZFlag
arcpy.env.outputZFlag = "Disabled"
tempEnvironment1 = arcpy.env.outputMFlag
arcpy.env.outputMFlag = "Disabled"
arcpy.RasterToPolygon_conversion(reclass, DEM_polygon_shp, "SIMPLIFY", "VALUE", "SINGLE_OUTER_PART", "")
arcpy.env.outputZFlag = tempEnvironment0
arcpy.env.outputMFlag = tempEnvironment1

print("Raster to polygon: done")


# Process: Identity: Overlaying NFI regions vector with DEM vector, to get 3 polygons per region (for each altitude class)
regions = arcpy.Identity_analysis(PRODREG_shp, DEM_polygon_shp, NFI_overlay_shp, "ALL", "", "NO_RELATIONSHIPS")

print("Overlay of polygon and raster features: done")

# Process: processing of attribute table
# i.    Creating a new column (alt_NFI) in "regions" table, containing Region + altitude class(1-3)
# ii.   Filling the new column with concatenation of Region + altitude class
# iii.  Removing Altitude class out of range (1-3)
# iiii. Removing problematic characters from field 

regions_Layer = arcpy.MakeFeatureLayer_management(regions, "NFI_region_Layer") # creating a layer
arcpy.management.AddField(regions_Layer,"alt_NFI","TEXT") # i. adding an empty column
arcpy.CalculateField_management(in_table=regions_Layer, field="alt_NFI", expression="[ProdregN_1]& [gridcode]", expression_type="VB", code_block="") # ii. filling

with arcpy.da.UpdateCursor(regions_Layer, ['gridcode']) as cursor: # iii. cleaning
    for row in cursor:
        if row[0] < 1 or row[0] >3:
            cursor.deleteRow()
            print("row deleted: ",row)

arcpy.CalculateField_management(in_table=regions_Layer, field="alt_NFI", expression='!alt_NFI!.replace(u"é","e")', expression_type="PYTHON_9.3", code_block="") # iiii.       
arcpy.CalculateField_management(in_table=regions_Layer, field="alt_NFI", expression='!alt_NFI!.replace(" ","")', expression_type="PYTHON_9.3", code_block="") # iiii. removing spaces to get shorter strings        

#Clipping lulc

lulc = arcpy.MakeRasterLayer_management(gs25lv95_tif, "lulcmap") # creating a layer for next step


# Process: Clipping the reclassified map (lulc) with each of the NFI_overlay polygon

output_fold = scratch + "\\rasters" 
os.mkdir(output_fold) # creating a new folder in scratch database for the outputs

with arcpy.da.SearchCursor(regions_Layer, ['alt_NFI']) as cursor:
    for row in cursor:
            i = row[0]
            expression = """{0} = '{1}'""".format(arcpy.AddFieldDelimiters(datasource="regions_Layer", field="alt_NFI"), i)
            name = output_fold + "\\" + str(row[0]) + ".tif"
            if not arcpy.Exists(name): 
                clipfeat = arcpy.SelectLayerByAttribute_management(in_layer_or_view=regions_Layer, selection_type="NEW_SELECTION", where_clause=expression)
                arcpy.Clip_management(in_raster=lulc, rectangle="2485409,2314 1075268,4779 2833856,0541 1295934,7142", out_raster=name, in_template_dataset=clipfeat, nodata_value="0", clipping_geometry="ClippingGeometry", maintain_clipping_extent="NO_MAINTAIN_EXTENT")
                print str(row[0]) + ".tif"
                arcpy.SelectLayerByAttribute_management(regions_Layer, "CLEAR_SELECTION")


print("..................................................")
print("script 1 done!")

# method using  mask instead of clip, doesn't quite work
#arcpy.gp.ExtractByMask_sa(lulc, clipfeat, name)
                              
