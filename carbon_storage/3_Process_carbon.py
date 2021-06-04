# -*- coding: utf-8 -*-
# ---------------------------------------------------------------------------
# 3_Process_carbon.py
# Created on 01.03.21 by : N.Külling
# Info: Python version 2.7.16. Necessary modules: Arcpy, os, string, shutil
# Description: the aim of this script is to bind together raster maps created on the previous part
# 
# ---------------------------------------------------------------------------


# Import modules

import arcpy, os, string, shutil
arcpy.CheckOutExtension("Spatial")

arcpy.env.overwriteOutput = True

# Define folders

#path to "invest_models" folder, containing each individual model
in_folder = "C:\Users\kuelling\Documents\VALPAR\ES Assessment\Carbon sequestration\Automatisation\scratch\Invest_models"
#output folder, containing results
out = r"C:\Users\kuelling\Documents\VALPAR\ES Assessment\Carbon sequestration\Automatisation\result"

# Process: Creating a new folder containing each of the Carbon output per region

list_files = os.listdir(in_folder)
newfold = in_folder + "\\" + "tot_C_united"
os.mkdir(newfold)

print("new folder created at: " + newfold)

for i in list_files :
    path1 = os.path.join(in_folder,i)
    name = "tot_c_cur_" + i + ".tif"
    path2 = os.path.join(path1,name)
    shutil.copy(path2, newfold)
    

# Process: Mosaic to new raster to bind layers together in a single raster

list_lu = os.listdir(newfold)
print("copied in new folder:" + str(len(list_lu)) + " files.")
for i in list_lu:
    print(i)
    
expression = ""

for i in list_lu:
    expression = expression + str(i) + ";" 
expression = expression[:-1]
expression = "\"" + expression + "\""

arcpy.env.workspace = newfold

arcpy.MosaicToNewRaster_management(input_rasters= expression, output_location=out, raster_dataset_name_with_extension="tot_c_cur_CH.tif", coordinate_system_for_the_raster="PROJCS['CH1903+_LV95',GEOGCS['GCS_CH1903+',DATUM['D_CH1903+',SPHEROID['Bessel_1841',6377397.155,299.1528128]],PRIMEM['Greenwich',0.0],UNIT['Degree',0.0174532925199433]],PROJECTION['Hotine_Oblique_Mercator_Azimuth_Center'],PARAMETER['False_Easting',2600000.0],PARAMETER['False_Northing',1200000.0],PARAMETER['Scale_Factor',1.0],PARAMETER['Azimuth',90.0],PARAMETER['Longitude_Of_Center',7.439583333333333],PARAMETER['Latitude_Of_Center',46.95240555555556],UNIT['Meter',1.0]]", pixel_type="32_BIT_FLOAT", cellsize="", number_of_bands="1", mosaic_method="LAST", mosaic_colormap_mode="MATCH")

print("Mosaic raster created: Carbon storage")
print("Name = tot_c_cur_CH.tif")
print("Directory = " + out)
print("..........................................")
print("script 3 done!")









