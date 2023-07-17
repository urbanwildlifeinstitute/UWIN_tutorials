
# UWIN Tutorial: Spatial Mapping - Detections
*Created by Kimberly Rivera - last updated July 2023 by Kimberly Rivera*

This tutorial is aimed at folks interested and new to spatial mapping, or as refesher for those already familiar. 

### Some helpful references:
1. [Species occurrence and density maps](https://ourcodingclub.github.io/tutorials/seecc_1/index.html#Flickr) - Coding Club, Gergana, John, Francesca, Sandra and Isla
2. [Elegant Graphics for Data Analysis](https://ggplot2-book.org/maps.html) -  Hadley Wickham, Danielle Navarro, and Thomas Lin Pedersen

### Tutorial Aims:

#### <a href="#spatial"> 1. Why do we need spatial data?</a>

#### <a href="#formatting"> 2. Reading and formatting data</a>

#### <a href="#plots"> 3. Plotting spatial data</a>


<a name="spatial"></a>

## 1.  Why do we need spatial data?
The study of species habitat, or where species are found in space and time, is a key component in understanding and managing wildlife. Thus, being able to collect, process, and manipulate spatial data is cruciual to this field. Though spatial information is increadibly useful to informing hypotheses and statistical analyses, it is also an incredibly powerful tool for storytelling via mapping. Traditionally, ecologists have relied on geospatial softwares like ArcGIS or QGIS to unpack and map spatial data. Though these are still important and useful tools, they can be expensive and require high computational demands. R has increasingly become a complementary tool in analyzing and mapping spatial data via new packages and software development. This tutorial will cover some basic R spatial tools to build simple but effective maps on species occurence. Concepts exemplified here can be applied to more complex map making.  


<a name="formatting"></a>

## 2. Formatting data for an Autologistic model
