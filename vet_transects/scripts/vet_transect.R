# Vetting new partner sites-----------------------------------------------------
# raster.R
# https://github.com/mfidino/uwinspatialtools/tree/vignettes
# https://r-spatial.github.io/sf/

# install & load libraries-----------------------------------------------------
#devtools::install_github("ropensci/FedData", force = TRUE)
#devtools::install_github("mfidino/uwinspatialtools")

library(devtools)
library(sf)
library(uwinspatialtools)
library(ggpubr)
library(FedData)
library(terra)
library(dplyr)
library(tidyterra)
library(tmap)
library(ggspatial)
library(purrr)

# To map and evaluate UWIN partners, we can use two datasets: ESA global landcover and 
# NLCD dataset which covers North America. 

# Read in your spatial locations-----------------------------------------------
# the best coordinate system is UTM or lat/long
## For .csv data----------------------------------------------------------------
site_coords = read.csv("./data_inputs/chil_coords.csv", stringsAsFactors = FALSE)

## For .kml files---------------------------------------------------------------
kml_file <- "./data_inputs/chil_coords.kml"

### If .kml is multiple layers--------------------------------------------------
# Read in layer names
lyrs <- st_layers(kml_file)$name

# Create an empty list to store each layer
layers_sf <- list()

# Loop through and read each layer
for (nm in lyrs) {
  message("Reading layer: ", nm)
  
  # Try reading it, skip if there’s an error
  layer_data <- try(st_read(kml_file, layer = nm, quiet = TRUE), silent = TRUE)
  
  if (!inherits(layer_data, "try-error")) {
    # Add a column showing where this came from
    layer_data <- layer_data %>% mutate(source_layer = nm)
    layers_sf[[nm]] <- layer_data
  }
}

# Combine all layers into one sf object
site_coords <- bind_rows(layers_sf) %>% 
  select(-"Description")

# Clean data--------------------------------------------------------------------
# Check which column has your site names and rename column
names(site_coords)[1] = 'sites'

# drop any NA columns
site_coords = na.omit(site_coords)

# Confirm lat/long make sense for study area
summary(site_coords)

# Correct any issue data points 
site_coords <- site_coords %>% 
  mutate(Longitude = if_else(Longitude > 0, -Longitude, Longitude))


# Transform spatial data--------------------------------------------------------
# be sure to use the correct CRS for your spatial data type
# for example WGS84 = 4326
# https://www.nceas.ucsb.edu/sites/default/files/2020-04/OverviewCoordinateReferenceSystems.pdf

# changes 'coords' here to naming in 'site_coords'
sites = sf::st_as_sf(     #sf = spatial tool
  site_coords,
  coords = c("Long", "Lat"), # note these labels coordinate with labeling in your csv
  crs = 4326)                          # if you used lat/long in your .csv, use those column names here.                       

# Rough plot of data
ggplot(sites) + geom_sf()

#now we plot, and we'll make it interactive that will add a basemap automatically
tmap_mode(mode = c("view")) #to return to static use "plot" 

tm_shape(sites) +
  tm_dots(size = 0.5, col="black")

# Plotting NLCD data--------------------------------------------------------------------
# More here on NLCD data here: https://www.mrlc.gov/data

# create buffer around site area
city_ext <- ext(sites) + .1
city_poly <- as.polygons(vect(city_ext, crs = crs(sites))) %>%  
  st_as_sf()

nlcd_raster <- get_nlcd(template = city_poly,
                        label = "my_study_area",
                        year = 2019,
                        dataset = "landcover",
                        force.redo = TRUE
)

map_proj <- terra::project(nlcd_raster, crs(sites))
plot(map_proj)
points(sf::st_coordinates(sites), pch = 19)

# Here, we are creating a dataframe with landcover classes for each site using NLCD classifications.
# View classes here: https://www.mrlc.gov/data/legends/national-land-cover-database-class-legend-and-description
# We combined many of these classes, feel free to add your own.
labels <- c(
  "Open Water",
  "Developed, Open Space",
  "Developed, Low Intensity",
  "Developed, Medium Intensity",
  "Developed, High Intensity",
  "Barren Land",
  "Deciduous Forest",
  "Evergreen Forest",
  "Mixed Forest",
  "Shrub/Scrub",
  "Grassland/Herbaceous",
  "Pasture/Hay",
  "Cultivated Crops",
  "Woody Wetlands",
  "Emergent Herbaceous Wetlands"
)

city_ext

# Make pretty plot with landcover classes
# update lat/long naming
ggplot() +
  geom_spatraster(data = map_proj)+
  coord_sf(
    crs = 4326,
    xlim = c(city_ext[1], city_ext[2]),
    ylim = c(city_ext[3], city_ext[4]),
    expand = FALSE,      # <- removes the padding
    clip   = "on"
  ) +
  geom_point(aes(x = Long, y = Lat), size = 2, color = "black",
             data = site_coords)+ #this adds location point data
  ggtitle("NLCD 2019 Site Map")+
  theme(plot.title = element_text(hjust = 0.5))+ # this will center your title
  xlab("Longitude")+
  ylab("Latitude")+
  labs(fill = "Landcover Class")+ # change legend title
  labs(color = "Sites")+
  annotation_north_arrow(
    location = "tr",              # top right corner
    which_north = "true",         # true north
    style = north_arrow_fancy_orienteering(
      text_face = "bold",
      text_size = 12
    ),
    pad_x = unit(0.3, "in"),      # adjust padding
    pad_y = unit(0.3, "in")) +
  annotation_scale(
    location = "bl",              # bottom left corner
    width_hint = 0.3,              # relative width of scale bar
    text_face = "bold",
    text_cex = .8
  )

ggsave("./plots/Chicago_landcover.png", width = 8, height = 8, units = "in")

# Extract landcover data--------------------------------------------------------
# Here, we are creating a dataframe with landcover classes for each site using NLCD classifications.
# View classes here: https://www.mrlc.gov/data/legends/national-land-cover-database-class-legend-and-description
# We combined many of these classes, feel free to add your own.
nlcd_data <- extract_raster_prop(
  sites,
  "sites",
  1000,     #m around site location
  my_raster = map_proj,
  lulc_cats = list(
    water = 11,
    lawn_grass = 21, # impervious surface < 20% and includes parks, golf courses, planted vegetation w/in 30m resolution
    urban_low = 22, # impervious 20-49%
    urban_med = 23, # impervious 50-79%
    urban_high = 24, # impervious surface 80-100%
    forest = 41:43,
    shrub = 51:52,
    herbaceous = 71:74, # grassland, herbaceous plants, moss, and lichen
    wetland = c(90,95), # woody wetlands and herbaceous wetlands
    ag = 81:82 # pasture/hay and cultivated crops
  )
)

# Look at dominant land cover types
(landcover_prop <- nlcd_data %>% 
    pivot_longer(water:ag, names_to = "landcover", values_to = "proportion") %>% 
    ggplot(aes(x=landcover, y = proportion, fill=landcover)) +
    geom_bar(stat="identity")+
    theme_minimal())

# Urban_low space
urban_low = ggplot(nlcd_data, aes(urban_low)) + 
  geom_histogram( binwidth=.1, fill="pink", color="pink", alpha=0.9) +
  ggtitle("20-49% Impervious") +
  expand_limits(x = c(0, 1))+
  xlab("Proportion Urban")+
  ylab("site count")+
  theme(
    plot.title = element_text(size=15)
  )

# Urban_med space
urban_med = ggplot(nlcd_data, aes(urban_med)) + 
  geom_histogram( binwidth=.1, fill="#E84C4CFF", color="#E84C4CFF", alpha=0.9) +
  ggtitle("50-79% Impervious") +
  expand_limits(x = c(0, 1))+
  xlab("Proportion Urban")+
  ylab("site count")+
  theme(
    plot.title = element_text(size=15)
  )

# Urban_low space
urban_high = ggplot(nlcd_data, aes(urban_high)) + 
  geom_histogram( binwidth=.1, fill=c("#990909FF"), color=c("#990909FF"), alpha=0.9) +
  ggtitle("80-100% Impervious") +
  expand_limits(x = c(0, 1))+
  xlab("Proportion Urban")+
  ylab("site count")+
  theme(
    plot.title = element_text(size=15)
  )

# Urban Green space 
urban_green = ggplot(nlcd_data, aes(lawn_grass)) + 
  geom_histogram( binwidth=.1, fill=c("#15C20F"), color="#15C20F", alpha=0.9) +
  ggtitle("< 20% Impervious") +
  expand_limits(x = c(0, 1))+
  xlab("Proportion Lawn Grass")+
  ylab("site count")+
  theme(
    plot.title = element_text(size=15)
  )

# Forest space 
forest = ggplot(nlcd_data, aes(forest)) + 
  geom_histogram( binwidth=.1, fill=c("#37733C"), color="#37733C", alpha=0.9) +
  ggtitle("Proportion Forest") +
  expand_limits(x = c(0, 1))+
  xlab("Proportion Forest")+
  ylab("site count")+
  theme(
    plot.title = element_text(size=15)
  )

ag = ggplot(nlcd_data, aes(ag)) + 
  geom_histogram( binwidth=.1, fill="#FFCC00", color="#FFCC00", alpha=0.9) +
  ggtitle("Proportion Agriculture") +
  expand_limits(x = c(0, 1))+
  xlab("Proportion Agriculture")+
  ylab("site count")+
  theme(
    plot.title = element_text(size=15)
  )


ggpubr::ggarrange(urban_low, urban_med, urban_high, urban_green, ncol = 2, nrow = 2)
ggsave("./plots/Chicago_urban.png", width = 8, height = 8, units = "in")


# Evaluate distance between sites-----------------------------------------------
unq = distinct(sites[,"sites"]) 

# double check to make sure all sites are unique,
# This should be 0
if(
  sum(
    duplicated(unq$sites)
  ) > 0
){
  stop("You have duplicate site names, fix these!")
} 

site_dist <- sf::st_distance(unq) 

site_dist <- matrix(
  as.numeric(site_dist),
  ncol = ncol(site_dist),
  nrow = nrow(site_dist)
)

colnames(site_dist) <- site_coords$sites

idx <- upper.tri(site_dist, diag = FALSE) # ID's where column > row
pair_tbl <- tibble::tibble(
  site_i = rownames(site_dist)[row(site_dist)[idx]], # ID of first site
  site_j = colnames(site_dist)[col(site_dist)[idx]], # ID of second site
  distance_m = as.numeric(site_dist[idx]) # distance between pairs
) %>%
  arrange(distance_m)

# Flag pairs closer than 800 m (the recommended min distance)
threshold <- 800
close_pairs <- pair_tbl %>% filter(distance_m < threshold)

write.csv(close_pairs, "./data_outputs/site_flags.csv")

write.csv(file="./data_outputs/Chicago_NLCD_landcover.csv", nlcd_data, row.names = FALSE)

