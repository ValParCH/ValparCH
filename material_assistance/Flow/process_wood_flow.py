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
scratch = "C:\\Users\\kuelling\\Documents\\VALPAR\\ES Assessment\\material_assistance\\wood_flow\\process\\scratch"
# Path to cantonal boundaries
cantons = "C:\\Users\\kuelling\\Documents\\VALPAR\\DATA\\Swiss boundaries\\swissBOUNDARIES3D_1_3_TLM_KANTONSGEBIET.shp"


# Identity

reg_cant = arcpy.Identity_analysis(in_features=cantons, identity_features=PRODREG_shp, out_feature_class=scratch + "\\cant_reg.shp", join_attributes="ALL", cluster_tolerance="", relationship="NO_RELATIONSHIPS")

print("Identity done")

# Process: processing of attribute table
# i.    Creating a new column (reg_cant) in "regions" table, containing Region + canton number
# ii.   Filling the new column with concatenation of Region + altitude class
# iii.  Removing Altitude class out of range (1-3)
# iiii. Removing problematic characters from field 

regions_Layer = arcpy.MakeFeatureLayer_management(reg_cant, "reg_cant") # creating a layer
arcpy.management.AddField(regions_Layer,"reg_cant","TEXT") # i. adding an empty column
arcpy.CalculateField_management(in_table=regions_Layer, field="reg_cant", expression="[ProdregN_1]& [KANTONSNUM]", expression_type="VB", code_block="") # ii. filling


with arcpy.da.UpdateCursor(regions_Layer, ['reg_cant']) as cursor: # iii. cleaning
    for row in cursor:
      if len(row[0]) < 5 :
        cursor.deleteRow()
        print "Deleted rows: "
        print row
      


arcpy.CalculateField_management(in_table=regions_Layer, field="reg_cant", expression='!reg_cant!.replace(u"é","e")', expression_type="PYTHON_9.3", code_block="") # iiii.       
arcpy.CalculateField_management(in_table=regions_Layer, field="reg_cant", expression='!reg_cant!.replace(" ","")', expression_type="PYTHON_9.3", code_block="") # iiii. removing spaces to get shorter strings        


#Clipping lulc

lulc = arcpy.MakeRasterLayer_management(gs25lv95_tif, "lulcmap") # creating a layer for next step


# Process: Clipping the reclassified map (lulc) with each of the NFI_overlay polygon

output_fold = scratch + "\\rasters" 
os.mkdir(output_fold) # creating a new folder in scratch database for the outputs

with arcpy.da.SearchCursor(regions_Layer, ['reg_cant']) as cursor:
    for row in cursor:
            i = row[0]
            expression = """{0} = '{1}'""".format(arcpy.AddFieldDelimiters(datasource="regions_Layer", field="reg_cant"), i)
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
                              
