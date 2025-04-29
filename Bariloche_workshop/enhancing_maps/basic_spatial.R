## install & load libraries---------------------------------------------------------------
devtools::install_github("mfidino/uwinspatialtools")

library(devtools)
library(sf)
library(uwinspatialtools)
library(terra)
library(ggplot2)
library(dplyr)
library(ggpubr)
library(tidyr)
library(ggpubr)

# Read in site data
site_coords = read.csv("./data/bariloche_sample.csv", stringsAsFactors = FALSE)
names(site_coords)[1] = 'sites'


# create spatial points
# be sure to use the correct CRS for your spatial data type
# for example WGS84 = 4326
# https://www.nceas.ucsb.edu/sites/default/files/2020-04/OverviewCoordinateReferenceSystems.pdf

sites = sf::st_as_sf(     #sf = spatial tool
  site_coords,
  coords = c("longitude", "latitude"), # note these labels coordinate with labeling in your csv
  crs = 4326)                          # if you used lat/long in your .csv, use that here                       

# Global Datasets---------------------------------------------------------------
# Read in Climate Data Store Data
# https://cds.climate.copernicus.eu/datasets/satellite-land-cover?tab=download
my_map = rast("./data/CCS-Map-300m-P1Y-2022-Argentina.nc")

# we will subset the raster to just the landcover data
my_map <- my_map$lccs_class

# view map
plot(my_map)

# transform site data to correct CRS
dat <- sf::st_transform(
  sites,
  crs = crs(my_map)
)

# crop map to buffered extent around site locations
crop <- crop(my_map, ext(sf::st_bbox(dat)[c("xmin","xmax","ymin","ymax")] +
                           c(-.05,.05,-.05,.05)))

# plot cropped map and plot sampling points
plot(crop)
points(sf::st_coordinates(dat), pch = 19)


# calculate proportion of landcover buffered around sampling sites
# this list is based on documentation of landcover values for your spatial data
# https://cds.climate.copernicus.eu/datasets/satellite-land-cover?tab=download

# note not all land cover types will be present in your study area and may issue a warning
landcover.data_CCS <- extract_raster_prop(
  sites,
  "sites",
  1000, # sampling buffer in meters
  my_map,
  lulc_cats = list(
    "cropland, rainfed" =	10,
    "herbaceous cover" =	11,
    "tree or shrub cover" =	12,
    "cropland, irrigates, or post-flooding" =	20,
    "mosaic cropland >50%" =	30,
    "mosaic natural vegetation >50%" =	40,
    "tree cover, evergreen >15%" =	50,
    "tree cover, deciduous >15%" =	60,
    "tree cover, deciduous, closed >40%" =	61,
    "tree cover, deciduous, open 15-40%" =	62,
    "tree cover, needleleaved, evergreen, >15%" =	70,
    "tree cover, needleleaved, evergreen >40%" =	71,
    "tree cover, needleleaved, evergreen, 15-40%" =	72,
    "tree cover, needleleaved, deciduous, >15%" =	80,
    "tree cover, needleleaved, deciduous >40%" =	81,
    "tree cover, needleleaved, deciduous, 15-40%" =	82,
    "tree cover, mixed leaf" =	90,
    "mosaic tree and shrub" =	100,
    "mosaic herbaceous cover" =	110,
    "shrubland" =	120,
    "evergreen shrubland" =	121,
    "deciduous shrubland" =	122,
    "grassland" =	130,
    "lichens and moses" =	140,
    "sparse vegetation (tree, shrub, herbaceous cover)" =	150,
    "spare shrub <15%" =	152,
    "sparse herbaceous cover <15%" =	153,
    "tree cover, flooded, fresh or brakish water" =	160,
    "tree cover, flooded, saline water" =	170,
    "shrub or herbaceous cover, flooded, fresh/saline/brakish" =	180,
    "urban areas" =	190,
    "bare areas" =	200,
    "consolidated bare areas" =	201,
    "unconcolidates bare areas" =	202,
    "water bodies" =	210,
    "permanent snow and ice" =	220
  )
)


## Plotting Global Data---------------------------------------------------------
# Let's plot out our sites over landcover types and see how they distribute
# to play with colors: http://www.cookbook-r.com/Graphs/Colors_(ggplot2)/

# Look at dominant land cover types around our sites
(landcover_prop <- landcover.data_CCS %>% 
   pivot_longer(cropland..rainfed:permanent.snow.and.ice, names_to = "landcover", values_to = "proportion") %>% 
   filter(proportion > 0) %>% 
   ggplot(aes(x=landcover, y = proportion, fill=landcover)) +
   geom_bar(stat="identity")+
   ylab("Proportion landcover within 1km of all sites")+
   theme(axis.text.x = element_text(angle = 45,hjust=0.95,vjust=.95)))

# clean up plot labels
x_labels <- c(
  "grassland" = "grassland",
  "herbaceous.cover" = "herbaceous cover",
  "mosaic.cropland..50." = "mosaic cropland >50%",
  "mosaic.herbaceous.cover" = "mosaic herbaceous cover",
  "mosaic.natural.vegetation..50." = "mosaic natural vegetation >50%",
  "mosaic.tree.and.shrub" = "mosaic tree and shrub",
  "shrubland" = "shurbland",
  "sparse.vegetation..tree..shrub..herbaceous.cover." = "sparse vegetation with tree, shrub, & herbaceous cover. ",
  "tree.cover..deciduous..15." = "tree cover deciduous >15%",
  "tree.cover..deciduous..closed..40." = "tree cover deciduous closed >40%",
  "tree.cover..deciduous..open.15.40." = "tree cover deciduous open 15-40%",
  "tree.cover..evergreen..15." = "tree cover evergreen >15%",
  "tree.cover..mixed.leaf" = "tree cover mixed leaf",
  "urban.areas" = "urban areas",
  "water.bodies" = "water bodies"
)

# Generate a palette of 15 distinct colors, feel free to choose your own
col <- c("#A2CF48", "#369C17", "#DBD253", "#A19E4D", "#4F7827", "#6B8C65", "#84B878", 
         "#7FA145", "#BBE6D5", "#335925", "#3D7344", "#3A803D", "#48B356", "#7D7E82", "#2B93A8")

# plot again with cleaned names
(landcover_prop_CCS <- landcover.data_CCS %>% 
    pivot_longer(cropland..rainfed:permanent.snow.and.ice, names_to = "landcover", values_to = "proportion") %>% 
    filter(proportion > 0) %>% 
    ggplot(aes(x=landcover, y = proportion, fill=landcover)) +
    geom_bar(stat="identity")+
    ylab("Proportion landcover within 1km of all sites")+
    scale_x_discrete(labels = x_labels) +
    scale_fill_manual(values = col, labels = x_labels) +  # Custom legend labels
    theme(axis.text.x = element_text(angle = 60,hjust=0.95,vjust=.95)))


# Built Area
urban = ggplot(landcover.data_CCS, aes(urban.areas)) + 
  geom_histogram( binwidth=.1, fill="#7D7E82", color="#7D7E82", alpha=0.9) +
  #ggtitle("Percent urban") +
  expand_limits(x = c(0, 1))+
  xlab("percent urban")+
  ylab("site count")+
  theme(
    plot.title = element_text(size=15)
  )

# Evergreen tree cover 
evergreen = ggplot(landcover.data_CCS, aes(tree.cover..evergreen..15.)) + 
  geom_histogram( binwidth=.1, fill="#0D5E1B", color="#0D5E1B", alpha=0.9) +
  #ggtitle("Percent evergreen tree cover >15%") +
  expand_limits(x = c(0, 1))+
  xlab("Percent evergreen tree cover")+
  ylab("site count")+
  theme(
    plot.title = element_text(size=15)
  )

# mosaic tree and shrub
forest = ggplot(landcover.data_CCS, aes(mosaic.tree.and.shrub)) + 
  geom_histogram( binwidth=.1, fill="#6B8C65", color="#6B8C65", alpha=0.9) +
  #ggtitle("percent mosaic tree and shrub") +
  expand_limits(x = c(0, 1))+
  xlab("percent mosaic tree and shrub")+
  ylab("site count")+
  theme(
    plot.title = element_text(size=15)
  )

# shrubland 
shrubland = ggplot(landcover.data_CCS, aes(shrubland)) + 
  geom_histogram( binwidth=.1, fill="#84B878", color="#84B878", alpha=0.9) +
  #ggtitle("Percent shrubland") +
  expand_limits(x = c(0, 1))+
  xlab("percent shrubland")+
  ylab("site count")+
  theme(
    plot.title = element_text(size=15)
  )

# deciduous tree cover
deciduous = ggplot(landcover.data_CCS, aes(tree.cover..deciduous..15.)) + 
  geom_histogram( binwidth=.1, fill="#7FA145", color="#7FA145", alpha=0.9) +
  #ggtitle("percent deciduous tree >15%") +
  expand_limits(x = c(0, 1))+
  xlab("percent deciduous tree >15%")+
  ylab("site count")+
  theme(
    plot.title = element_text(size=15)
  )

# water 
water = ggplot(landcover.data_CCS, aes(water.bodies)) + 
  geom_histogram( binwidth=.1, fill="#2B93A8", color="#2B93A8", alpha=0.9) +
  #ggtitle("Percent water") +
  expand_limits(x = c(0, 1))+
  xlab("percent water")+
  ylab("site count")+
  theme(
    plot.title = element_text(size=15)
  )

ggarrange(urban, evergreen, forest, shrubland, deciduous, water,
                  labels = c("A", "B", "C", "D", "E", "F"),
                  ncol = 2, nrow = 3)

# Now we can compare our site distributions across our new OSM enhanced map
OSM_map = rast("./data/Bariloche_enhanced_lcover.tif")

# view map
plot(OSM_map)

# transform site data to correct CRS
OSM_dat <- sf::st_transform(
  sites,
  crs = crs(OSM_map)
)

# crop map to buffered extent around site locations
OSM_crop <- crop(OSM_map, ext(sf::st_bbox(OSM_dat)[c("xmin","xmax","ymin","ymax")] +
                           c(-.05,.05,-.05,.05)))

# plot cropped map and plot sampling points
plot(OSM_crop)
points(sf::st_coordinates(OSM_dat), pch = 19)

# note not all land cover types will be present in your study area and may issue a warning
landcover.data_OSM <- extract_raster_prop(
  sites,
  "sites",
  1000, # sampling buffer in meters
  OSM_map,
  lulc_cats = list(
    # "industrial" = 1, 
    # "commercial" = 2,
    # "institutional" = 3,
    "residential" = 4,
    #"landuse_railway" = 5,
    "open green" = 6,
    "protected area" = 7,
    "resourceful area" = 8,
    "heterogeneous green area" = 9,
    "barren soil" = 10,
    "dense green area" = 11,
    "water" = 12,
    "parking surface" = 13,
    "buildings" = c(1:3,14),
    "roads" = c(5, 15:23, 25),
    #"roads (v.h. traffic)" = 15,
    # "sidewalks" = 16, 
    # "roads_na" = 17,
    # "roads (v.l. traffic)" = 18,
    # "roads (l. traffic)" = 19,
    # "roads (m. traffic)" = 20,
    # "roads (h.t.l.s)" = 21,
    # "roads (h.t.h.s)" = 22,
    # "trams/streetcars" = 23,
    "walking trails" = 24,
    #"railways" = 25, 
    "unused linear feature" = 26,
    "barriers" = 27,
    "mosaic herbaceous cover" = 110,
    "shrubland" = 120, 
    "evergreen shrubland" = 121,
    "deciduous shrubland" = 122,
    "lichens and moses" = 140, 
    "sparse vegetation (tree, shrub, herbaceous cover)" = 150, 
    "tree cover, flooded" = 160,
    "herbaceous, flooded" = 180,
    "permanent snow and ice" = 220
  )
)

col2 <- c("#BFBCAE","#EB1612", "#594141", "#47753F", "#5D8562","#88BDA0",
          "#756969", "#5D9E70","#B8A5C9", "#B5BF5B", "#8C8787", "#74C28E","#9FB386",
          "#7A3837", "#7D7357", "#4D94A8")

# Look at dominant land cover types around our sites
(landcover_prop_OSM <- landcover.data_OSM %>% 
    pivot_longer(residential:permanent.snow.and.ice, names_to = "landcover", values_to = "proportion") %>% 
    filter(proportion > 0) %>% 
    ggplot(aes(x=landcover, y = proportion, fill=landcover)) +
    geom_bar(stat="identity")+
    ylab("Proportion landcover within 1km of all sites")+
    scale_fill_manual(values = col2) +  # Custom legend labels
    theme(axis.text.x = element_text(angle = 50,hjust=0.95,vjust=.95)))

ggarrange(landcover_prop_CCS, landcover_prop_OSM,
          labels = c("A", "B"),
          ncol = 2, nrow = 1)
