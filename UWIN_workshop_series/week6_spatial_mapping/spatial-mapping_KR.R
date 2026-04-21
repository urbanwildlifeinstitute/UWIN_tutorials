# UWIN tutorial - Spatial Mapping

setwd("D:/GitHub/UWIN_tutorials/tutorials/week6_spatial_mapping")

library(dplyr)
library(tidyr)
library(ggplot2)

library(sf)
library(terra)

library(rosm)
library(tmap)
library(leaflet)

packages_needed <-c("dplyr", "tidyr","tidyterra","sf","terra","ggplot2","tmap","leaflet","rosm")

for (i in packages_needed){
  if(!(i %in% installed.packages())){
    install.packages(i, dependencies = TRUE)
  }
  require(i)
}

captures.table <- read.csv("data/captures.csv")
head(captures.table) 

captures.spatial <- st_as_sf(captures.table,
                             coords = c("longitude","latitude"), 
                             crs = 4326)
head(captures.spatial)

ggplot(captures.spatial) + geom_sf()

#now we plot, and we'll make it interactive that will add a basemap automatically
tmap_mode(mode = c("view")) #to return to static use "plot" 

tm_shape(captures.spatial) +
  tm_dots(size = 0.1, col="black")

#download background file from OpenStreetMap using the extent of the captue data
bg = rosm::osm.raster(st_bbox(captures.spatial)) #get background from OSM using our layer's extent/bbox
bg[bg[]>255]=255 #little trick to make sure the reprojection doesn't mess up with the rgb values.
bg[bg[]<0]=0
 
#Now we plot in static mode
tmap_mode(mode = c("plot"))

#we add the background basemap 
tm_shape(bg) +
  tm_rgb() + #background is an rgb file
  tm_shape(captures.spatial) + #overlays over the camera trap data points
  tm_dots(size = 0.1, col="black")

# Filter for coyote detections and count the number at each location
coyotes <- filter(captures.spatial, speciesname == "Canis latrans") %>%
  group_by(locationid) %>%
  summarize(detections = n())

# Draw the map
tm_shape(bg) +
  tm_rgb() + #background is an rgb file
  tm_shape(coyotes) + #overlays the camera trap data points
  tm_dots(size = "detections", col="black", #determine size will change with detection freq.
          sizes.legend = seq(100,500, by=100), #define break interval
          title.size = "frequency")+        #chnge title for the size variable
  tm_layout(title = "Coyote detections")  + #plot title
  tm_compass(position = c("right", "top")) + #add compass
  tm_scale_bar() +                          #add scale 
  tm_credits("Author, 2024")                #add credits

# Try yourself
# Filter for coyote detections and count the number at each location
raccoons <- filter(captures.spatial, speciesname == "Procyon lotor") %>%
  group_by(locationid) %>%
  summarize(detections = n())

# Draw the map
tm_shape(bg) +
  tm_rgb() + #background is an rgb file
  tm_shape(raccoons) + #overlays the camera trap data points
  tm_dots(size = "detections", col="black", #determine size will change with detection freq.
          sizes.legend = seq(100,500, by=100), #define break interval
          title.size = "frequency")+        #chnge title for the size variable
  tm_layout(title = "Raccoon detections")  + #plot title
  tm_compass(position = c("right", "top")) + #add compass
  tm_scale_bar() +                          #add scale 
  tm_credits("Author, 2024")                #add credits
