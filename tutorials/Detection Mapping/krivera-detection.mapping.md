
# UWIN Tutorial: Spatial Mapping - Detections
*Created by Kimberly Rivera - last updated July 2023 by Kimberly Rivera*

This tutorial is aimed at folks interested and new to spatial mapping, or as refresher for those already familiar. 

### Some helpful references:
1. [Species occurrence and density maps](https://ourcodingclub.github.io/tutorials/seecc_1/index.html#Flickr) - Coding Club, Gergana, John, Francesca, Sandra and Isla
2. [Elegant Graphics for Data Analysis](https://ggplot2-book.org/maps.html) -  Hadley Wickham, Danielle Navarro, and Thomas Lin Pedersen
3. [A Guide to using ggmap](https://builtin.com/data-science/ggmap) - Ivo Bernardo

### Tutorial Aims:

#### <a href="#spatial"> 1. Why do we need spatial data?</a>

#### <a href="#formatting"> 2. Processing and formatting data</a>

#### <a href="#plots"> 3. Plotting spatial data</a>


<a name="spatial"></a>

## 1.  Why do we need spatial data?
The study of species habitat, or where species are found in space and time, is a key component in understanding and managing wildlife. Thus, being able to collect, process, and manipulate spatial data is an important skill. In addition to spatial information being useful in informing hypotheses and statistical analyses, it is also a powerful tool for visualizing data and storytelling via mapping. Traditionally, ecologists have relied on geospatial softwares like ArcGIS or QGIS to unpack and map spatial data. Though these are still important and useful tools, they can be expensive and may require high computational demands. R has increasingly become a complementary tool for analyzing and mapping spatial data via new packages and software development. This tutorial will cover some basic R spatial tools to build simple but effective maps on species occurrence. Concepts exemplified here can be templates for more complex map making.  

<a name="formatting"></a>

## 2. Processing and formatting data
Some reasons spatial data can be difficult to work with is that it exists in many data types (shapefiles, geospatial images, etc.) with varying information extents (affiliated metadata, resolution, coordinate systems, etc.). In this tutorial we will work with two different raster datasets from package [`ggmap`](https://cran.r-project.org/web/packages/ggmap/readme/README.html) and GeoTIFF files from [ESA's WorldCover data](https://esa-worldcover.org/en). We will also use sample data from UWIN Chicago.

```R
setwd() # set to the directory in which you have data saved 

# install packages
install.packages("readr")
install.packages("tidyr")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("maps")
install.packages("RColorBrewer")
install.packages("forcats")
devtools::install_github("dkahle/ggmap", ref = "tidyup") # download source data

# load in libraries
library(readr)
library(tidyr)
library(dplyr)
library(ggplot2)
library(maps)
library(RColorBrewer)
library(ggmap)
library(forcats)

# read in example data
sp_data <- read_csv("CHIL_Detections.csv")

```
We will continue to practice manipulating data in R and subset relevant data columns in the appropriate format. We have a full UWIN sampling dataset from 2021 (four seasons of sampling) and a partial dataset from 2022. We will use 2021 data to build species distribution and alpha diversity (number of species) maps. 

```R
# to subsample data by year, we will add a new column 'year'
sp_data <- sp_data %>% 
  mutate(year = if_else(photoDateTime > '2021-12-31 11:59:59', 2022, 2021))

# we can use this column to subset our data to year 2021
sp_data_2021 <- sp_data %>% filter(year == 2021)
```
We will need to use the `group_by` function to count the number of detections for each species

```R
# we can practice using group_by functions to count all detections for 2021 by species
sp_det <- sp_data_2021 %>% 
  group_by(commonName) %>% 
  summarise(detections = n())

# we can see this list matches the number of unique species in 2021
sp_det
unique(sp_data_2021$commonName)
```
Let's simplify this task by focusing on mapping one species across all of our camera sites.

```R
# subset to just detections of raccoons
raccoon_det_2021 <- sp_data_2021 %>% 
  filter(commonName == "Raccoon")

# count raccoon detections by location
raccoon_sum <- raccoon_det_2021 %>% 
  group_by(locationAbbr) %>% # this groups detections by location
  mutate(detections = n()) %>% # this function counts the detections
  ungroup() %>% 
  distinct(commonName, detections, locationAbbr, DD_Long, DD_Lat) # allows us to retain site level data
```
Great! Now we have all the data we need in one place. We also have all the information we need to plot and map raccoon detections. 

<a name="plots"></a>

## 3. Plotting spatial data
### Using ggmap
There are many packages and base maps we can use to display these data. We will be using a package called `ggmap` which allows us to use public mapping data sources like Google Maps and Stamen Maps to plot our detection data (or any point/segment/polygon data!). 

One limitation on using `ggmap` is we need to setup a project API, or application programming interface. These API's are free to use up to a $200 credit each month (28,500 maploads per month). If you already have a google account, follow [API setup instructions here](https://developers.google.com/maps/documentation/embed/get-api-key).

```R
# setup API key to use `ggmap`
my_api <- 'AIzaSyBt73bzxdvlS6ioit4OTCaIE6SrZJ9aWnA'
register_google(key = my_api)

# use package function `get_map` to extract relevant mapping data using a regions names or bounding box with coordinate information (this allows us to be more specific)
chicago <- get_map("chicago", source= "google", api_key = my_api)
ggmap(chicago)

chicago <- get_map(c(left = -88.3, bottom = 41.55, right = -87.4, top = 42.3), 
                   zoom = 10)
ggmap(chicago)
```
<p float="left">
  <img src="./plots/chicago_map_region.jpg" alt="Map of Chicago in using get_map("chicago")" width="500" height="auto" />
  <img src="./plots/chicago_map_coord.jpg" alt="Map of Chicago in using get_map() with coordinates" width="500" height="auto" />
</p>

The `ggmap` package allows us to plot over maps using the ggplot format we have learned in previous tutorials. Though we are plotting our data using latitude and longitude, it is really just like plotting any other xy data (x = longitude, y = latitude). To visualize differences in detections across camera trapping locations, we can use the command `size = detections`. 

```R
# plot detections using common ggplot functions
ggmap::ggmap(chicago) +
  geom_point(aes(x = DD_Long, y = DD_Lat, color = commonName, size = detections), 
             data = raccoon_sum) +
  ggtitle("Raccoon detections") +
  labs(size = "Detection frequency") + # updates legend related to size (here 'detections')
  #labs(color = "Species")  # updates legend related to color (here 'commonName')
  guides(color = "none") # a way to drop a certain aspect of the legend (here 'commonName')

# plot detections using additional ggplot functions to control other graphics
ggmap::ggmap(chicago) +
  geom_point(aes(x = DD_Long, y = DD_Lat, size = detections), 
             data = raccoon_sum, color = "dark blue") + # control color of detections
  ggtitle("Raccoon detections") +
  labs(size = "Detection frequency") + # updates legend related to size (here 'detections')
  scale_size_continuous(breaks=seq(50, 300, by=50)) # control breaks of detection counts
```
<p float="left">
  <img src="./plots/raccoon_map1.jpg" alt="Detections of raccoons across Chicago in 2021" width="500" height="auto" />
  <img src="./plots/raccoon_map2.jpg" alt="Detections of raccoons across Chicago in 2021" width="500" height="auto" />
</p>

Try this same process again for coyote detections. Make this plot using another color. 

<details closed><summary>Solution</a></summary>

```R
# Another species
# lets run this for ones species
coyote_det_2021 <- sp_data_2021 %>% 
  filter(commonName == "Coyote")

# count detections by location
coyote_sum <- coyote_det_2021 %>% 
  group_by(locationAbbr) %>% 
  mutate(detections = n()) %>% 
  ungroup() %>% 
  distinct(commonName, detections, locationAbbr, DD_Long, DD_Lat) 

ggmap::ggmap(chicago) +
  geom_point(aes(x = DD_Long, y = DD_Lat, size = detections), 
             data = coyote_sum, color = "purple") + # control color of detections
  ggtitle("Coyote detections") +
  labs(size = "Detection frequency") + # updates legend related to size (here 'detections')
  scale_size_continuous(breaks=seq(10, 100, by=10)) # control breaks of detection counts

# a way to save your ggplot locally
ggsave("coyote_map.jpg", width = 6, height = 6) # run this function after your desired plot
```
 <p float="left">
  <img src="./plots/coyote_map.jpg" alt="Detections of coyote across Chicago in 2021" width="500" height="auto" />
</p>

</details>

We can also map multiple species at once. Since plotting multiple species may become crowded or overwhelming to interpret as a viewer, it's helpful to know why and for who you are making these maps. Depending on your desired 'story' you may want to map certain groups of species together or separately.

Perhaps we are interested in the co-occurrence of domestic dogs with raccoon and coyote. We hypothesize that dogs are more likely to co-occur with raccoons then with coyotes based on previous research. We will certainly want to explore this hypothesis with statical models, such as a multi-species occupancy model, but we may also want to visualize our data to inform our hypotheses or supplement our findings in reports or manuscripts. Let's plot these three species together: raccoon, coyote, and dogs.

```R
# let's try this again with three species of your choosing in 2021
carnivore_det_2021 <- sp_data_2021 %>% 
  filter(commonName == "Raccoon" | commonName == "Coyote" | commonName == "Domestic dog")

# count detections by location
carnivore_sum <- carnivore_det_2021 %>% 
  group_by(locationAbbr) %>% 
  mutate(detections = n()) %>% 
  ungroup() %>% 
  distinct(commonName, detections, locationAbbr, DD_Long, DD_Lat) 

# lets map these together
ggmap::ggmap(chicago) +
  geom_point(aes(x = DD_Long, y = DD_Lat, colour = commonName, size = detections), 
             stroke = 1, data = carnivore_sum, shape = 21)
```
 <p float="left">
  <img src="./plots/carn_map.jpg" alt="Detections of coyote, dog, and raccoon across Chicago in 2021" width="500" height="auto" />
</p>

If we look closely at our map, we can see that all the raccoon detections appear to be visible but, by referencing the last map, it seems we are missing coyote detections. These data are not actually missing, but raccoon detections are overlapping the other species detections and overwriting them as those detections are plotted last. 

We can fix this by changing the plotting shapes and by adding a bit of randomness to their locations using the `jitter()` function. We can also tidy up our map using a few additional ggplot commands.

```R
# using the jitter() function
ggmap::ggmap(chicago) +
  geom_point(aes(x = DD_Long, y = DD_Lat, colour = commonName, size = detections), 
             stroke = 1, data = carnivore_sum, shape = 21)

# We can also clean up our map using more labels and axes 
ggmap::ggmap(chicago) +
  geom_point(aes(x = DD_Long, y = DD_Lat, color = commonName, size = detections, 
                 shape = commonName), stroke = 1, data = carnivore_sum, 
             position=position_jitter(h=0.01,w=0.01)) +
  ggtitle("Carnivore detections") +
  labs(size = "Detection frequency") +
  labs(color = "Species") +
  labs(color = "Species") +
  labs(shape = "Species") +
  scale_size_continuous(breaks=seq(50, 300, by=50)) +
  scale_shape_manual(values= c(21, 22, 23))  
```
 <p float="left">
  <img src="./plots/species_map_basic.jpg" alt="Detections of coyote, dog, and raccoon across Chicago in 2021" width="500" height="auto" />
   <img src="./plots/species_map_clean.jpg" alt="Detections of coyote, dog, and raccoon across Chicago in 2021" width="500" height="auto" />
</p>

If we want to instead focus our attention on a specific area, we can adjust the bounding box and map level zoom.

```R
lincoln_park <- get_map(c(left = -87.7, bottom = 41.9, 
                                  right = -87.6, top = 42.0), 
                         zoom = 12)

ggmap::ggmap(lincoln_park) +
  geom_point(aes(x = DD_Long, y = DD_Lat, colour = commonName, size = detections, 
                 shape = commonName), stroke = 1, data = carnivore_sum, 
             position=position_jitter(h=0.0025,w=0.0025))+
  scale_shape_manual(values= c(21, 22, 23))+
  scale_color_manual(values= c("chocolate", "brown4", "darkslateblue")) + # change colors for each species
  ggtitle("Lincoln Park, IL USA Detections 2021")+
  theme(plot.title = element_text(hjust = 0.5))+ # this will center your title
  xlab("Longitude")+
  ylab("Latitude")+
  labs(color = "Species")+ # to edit labels on color/shape legend title
  labs(shape = "Species")+
  labs(size = "Detections")+ # to edit label on detections legend title
  scale_size_continuous(breaks=seq(0, 300, by=50)) 
```
 <p float="left">
  <img src="./plots/species_map_LP.jpg" alt="Detections of coyote, dog, and raccoon at Lincoln Park, Chicago in 2021" width="500" height="auto" />
</p>

We can zoom in even further. Note that we need to adjust the 'zoom' every time we focus on a smaller area to increase clarity of the map image. We also need to decrease the 'jitter' so we can tell what detections are relative to what sites

```R
montrose <- get_map(c(left = -87.652, bottom = 41.950, 
                                       right = -87.620, top = 41.975), 
                              zoom = 15)

ggmap::ggmap(montrose) +
  geom_point(aes(x = DD_Long, y = DD_Lat, colour = commonName, size = detections, 
                 shape = commonName), stroke = 1, data = carnivore_sum, # want to change plot size when we zoom in
             position=position_jitter(h=0.001,w=0.001)) +
  scale_shape_manual(values= c(21, 22, 23))+
  scale_color_manual(values= c("chocolate", "brown4", "darkslateblue"))+ # change colors for each species
  ggtitle("Montrose, IL USA Detections 2021")+
  theme(plot.title = element_text(hjust = 0.5))+ # this will center your title
  xlab("Longitude")+
  ylab("Latitude")+
  labs(color = "Species")+ # to edit labels on color/shape legend title
  labs(shape = "Species")+
  labs(size = "Detections")+ # to edit label on detections legend title
  scale_size_continuous(breaks=seq(0, 300, by=50)) 
```
<p float="left">
  <img src="./plots/species_map_montrose.jpg" alt="Detections of coyote, dog, and raccoon at Montrose Beach, Chicago in 2021" width="500" height="auto" />
</p>

It can be difficult to visualize many species at once so we can also consider mapping alpha diversity, or species richness (number of species), in a given wildlife community. Let's do this for all species detected in Chicago in 2021.

```R
# summarize detections for all wildlife
sp_rich <- sp_data_2021 %>% 
  group_by(locationAbbr) %>% # group by location to summarise all species detections
  mutate(sp_det = length(unique(commonName))) %>% # count the number of species detected at each site
  ungroup() %>% # ungroup data to retain additional information like lat/long
  distinct(sp_det, locationAbbr, DD_Long, DD_Lat) # define the columns to keep 

# mapping alpha diversity
ggmap::ggmap(chicago) +
  geom_point(aes(x = DD_Long, y = DD_Lat, size = sp_det), stroke = 1, shape = 1, 
             data = sp_rich) +
  scale_shape_manual(values= c(17))+
  scale_color_manual(values = c("#5C9171", "#B39030", "#855757"))+
  ggtitle("Chicago, IL USA Alpha Diversity 2021")+
  theme(plot.title = element_text(hjust = 0.5))+ # this will center your title
  xlab("Longitude")+
  ylab("Latitude")+
  labs(size = "Detection frequency") # to edit label on detections legend title
```
<p float="left">
  <img src="./plots/alpha_diversity.jpg" alt="Alpha diversity, Chicago in 2021" width="500" height="auto" />
</p>

 We could also bin our data in groups to make the map a bit more clear

 ```R
# check data range and use to inform bins
range(sp_rich$sp_det)

sp_rich_bin <- sp_rich %>% 
  mutate(det_size = case_when(
    sp_det >= 10 ~ "10+ detections",
    sp_det <= 6 ~ "6-9 detections",
    sp_det > 6 | sp_det < 10 ~ "< 6 detections",
    FALSE ~ as.character(sp_det)))

# convert det_size to a factor
sp_rich_bin <- sp_rich_bin %>% 
  mutate(det_size = as.factor(det_size))

# using the forcats library, we can relevel det_size to correct order
library(forcats)
sp_rich_bin <- sp_rich_bin %>% 
  mutate(det_size = fct_relevel(det_size, c("< 6 detections", "6-9 detections", "10+ detections")))

ggmap::ggmap(chicago) +
  geom_point(aes(x = DD_Long, y = DD_Lat, size = det_size, color = det_size), 
             stroke = 1, shape = 1, 
             data = sp_rich_bin) +
  scale_size_discrete(breaks=c(1,2,3))+
  scale_shape_manual(values= c(17))+
  ggtitle("Chicago, IL USA Alpha Diversity 2021")+
  theme(plot.title = element_text(hjust = 0.5))+ # this will center your title
  xlab("Longitude")+
  ylab("Latitude")+
  labs(color = "Detection frequency") # to edit label on detections legend title
```
<p float="left">
  <img src="./plots/bin_alpha_diversity.jpg" alt="Alpha diversity, Chicago in 2021" width="500" height="auto" />
</p>

We can also do this for groups of species. Let's 1) examine all the species in our study area, 2) filter down to carnivore species and 3) make a plot of counts of unique carnivore species detected at each of our sites (similar to above) 

<details closed><summary>Solution</a></summary>  

```R
unique(sp_data_2021$commonName)

native_carn <- sp_data_2021 %>% 
  filter(commonName == "American mink" | commonName == "Coyote"| commonName == "Raccoon"
         | commonName == "Striped Skunk"| commonName == "Red fox")

carn_rich <- native_carn %>% 
  group_by(locationAbbr) %>% # group by location to summarise all species detections
  mutate(sp_det = length(unique(commonName))) %>% 
  ungroup() %>% # ungroup data to retain additional information like lat/long
  distinct(sp_det, locationAbbr, DD_Long, DD_Lat) # define the column to keep 

# mapping alpha diversity for native carnivores
ggmap::ggmap(chicago) +
  geom_point(aes(x = DD_Long, y = DD_Lat, size = sp_det), shape = 1, stroke = 1, data = carn_rich) +
  # scale_shape_manual(values= c(21, 22, 23))+
  ggtitle("Chicago, IL USA Native Carnivore Alpha Diversity 2021")+
  theme(plot.title = element_text(hjust = 0.5))+ # this will center your title
  xlab("Longitude")+
  ylab("Latitude")+
  labs(size = "Detections") # to edit label on detections legend title
```
 <p float="left">
  <img src="./plots/carn_alpha_diversity.jpg" alt="Alpha Diversity of carnivores in Chicago, 2021" width="500" height="auto" />
</p>

</details>

### Using other raster layers
We can also build these plots with other geospatial layers. We can use the [European Space Agency's global landcover layer](https://worldcover2020.esa.int/) for an example. This is a great mapping layer as it is a free, fine-scale (10m resolution), dataset which covers landcover globally across 10 classes: "Tree cover", "Shrubland", "Grassland", "Cropland", "Built-up", "Bare / sparse vegetation”, “Snow and Ice”, “Permanent water bodies”, “Herbaceous Wetland”, “Mangrove” and “Moss and lichen". See [ESA's product details document](https://blog.vito.be/remotesensing/release-of-the-10-m-worldcover-map) for more information.

```R
# install packages 
install.packages("sf")
install.packages("terra")
install.packages("rgdal")
install.packages("tidyterra")
install.packages("devtools")

# load in libraries
library(sf)
library(terra)
library(rgdal)
library(tidyterra)
library(devtools)

# convert latitude/longitude data into spatial data by assigning the appropriate crs
sites = sf::st_as_sf(     #sf = spatial tool
  sp_data,
  coords = c("DD_Long", "DD_Lat"), # note these labels coordinate with labeling in your csv
  crs = 4326)                          # if you used lat/long in your .csv, use that here.                       
```

Above we are telling R that sp_data contains spatial data in DD_long and DD_lat. Classifying these data as 'spatial' will allow us to set our mapping layer to the appropriate CRS, or coordinator reference system, to further manipulate the map. This is helpful if you are reading in a large map that needs to be cropped to a specific region. 

```R
# read in raster layer
my_map = rast("/Chicago_merged.tif") #path to where raster layer is

# Transform your site data into data which is cohesive with the ESA raster
dat <- sf::st_transform(
  sites,
  crs = crs(my_map)
)

# Crop map around buffer area of sites
crop <- crop(my_map, ext(sf::st_bbox(dat)[c("xmin","xmax","ymin","ymax")] +
                              c(-.05,.05,-.05,.05)))

# Plot cropped map and points
plot(crop)
points(sf::st_coordinates(dat), pch = 19)
```

<p float="left">
  <img src="./plots/chi_sites.png" alt="Map of camera sampling sites across Chicago landcover" width="500" height="auto"/>
  <img src="./plots/landcover_class.png" alt="Key to ESA landcover classes" width="250" height="auto"/>
</p>

Note that the map key does not include all values in the ESA landcover key. This is because `plot()` is only plotting the values in the plotted extent.

We will continue to use `ggplot` to visualize our data with a few adaptations to the previous code. Unlike the standard `plot` function, `ggplot` requires specific data-types which are in the form of a *data.frame* or *SpatRaster*. Though we could simply convert our map, `crop`, using `as.data.frame()`, it would take a very long time to process and will likley fail to plot depending on your computers local storage. Rather, we can use the ggplot function `geom_spatraster(data = crop)` by installing the package `tidyterra` (done above) which was developed by Diego Hernangómez (more on tidyterra [here](https://dieghernan.github.io/tidyterra/)). 

```R
ggplot() +
  geom_spatraster(data = crop, aes(fill = Chicago_merged))+
  ggtitle("Chicago, IL USA Land cover")
```
<p float="left">
  <img src="./plots/carn_alpha_diversity_gradient.jpg" alt="Map of Chicago landcover" width="500" height="auto" />
</p>

We can see that the default map plots landcover as a continue variable leading to the blue gradient in the key. We can make these discrete with a few additions to the ggplot command. We can also use our previous code to plot alpha diversity across all of our study sites. 

```R
ggplot() +
  geom_spatraster(data = crop)+
  #facet_wrap(~lyr, ncol = 1)+
  coord_sf(crs = 4326)+
  scale_fill_whitebox_c(
    palette = "muted",
    labels = c("NA","Tree", "Shrubland", "Grassland", "Cropland", "Built",
               "Bare/ spare vegetation", "Snow and Ice", "Permanent water", "Herbaceous wetlands"),
    n.breaks = 9,
    guide = guide_legend(reverse = TRUE))+
  scale_x_continuous(expand = expansion(0))+ # expands plot to axes
  scale_y_continuous(expand = expansion(0))+
  geom_point(aes(x = DD_Long, y = DD_Lat, color = sp_det), size = 2,
             data = sp_rich)+ #this adds location point data
  ggtitle("Chicago, IL USA Native Carnivore Alpha Diversity 2021")+
  theme(plot.title = element_text(hjust = 0.5))+ # this will center your title
  xlab("Longitude")+
  ylab("Latitude")+
  labs(fill = "Landcover Class")+ # change legend title
  labs(color = "Detections")+ # to edit label on detections legend title
  scale_color_gradient(low="lightblue", high="navy") # we can manually change the scale color pallet
```
<p float="left">
  <img src="./plots/carn_alpha_diversity_ESA.jpg" alt="Map of Alpha Diversity across Chicago, 2021" width="500" height="auto" />
</p>
Nice work! There are lots of other ways we can manipulate and visualize spatial data and we're off to a good start.
