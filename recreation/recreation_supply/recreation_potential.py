# -*- coding: utf-8 -*-
# ---------------------------------------------------------------------------
# Recreation potential 
#
# Description: 
# ---------------------------------------------------------------------------


# Import modules

import arcpy, os, string
arcpy.CheckOutExtension("Spatial") #needed for Spatial analyst toolbox
arcpy.env.overwriteOutput = True


#Data for Water component part
    #Swiss boundaries polygon
swissBOUNDARIES3D_1_3_TLM_LANDESGEBIET_shp = "C:\\Users\\kuelling\\Documents\\VALPAR\\DATA\\Swiss boundaries\\swissBOUNDARIES3D_1_3_TLM_LANDESGEBIET.shp"
    #Polygon with every lake of Switzerland
lakes_TLM_shp = "C:\\Users\\kuelling\\Documents\\VALPAR\\ES Assessment\\Recreation - estimap\\data\\lakes\\lakes_TLM.shp" 
    #Land-use Land Cover map. Will be used as reference extent troughout script
gs25lv95_tif = "C:\\Users\\kuelling\\Documents\\VALPAR\\DATA\\Data CRS extent ok\\geotif_new_extent\\geotif_new_extent\\gs25lv95.tif" 


#Data for Natural area component part
    #Swiss protected areas
TLMRegio_ProtectedArea_shp = "C:\\Users\\kuelling\\Documents\\VALPAR\\ES Assessment\\Recreation - estimap\\Natural Areas component\\TLMRegio_protectedArea\\TLMRegio_ProtectedArea.shp"
    #Emerald sites of Switzerland
smaragd_shp = "C:\\Users\\kuelling\\Documents\\VALPAR\\ES Assessment\\Recreation - estimap\\Natural Areas component\\emerald\\Smaragd_LV95\\smaragd.shp"
    #World Heritage UNECSO sites
WH_Natur_shp = "C:\\Users\\kuelling\\Documents\\VALPAR\\ES Assessment\\Recreation - estimap\\Natural Areas component\\UNESCO\\UNESCO Weltnaturerbe_LV95\\WH_Natur.shp"
    #Pro natura sites
PN_sites_shp = "C:\Users\kuelling\Documents\VALPAR\DATA\Pro Natura\\protected_sites.shp"



#Data for Degree of naturality part
    #LULC naturality correspondance .csv table for the LULC map. Done using Pascal Martin personnal communication 
lulc_table = "C:\Users\kuelling\Documents\VALPAR\ES Assessment\Recreation - estimap\Naturality\LUtable_naturality.csv"


#scratch and results workspaces

scratch = r"C:\Users\kuelling\Documents\VALPAR\ES Assessment\Recreation - estimap\Automatisation\scratch"
results = r"C:\Users\kuelling\Documents\VALPAR\ES Assessment\Recreation - estimap\Automatisation\results"

print ("Loading of input data: done")

# Local variables:
Output_direction_raster = ""
Output_back_direction_raster = ""
dist_coast = scratch + "\\dist_coast"
CHbound = scratch + "\\CHbound"
CHbound2 = scratch + "\\CHbound2"
dist_coast2 = scratch + "\\dist_coast2"
dist_coast3 = scratch + "\\dist_coast3"
dist_coast4 = dist_coast3
fuzzy1 = scratch + "\\Fuzzy"
fuzzy_rast = scratch + "\\fuzzy_rast"


merged_NA_shp = scratch + "\\merged_NA.shp"
merged_NA_Dissolve = scratch + "\\merged_NA_Dissolve.shp"
Na_comp_rast = scratch + "\\Na_comp_rast"
Na_comp_rast_Clip = scratch + "\\Na_comp_rast_Clip"


PA = arcpy.MakeFeatureLayer_management (TLMRegio_ProtectedArea_shp, "PA")
EM = arcpy.MakeFeatureLayer_management (smaragd_shp, "EM")
WH = arcpy.MakeFeatureLayer_management (WH_Natur_shp, "WH")
PN = arcpy.MakeFeatureLayer_management (PN_sites_shp, "PN")

################################################## 1) Water component part
print("...................................................")
print("creating water component layer")
# Process: Euclidean Distance
arcpy.gp.EucDistance_sa(lakes_TLM_shp, dist_coast, "2000", "25", Output_direction_raster, "PLANAR", "", Output_back_direction_raster)

print("Distance to lakes computed")
# Process: Dissolve
arcpy.Dissolve_management(swissBOUNDARIES3D_1_3_TLM_LANDESGEBIET_shp, CHbound, "", "", "MULTI_PART", "DISSOLVE_LINES")

# Process: Erase
arcpy.Erase_analysis(CHbound + ".shp", lakes_TLM_shp, CHbound2, "")
print("Clip layer produced")
# Process: Clip
arcpy.Clip_management(dist_coast, "2485410,215 1075268,13625 2833857,72375 1295933,6975", dist_coast2, CHbound2 + ".shp", "", "ClippingGeometry", "NO_MAINTAIN_EXTENT")

# Process: Copy Raster
arcpy.CopyRaster_management(dist_coast2, dist_coast3, "", "", "-3,402823e+38", "NONE", "NONE", "32_BIT_SIGNED", "NONE", "NONE", "GRID", "NONE")

# Process: Fuzzy Membership
arcpy.gp.FuzzyMembership_sa(dist_coast3, fuzzy1, "LINEAR 2000 0", "NONE")
print("Fuzzy membership done")
# Process: Raster Calculator

arcpy.MakeRasterLayer_management(fuzzy1, "fuzz")

tempEnvironment0 = arcpy.env.snapRaster
arcpy.env.snapRaster = gs25lv95_tif
tempEnvironment1 = arcpy.env.extent
arcpy.env.extent = gs25lv95_tif
arcpy.gp.RasterCalculator_sa('Con(IsNull("fuzz"),0, "fuzz") ', fuzzy_rast + ".tif")
arcpy.env.snapRaster = tempEnvironment0
arcpy.env.extent = tempEnvironment1
print("water component layer created at : " + fuzzy_rast)


########### 2) Natural areas components

print("...................................................")
print("Natural areas component layer")

# Process: Merge
tempEnvironment0 = arcpy.env.extent
arcpy.env.extent = gs25lv95_tif
arcpy.Merge_management([PA,EM,WH,PN], merged_NA_shp)
arcpy.env.extent = tempEnvironment0

print("Merging of Natural areas: done")
# Process: Dissolve
arcpy.Dissolve_management(merged_NA_shp, merged_NA_Dissolve, "", "", "MULTI_PART", "DISSOLVE_LINES")
print("Dissolve")
# Process: Polygon to Raster
arcpy.PolygonToRaster_conversion(merged_NA_Dissolve, "FID", Na_comp_rast, "CELL_CENTER", "NONE", "25")
print("Polygon transformed to raster")

#Process: change raster values
arcpy.MakeRasterLayer_management(Na_comp_rast, "NA_rast")

arcpy.gp.RasterCalculator_sa('Con("NA_rast" ==0 , 1 , "NA_rast")', scratch + "\\Na_comp_3.tif")
print("Raster Values of natural parks set to : 1")

# Process: Raster Calculator
arcpy.MakeRasterLayer_management(scratch + "\\Na_comp_3.tif", "NA")
arcpy.gp.RasterCalculator_sa('Con(IsNull("NA"),0,"NA")', scratch + "\\NA_Layer.tif")

# Replace a layer/table view name with a path to a dataset (which can be a layer file) or create the layer/table view within the script
# The following inputs are layers or table views: "NA_Layer.tif", "naturality.tif"
arcpy.Clip_management(in_raster= scratch + "\\NA_Layer.tif", rectangle="2480000 1070000 2840000 1300000", out_raster=scratch + "\\NA_LYR.tif", in_template_dataset=gs25lv95_tif, nodata_value="#", clipping_geometry="NONE", maintain_clipping_extent="NO_MAINTAIN_EXTENT")



print("Final Natural Areas component Layer done at : " + scratch + "\\NA_LYR.tif" )



########### 3) Degree of Naturality

# Replace a layer/table view name with a path to a dataset (which can be a layer file) or create the layer/table view within the script
# The following inputs are layers or table views: "gs25lv95.tif"

# Replace a layer/table view name with a path to a dataset (which can be a layer file) or create the layer/table view within the script
# The following inputs are layers or table views: "gs25lv95.tif"

print("Naturality layer created")

naturality = scratch + "\\naturality.tif"

arcpy.CopyRaster_management(in_raster=gs25lv95_tif, out_rasterdataset= naturality, config_keyword="", background_value="", nodata_value="255", onebit_to_eightbit="NONE", colormap_to_RGB="NONE", pixel_type="", scale_pixel_value="NONE", RGB_to_Colormap="NONE", format="", transform="NONE")
print("Naturality layer created")

arcpy.AddField_management(in_table=naturality, field_name="DN", field_type="FLOAT", field_precision="", field_scale="", field_length="", field_alias="", field_is_nullable="NULLABLE", field_is_required="REQUIRED", field_domain="")

arcpy.MakeRasterLayer_management(naturality, "LULC")

arcpy.AddJoin_management(in_layer_or_view="LULC", in_field="Value", join_table= lulc_table, join_field="ID", join_type="KEEP_ALL")

print("Joined with table: " + lulc_table)

# Replace a layer/table view name with a path to a dataset (which can be a layer file) or create the layer/table view within the script
# The following inputs are layers or table views: "gs25lv95.tif"

arcpy.CalculateField_management(in_table="LULC", field="naturality.tif.vat.DN", expression="[LUtable_naturality.csv.naturality]", expression_type="VB", code_block="")

print("Degree of Naturality field created in : " + naturality )



############### Calculation of final layer
print( "making overlay of features")
arcpy.MakeRasterLayer_management(naturality, "DN")
arcpy.MakeRasterLayer_management(scratch + "\\NA_LYR.tif", "NA")
arcpy.MakeRasterLayer_management(fuzzy_rast + ".tif", "WC")
arcpy.gp.RasterCalculator_sa('(Lookup("DN","DN") + "NA" + "WC")/3', results + "\\Recreation.tif")
print("..................................................")
print("done!")
print("final Recreation layer produced at: " + results + "\\Recreation.tif") 
