# helpful links
# https://stackoverflow.com/questions/34901615/plotting-points-on-a-map-with-size-depending-on-category-count
# https://ggplot2-book.org/maps.html
# https://stackoverflow.com/questions/47955292/visualizing-two-or-more-data-points-where-they-overlap-ggplot-r
# https://onlinelibrary.wiley.com/doi/full/10.1111/ecog.05787

setwd("E:/GitHub/UWIN_tutorials/tutorials/Detection Mapping")

# load in libraries
library(readr)
library(tidyr)
library(dplyr)
#library(broom)
library(ggplot2)
#library(ggExtra)
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

sp_det
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


# https://builtin.com/data-science/ggmap
install.packages("ggmap")
library('ggmap')
install.packages('osmdata')
library(osmdata)

my_api <- 'AIzaSyBt73bzxdvlS6ioit4OTCaIE6SrZJ9aWnA'
register_google(key = my_api)

#library(osmdata)

#chicago = get_map(location = getbb("chicago"), zoom = 10, scale = 1, source = "stamen")
# this may take a few minutes ot load 
#my_map = ggmap::ggmap(chicago)

#devtools::install_github("dkahle/ggmap", ref = "tidyup")
#https://www.r-bloggers.com/2018/10/getting-started-stamen-maps-with-ggmap/
# http://maps.stamen.com/#watercolor/12/37.7706/-122.3782
?get_map()
# chicago <- get_stamenmap(bbox = c(left = -88.3, bottom = 41.55, 
#                                   right = -87.4, top = 42.3), 
#                          zoom = 11)
chicago <- get_map("chicago", source= "google", api_key = my_api)
ggmap(chicago)
ggsave("plots/chicago_map_region.jpg", width = 6, height = 6)

chicago <- get_map(c(left = -88.3, bottom = 41.55, right = -87.4, top = 42.3), 
                   zoom = 10)
ggmap(chicago)
ggsave("plots/chicago_map_coord.jpg", width = 6, height = 6)

# see difference between base R and ggplot style mapping
plot(chicago)
ggmap(chicago)

# we can also pull other types data or other layers from Google Maps
chicago_satellite <- get_map("chicago", maptype= "satellite", source= "google", api_key = my_api)
ggmap(chicago_satellite)
chicago_road <- get_map("chicago", maptype= "roadmap", source= "google", api_key = my_api)
ggmap(chicago_road)

ggmap::ggmap(chicago) +
  geom_point(aes(x = DD_Long, y = DD_Lat, color = commonName, size = detections), 
             data = raccoon_sum) +
  ggtitle("Raccoon detections") +
  labs(size = "Detection frequency") + # updates legend related to size (here 'detections')
  #labs(color = "Species")  # updates legend related to color (here 'commonName')
  guides(color = "none") # a way to drop a certain aspect of the legend (here 'commonName')
ggsave("plots/raccoon_map1.jpg", width = 6, height = 6)

# control more of the graphics with other ggplot commands
ggmap::ggmap(chicago) +
  geom_point(aes(x = DD_Long, y = DD_Lat, size = detections), 
             data = raccoon_sum, color = "dark blue") + # control color of detections
  ggtitle("Raccoon detections") +
  labs(size = "Detection frequency") + # updates legend related to size (here 'detections')
  scale_size_continuous(breaks=seq(50, 300, by=50)) # control breaks of detection counts
ggsave("plots/raccoon_map2.jpg", width = 6, height = 6)

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
  geom_point(aes(x = DD_Long, y = DD_Lat, colour = commonName, size = detections), 
             data = coyote_sum, color = "purple") +
  labs(size = "Detection frequency") +
  ggtitle("Coyote detections")
ggsave("plots/coyote_map.jpg", width = 6, height = 6)

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
ggsave("plots/carn_map.jpg", width = 6, height = 6)

# If we look closely we can see that all the raccoon detections appear to be on this map 
# but by referencing the last map, it seems we are missing coyote detections. Whats
# happening it that the raccoon detections are overlapping and overwritting them as 
# those detections are plotted last

# we can fix this by changing rhe shapes and add a bit of randomness to their location
# using the jitter() function

ggmap::ggmap(chicago) +
  geom_point(aes(x = DD_Long, y = DD_Lat, colour = commonName, size = detections, 
                 shape = commonName), stroke = 1, data = carnivore_sum, 
             position=position_jitter(h=0.01,w=0.01)) +
  scale_shape_manual(values= c(21, 22, 23))  
ggsave("plots/species_map.jpg", width = 6, height = 6)

# We can also clean up our labels and axes 
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
ggsave("plots/species_map_final.jpg", width = 6, height = 6)

# If there is a certain area of interest, we can also update our bounding box to focus on a certain 
# region
# lincoln_park_sum <- carnivore_sum %>% 
#   filter(DD_Long >= 41.8 | DD_Long <= 41.5 | DD_Lat >= -87.5 | DD_Lat <= -87.7)

lincoln_park <- get_stamenmap(bbox = c(left = -87.7, bottom = 41.9, 
                                  right = -87.6, top = 42.0), 
                         zoom = 12)

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
ggsave("plots/species_map_LP.jpg", width = 6, height = 6)

# or even more detailed
# Note that we need to adjust the 'zoom' every time we focus on a smaller area to increase clarity of 
# the map image 
# we also need to decrease the 'jitter' so we can tell what detections are reletive to what sites
montrose <- get_stamenmap(bbox = c(left = -87.652, bottom = 41.950, 
                                       right = -87.620, top = 41.975), 
                              zoom = 14)

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
ggsave("plots/species_map_montrose.jpg", width = 6, height = 6)

# It can be hard to overlap all species of interest so it's best to do this in small groups
# or we can also map alpha diversity, or species richness (number of species), in a given wildlife community

# sp_rich <- sp_data_2021 %>% 
#   group_by(locationAbbr) %>% # group by location to summarise all species detections
#   mutate(detections = n()) %>% # count the number of detectionsat each site
#   ungroup() %>% # ungroup data to retain additional information like lat/long
#   distinct(detections, locationAbbr, DD_Long, DD_Lat) # define the column to keep 

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
  labs(size = "Detections") # to edit label on detections legend title
ggsave("plots/alpha_diversity.jpg", width = 6, height = 6)

# We could also bin our data in groups to make this a bit more clear
median(sp_rich$sp_det)

sp_rich_bin <- sp_rich %>% 
  mutate(det_size = case_when(
    sp_det >= 10 ~ "large",
    sp_det <= 6 ~ "small",
    sp_det > 6 | sp_det < 10 ~ "medium",
    FALSE ~ as.character(sp_det)))

# sp_rich_bin <- sp_rich %>% 
#   mutate(det_size = case_when(
#     sp_det >= 12 ~ 3,
#     sp_det <= 5 ~ 1,
#     sp_det > 5 | sp_det < 12 ~ 2,
#     FALSE ~ as.numeric(sp_det)))

sp_rich_bin <- sp_rich_bin %>% 
  mutate(det_size = as.factor(det_size))

library(forcats)
sp_rich_bin <- sp_rich_bin %>% 
  mutate(det_size = fct_relevel(det_size, c("small", "medium", "large")))

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
  labs(color = "Detections") # to edit label on detections legend title
ggsave("plots/bin_alpha_diversity.jpg", width = 6, height = 6)

# we can also do this for groups of species, like alpha diversity of native carnivores
# first we need to filter data to only these species
unique(sp_data_2021$commonName)

native_carn <- sp_data_2021 %>% 
  filter(commonName == "American mink" | commonName == "Coyote"| commonName == "Raccoon"
         | commonName == "Striped Skunk"| commonName == "Red fox")

carn_rich <- native_carn %>% 
  group_by(locationAbbr) %>% # group by location to summarise all species detections
  mutate(sp_det = length(unique(commonName))) %>% 
 # mutate(detections = n()) %>% # count the number of detections at each site
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
ggsave("plots/carn_alpha_diversity.jpg", width = 6, height = 6)

# we could use same plotting functions to map seasonal detections or diel detections
# by manipulating our dataset to detections of interest!

# We could also use difference base maps to make this plot. We can use ESA landcover maps as an example----


# species richness (color for zero sp. detections)


# Let's do this over a landcover map. For an example, we can use ESA data
# see: 
# download libraries
library(sf)
library(terra)
library(rgdal)
library(tidyterra)
library(devtools)
# library(raster)

# helpful resources
# https://dieghernan.github.io/tidyterra/reference/geom_spatraster.html#source

# make this data spatial data by assigning the appropriate crs
sites = sf::st_as_sf(     #sf = spatial tool
  sp_data,
  coords = c("DD_Long", "DD_Lat"), # note these labels coordinate with labeling in your csv
  crs = 4326)                          # if you used lat/long in your .csv, use that here.                       


# read your raster in
my_map = rast("E:/GitHub/Partner_Transects/ESA_landcover/Chicago/Chicago_merged.tif") #path to where raster data is

# Transform your site data into data which is cohesive with the ESA raster
dat <- sf::st_transform(
  sites,
  crs = crs(my_map)
)

crop <- crop(my_map, ext(sf::st_bbox(dat)[c("xmin","xmax","ymin","ymax")] +
                              c(-.05,.05,-.05,.05)))

png("plots/chi_sites.png", height = 700, width = 700)
plot(crop)
points(sf::st_coordinates(dat), pch = 19)
dev.off()

# help files: https://dieghernan.github.io/tidyterra/
# legend help: chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/https://worldcover2020.esa.int/data/docs/WorldCover_PUM_V1.1.pdf
# plot with breaks
ggplot() +
  geom_spatraster(data = crop, aes(fill = Chicago_merged))+
  ggtitle("Chicago, IL USA Land cover")
ggsave("plots/carn_alpha_diversity_gradient.jpg", width = 6, height = 6)
  #facet_wrap(~lyr, ncol = 1)+
  #coord_sf(crs = 4326)

write.csv(carn_rich, "carn_rich.csv")

# plot with key of landcover
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
  scale_x_continuous(expand = expansion(0))+ #expands plot to axes
  scale_y_continuous(expand = expansion(0))+
  geom_point(aes(x = DD_Long, y = DD_Lat, color = sp_det), size = 2,
             data = sp_rich)+
  ggtitle("Chicago, IL USA Native Carnivore Alpha Diversity 2021")+
  theme(plot.title = element_text(hjust = 0.5))+ # this will center your title
  xlab("Longitude")+
  ylab("Latitude")+
  labs(fill = "Landcover Class")+ # change legend title
  labs(color = "Detections")+ # to edit label on detections legend title+
  scale_color_gradient(low="lightblue", high="navy")
  
ggsave("plots/carn_alpha_diversity_ESA.jpg", width = 6, height = 6)


# playing with color pallet 
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
  scale_x_continuous(expand = expansion(0))+ #expands plot to axes
  scale_y_continuous(expand = expansion(0))+
  geom_point(aes(x = DD_Long, y = DD_Lat, size = detections), stroke = 1, data = carn_rich) +
  ggtitle("Chicago, IL USA Native Carnivore Alpha Diversity 2021")+
  theme(plot.title = element_text(hjust = 0.5))+ # this will center your title
  xlab("Longitude")+
  ylab("Latitude")+
  labs(fill = "Landcover Class")+ # change legend title
  labs(size = "Detections") # to edit label on detections legend title


#playing with labels
m<- c(0,0,0,10,10,1,20,20,2,30,30,3,40,40,4,
                          50,50,5,60,60,6,80,80,8,90,90,9)
mat = matrix(m,ncol=3, byrow = TRUE)
reclass_crop <- classify(crop, mat)
plot(reclass_crop)

ggplot() +
  geom_spatraster(data = reclass_crop, aes(fill = Chicago_merged))+
  facet_wrap(~lyr, ncol = 1)+
  coord_sf(crs = 4326)

ggplot() +
  geom_spatraster(data = crop, na.rm = TRUE, aes(fill = Chicago_merged))+
  facet_wrap(~lyr, ncol = 1)+
  scale_alpha_manual(
    values = cols,
    palette = "muted",
    aesthetics = c("colour", "fill"),
    labels = c("NA","Tree", "Grassland", "Cropland", "Built",
               "Bare/ spare vegetation", "Permanent water", "Herbaceous wetlands"),
    breaks = c("0","10","30","40","50","60","80", "90"),
    guide = guide_legend(reverse = TRUE))+
  coord_sf(crs = 4326)+
  scale_x_continuous(expand = expansion(0)) + 
  scale_y_continuous(expand = expansion(0)) 


