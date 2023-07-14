# helpful links
# https://stackoverflow.com/questions/34901615/plotting-points-on-a-map-with-size-depending-on-category-count
# https://ggplot2-book.org/maps.html
# https://stackoverflow.com/questions/47955292/visualizing-two-or-more-data-points-where-they-overlap-ggplot-r

setwd("E:/GitHub/UWIN_tutorials/tutorials/Detection Mapping")

# load in libraries
library(readr)
library(tidyr)
library(dplyr)
library(broom)
library(ggplot2)
library(ggExtra)
library(maps)
library(RColorBrewer)

sp_data <- read_csv("CHIL_Detections.csv")

# make new column which categorizes by the year
sp_data <- sp_data %>% 
  mutate(year = if_else(photoDateTime > '2021-12-31 11:59:59', 2022, 2021))

# # get unique locations from data to build map 
# sites <- sp_data %>% 
#   distinct(locationAbbr, DD_Long, DD_Lat) 

# let's focus on 2021 since we have all four seasons for this data set
sp_data_2021 <- sp_data %>% filter(year == 2021)

# group by species to gather the number of detections collected for this year
sp_det <- sp_data_2021 %>% 
  group_by(commonName) %>% 
  summarise(detections = n())

# we can confirm we have all the species by looking at unique species seen in 2021
unique(sp_data_2021$commonName)

# lets run this for ones species
raccoon_det_2021 <- sp_data_2021 %>% 
  filter(commonName == "Raccoon")

# count detections by location
raccoon_sum <- raccoon_det_2021 %>% 
  group_by(locationAbbr) %>% 
  mutate(detections = n()) %>% 
  ungroup() %>% 
  distinct(commonName, detections, locationAbbr, DD_Long, DD_Lat) 


library(ggmap)
library(osmdata)

#chicago = get_map(location = getbb("chicago"), zoom = 10, scale = 1, source = "stamen")
# this may take a few minutes ot load 
#my_map = ggmap::ggmap(chicago)

#devtools::install_github("dkahle/ggmap", ref = "tidyup")
library(ggmap)
?get_stamenmap
chicago <- get_stamenmap(bbox = c(left = -88.3, bottom = 41.55, 
                                  right = -87.4, top = 42.3), 
                         zoom = 11)
ggsave("raccoon_map.tiff", width = 6, height = 6)
ggmap::ggmap(chicago) +
  geom_point(aes(x = DD_Long, y = DD_Lat, colour = commonName, size = detections), data = raccoon_sum)

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

ggsave("coyote_map.tiff", width = 6, height = 6)
ggmap::ggmap(chicago) +
  geom_point(aes(x = DD_Long, y = DD_Lat, colour = commonName, size = detections), data = coyote_sum)


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

# If we look closely we can see that all the raccoon detections appear to be on this map 
# but by referencing the last map, it seems we are missing coyote detections. Whats
# happening it that the raccoon detections are overlapping and overwritting them as 
# those detections are plotted last

# we can fix this by changing rhe shapes and add a bit of randomness to their location
# using the jitter() function

ggsave("species_map.tiff", width = 6, height = 6)
ggmap::ggmap(chicago) +
  geom_point(aes(x = DD_Long, y = DD_Lat, colour = commonName, size = detections, 
                 shape = commonName), stroke = 1, data = carnivore_sum, 
             position=position_jitter(h=0.01,w=0.01)) +
  scale_shape_manual(values= c(21, 22, 23))  

# We can also clean up our labels and axes 
ggsave("species_map_final.tiff", width = 6, height = 6)
ggmap::ggmap(chicago) +
  geom_point(aes(x = DD_Long, y = DD_Lat, colour = commonName, size = detections, 
                 shape = commonName), stroke = 1, data = carnivore_sum, 
             position=position_jitter(h=0.01,w=0.01)) +
  scale_shape_manual(values= c(21, 22, 23))+
  ggtitle("Chicago, IL USA Detections 2021")+
  theme(plot.title = element_text(hjust = 0.5))+ # this will center your title
  xlab("Longitude")+
  ylab("Latitude")+
  labs(color = "Species")+ # to edit labels on color/shape legend title
  labs(shape = "Species")+
  labs(size = "Detections") # to edit label on detections legend title

# If there is a certain area of interest, we can also update our bounding box to focus on a certain 
# region
# lincoln_park_sum <- carnivore_sum %>% 
#   filter(DD_Long >= 41.8 | DD_Long <= 41.5 | DD_Lat >= -87.5 | DD_Lat <= -87.7)

lincoln_park <- get_stamenmap(bbox = c(left = -87.7, bottom = 41.9, 
                                  right = -87.6, top = 42.0), 
                         zoom = 12)

ggsave("species_map_LP.tiff", width = 6, height = 6)
ggmap::ggmap(lincoln_park) +
  geom_point(aes(x = DD_Long, y = DD_Lat, colour = commonName, size = detections, 
                 shape = commonName), stroke = 1, data = carnivore_sum, 
             position=position_jitter(h=0.0025,w=0.0025)) +
  scale_shape_manual(values= c(21, 22, 23))+
  ggtitle("Lincoln Park, IL USA Detections 2021")+
  theme(plot.title = element_text(hjust = 0.5))+ # this will center your title
  xlab("Longitude")+
  ylab("Latitude")+
  labs(color = "Species")+ # to edit labels on color/shape legend title
  labs(shape = "Species")+
  labs(size = "Detections") # to edit label on detections legend title

# or even more detailed
# Note that we need to adjust the 'zoom' every time we focus on a smaller area to increase clarity of 
# the map image 
# we also need to decrease the 'jitter' so we can tell what detections are reletive to what sites
montrose <- get_stamenmap(bbox = c(left = -87.652, bottom = 41.950, 
                                       right = -87.620, top = 41.975), 
                              zoom = 14)

ggsave("species_map_montrose.tiff", width = 6, height = 6)
ggmap::ggmap(montrose) +
  geom_point(aes(x = DD_Long, y = DD_Lat, colour = commonName, size = detections, 
                 shape = commonName), stroke = 1, data = carnivore_sum, 
             position=position_jitter(h=0.001,w=0.001)) +
  scale_shape_manual(values= c(21, 22, 23))+
  ggtitle("Montrose, IL USA Detections 2021")+
  theme(plot.title = element_text(hjust = 0.5))+ # this will center your title
  xlab("Longitude")+
  ylab("Latitude")+
  labs(color = "Species")+ # to edit labels on color/shape legend title
  labs(shape = "Species")+
  labs(size = "Detections") # to edit label on detections legend title

# It can be hard to overlap all species of interest so it's best to do this in small groups
# or we can also map alpha diversity, or species richness (number of species), in a given wildlife community

sp_rich <- sp_data_2021 %>% 
  group_by(locationAbbr) %>% # group by location to summarise all species detections
  mutate(detections = n()) %>% # count the number of detectionsat each site
  ungroup() %>% # ungroup data to retain additional information like lat/long
  distinct(detections, locationAbbr, DD_Long, DD_Lat) # define the column to keep 

# mapping alpha diversity
ggsave("alpha_diversity.tiff", width = 6, height = 6)
ggmap::ggmap(chicago) +
  geom_point(aes(x = DD_Long, y = DD_Lat, size = detections), stroke = 1, data = sp_rich, 
             position=position_jitter(h=0.01,w=0.01)) +
 # scale_shape_manual(values= c(21, 22, 23))+
  ggtitle("Chicago, IL USA Alpha Diversity 2021")+
  theme(plot.title = element_text(hjust = 0.5))+ # this will center your title
  xlab("Longitude")+
  ylab("Latitude")+
  labs(size = "Detections") # to edit label on detections legend title

# we can also do this for groups of species, like alpha diversity of native carnivores
# first we need to filter data to only these species
unique(sp_data_2021$commonName)

native_carn <- sp_data_2021 %>% 
  filter(commonName == "American mink" | commonName == "Coyote"| commonName == "Raccoon"
         | commonName == "Striped Skunk"| commonName == "Red fox")

carn_rich <- native_carn %>% 
  group_by(locationAbbr) %>% # group by location to summarise all species detections
  mutate(detections = n()) %>% # count the number of detectionsat each site
  ungroup() %>% # ungroup data to retain additional information like lat/long
  distinct(detections, locationAbbr, DD_Long, DD_Lat) # define the column to keep 

# mapping alpha diversity for native carnivores
ggsave("carn_alpha_diversity.tiff", width = 6, height = 6)
ggmap::ggmap(chicago) +
  geom_point(aes(x = DD_Long, y = DD_Lat, size = detections), stroke = 1, data = carn_rich) +
  # scale_shape_manual(values= c(21, 22, 23))+
  ggtitle("Chicago, IL USA Native Carnivore Alpha Diversity 2021")+
  theme(plot.title = element_text(hjust = 0.5))+ # this will center your title
  xlab("Longitude")+
  ylab("Latitude")+
  labs(size = "Detections") # to edit label on detections legend title

# We could also use difference base maps to make this plot. We can use ESA landcover maps as an example----


# species richness (color for zero sp. detections)


# Let's do this over a landcover map. For an exmaple, we can use ESA data
# see: 
# download libraries
library(devtools)
library(sf)
library(uwinspatialtools)
library(raster)
library(rgdal)
library(FedData)

# make this data spatial data by assigning the appropriate crs
sites = sf::st_as_sf(     #sf = spatial tool
  sp_data,
  coords = c("DD_Long", "DD_Lat"), # note these labels coordinate with labeling in your csv
  crs = 4326)                          # if you used lat/long in your .csv, use that here.                       


# read your raster in
my_map = raster("E:/GitHub/Partner_Transects/ESA_landcover/Chicago/Chicago_merged.tif") #path to where raster data is

# Transform your site data into data which is cohesive with the ESA raster
dat <- sf::st_transform(
  sites,
  crs = projection(my_map)
)

crop <- crop(my_map, extent(sf::st_bbox(dat)[c("xmin","xmax","ymin","ymax")] +
                              c(-.0,.0,-.0,.0)))

# crop <- crop(my_map, extent(sf::st_bbox(c(xmin = -88.3, xmax = -87.45, ymin = 41.6, ymax = 42.3)) +
#                               c(-.0,.0,-.0,.0)))
plot(crop)
points(sf::st_coordinates(dat), pch = 19)

crop_stack <- stack(crop)
crop_df <- as.data.frame(crop_stack, xy = TRUE) %>% 
  drop_na()

# need space work around for this
gc() # garbage collection helps clear up space
ggplot() +
  geom_raster(aes(x = x, y = y, fill = Chicago_merged), data = crop_df)+
  scale_fill_viridis_c() +
  theme_void() 

# need to figure this out in base R
plot(crop)
points(sf::st_coordinates(dat), col = unique(carnivore_sum$commonName))

plot(carnivore_sum$DD_Long, carnivore_sum$DD_Lat, col = alpha("black", .2), add = TRUE)
