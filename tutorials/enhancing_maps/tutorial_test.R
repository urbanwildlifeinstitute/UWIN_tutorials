# Load in libraries
library(osmextract)
library(tidyterra)
library(dplyr)
library(terra)
library(sf)
library(readr)
library(devtools)
library(ggplot2)
library(googledrive)
library(colourpicker)
library(tmap)
library(smoothr)
library(geos)

# Load in functions
source("OSM_to_LULC_functions_Bariloche.R") 

#table with the key-value pairs to be extracted 
osm_kv <- read_csv(
  "https://raw.githubusercontent.com/tgelmi-candusso/OSM_for_Ecology/main/urban_features/osm_key_values.csv"
) 
osm_kv <- osm_kv %>% 
  filter(!is.na(key))
keys <- unique(osm_kv$key)

# Set our first query
place <- "Argentina" 

# Narrow down our first query to a bounding box using latitude/longitude coordinates which wil help load data faster
study_area_bbox <- sf::st_bbox(c(xmin=-71.900000,ymin=-41.262600,xmax=-70.650000,ymax=-40.490000), 
                               crs = "epsg:4326") %>% 
  st_as_sfc() 

# Confirm the box is the correct coordinates for you study area 
plot(study_area_bbox, axes = TRUE)

pol_feat <- osmextract::oe_get(place = "Argentina", # place we defined above
                               boundary = study_area_bbox, # more specific study area boundary (this helps speed up processing)
                               boundary_type = c("spat","clipsrc"),
                               provider ="geofabrik",
                               layer = "multipolygons",
                               stringsAsFactors = FALSE,
                               quiet = FALSE,
                               force_download = TRUE,
                               extra_tags=keys)

saveRDS(pol_feat, "./data/pole_feat.rds")
pol_feat <- readRDS("./data/pole_feat.rds")
                               
# This filtering grabs the townships of our study area and any landcover class in our study area tagged as 'scrub'. We do this because Bariloche's boundary is outside
# the barriers we want to grab OSM data. Grabbing the smaller municipalities lets us limit our boundary to the city area more specifically. Then we will use 
# a national landcover map to fill in regions not covered well by OSM (e.g. non-urban areas)
study_area_boundary <- pol_feat %>% 
  filter((boundary == "administrative" & admin_level %in% c(8,9) # admin_level=* key describes the administrative level of a feature within a subdivision hierarchy
          & osm_id != 3405247) | natural == "scrub")

# Now we grab the larger Bariloche boundary so we can subset our study area just to Bariloche
bariloche_boundary <- pol_feat %>% 
  filter(osm_id == 3405247)

# Here we subset to our Bariloche boundary (excluding Villa La Angostura). This is so 
# we can apply a smoothing function in our next step. Ignore the warning message here.
sf_use_s2(FALSE)
bariloche <- study_area_boundary %>% 
  st_intersection(bariloche_boundary)

# notice that filtering to the townships of Bariloche misses some urban data nearby.
# By using a buffer and smoothing function, we can grab additional areas around 
# the small municipalities
sf_use_s2(TRUE)
bariloche_buffer <-
  st_geometry(bariloche) %>% 
  st_buffer(1) %>%  
  st_union() %>%
  as_geos_geometry() %>% 
  geos_concave_hull(ratio = .02) %>% 
  st_as_sfc() %>% 
  st_buffer(5) %>% 
  smoothr::smooth(method = "ksmooth", smoothness = 3)

plot(bariloche[1], main = "Bariloche boundary") # before smoothing
plot(bariloche_buffer[1], main = "Bariloche boundary smooth") #after smoothing

# Now we are ready to grab all OSM polygons which fall within our new 'bariloche buffer'
sf_use_s2(FALSE)
bariloche_poly <- pol_feat %>% 
  st_intersection(bariloche_buffer)

angostura_boundary <- pol_feat %>%
  filter(osm_id == 3442889)

plot(angostura_boundary[1], main = "Angostura boundary")

# convert to a multipolygon
sf_use_s2(TRUE)
angostura_buffer <- 
  st_geometry(angostura_boundary) %>% 
  as_geos_geometry() %>%
  st_as_sfc() 

# Grab all OSM polygons which fall within the Angostura polgygon
sf_use_s2(FALSE)
angostura_poly <- pol_feat %>% 
  st_intersection(angostura_buffer)

# Join our two cities into one data.frame of polygons
pol_feat_agg <- rbind(bariloche_poly, angostura_poly)

# We're ready to grab out linear data from our study area region

lin_feat <- osmextract::oe_get("Argentina",
                               layer = "lines", 
                               boundary = study_area_bbox,
                               boundary_type = 'clipsrc',
                               quiet = FALSE,
                               force_download = TRUE,
                               stringsAsFactors = FALSE, 
                               extra_tags=keys)

saveRDS(pol_feat, "./data/lin_feat.rds")
lin_feat <- readRDS("./data/lin_feat.rds")

# read in .gpkg file
build <- st_read("./data/Argentina_buildings.gpkg")

# filter to buildings with >80% confidence
build_80 <- build %>% 
  filter(confidence > .8)

# Crop buildings layers to extent of study area or pol_feat if limited to specific polygons
build_80 <- st_crop(build_80, study_area_bbox)

# transform to pol_feat CRS
build_80 <- st_transform(build_80, st_crs(pol_feat))

# format data to be cohesive with pol_feat dataset
build_80$building <-rep("yes", nrow(build_80))
build_80 <- rename(build_80, geometry = geom)

# Step 1: Make sure columns in both data.frames are the same
all_columns <- union(names(build_80), names(pol_feat_agg))  # Combine all unique columns from both

# Step 2: Add missing columns with NA in each data.frame
# Add missing columns to 'build'
missing_build <- setdiff(all_columns, names(build_80))  # Columns missing in 'build'
for (col in missing_build) {
  build_80[[col]] <- NA  # Add missing column with NA values
}

# Add missing columns to 'pol_feat_agg'
missing_pol_feat <- setdiff(all_columns, names(pol_feat_agg))  # Columns missing in 'pol_feat_agg'
for (col in missing_pol_feat) {
  pol_feat_agg[[col]] <- NA  # Add missing column with NA values
}

combined <- rbind(build_80, pol_feat_agg)
combined <- st_as_sf(combined)

vlayers <- OSMtoLULC_vlayers(
  OSM_polygon_layer = combined, 
  OSM_line_layer = lin_feat
)

# plot a layer to see if this worked as expected
plot(vlayers[[14]][1]) # This is the building layer

extent <- as.vector(ext(c(xmin=-71.900000,xmax=-70.650000, ymin=-41.262600,ymax=-40.490000)))

# this function which assigns each landcover class information such as its geometry or a buffer
rlayers <- OSMtoLULC_rlayers(
  OSM_LULC_vlayers = vlayers,
  study_area_extent = extent
)

# Test this worked by plotting our building layer 
plot(rlayers[[14]], col = "black") # 14 = building list
