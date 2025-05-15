#OSM IUWC25 Test file
# package_load:
# A general function to load packages, and if not on a computer
# to download them first
package_load<-function(packages = NA, quiet=TRUE, verbose=FALSE, warn.conflicts=FALSE){
  
  # download required packages if they're not already
  pkgsToDownload<- packages[!(packages  %in% installed.packages()[,"Package"])]
  if(length(pkgsToDownload)>0)
    install.packages(pkgsToDownload, repos="http://cran.us.r-project.org", quiet=quiet, verbose=verbose)
  
  # then load them
  for(i in 1:length(packages))
    require(packages[i], character.only=T, quietly=quiet, warn.conflicts=warn.conflicts)
}

package_load(
  c(
    "osmextract","tidyterra", "dplyr", "terra", "sf",
    "readr", "devtools", "ggplot2", "googledrive",
    "colourpicker", "tmap", "smoothr", "geos"
  )
)

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
# Replace with your study area country
place <- "Argentina" 

# Narrow down our first query to a bounding box using latitude/longitude coordinates which will help load data faster
# Argentina example
study_area_bbox <- sf::st_bbox(c(xmin=-71.900000,ymin=-41.262600,xmax=-70.650000,ymax=-40.490000), 
                               crs = "epsg:4326") %>% 
  st_as_sfc() 

pol_feat <- osmextract::oe_get(place = place, # place we defined above
                               boundary = study_area_bbox, # more specific study area boundary (this helps speed up processing)
                               boundary_type = c("spat","clipsrc"),
                               provider ="geofabrik",
                               layer = "multipolygons",
                               stringsAsFactors = FALSE,
                               quiet = FALSE,
                               force_download = TRUE,
                               extra_tags=keys)

# Read in downloaded OSM data
pol_feat <- oe_read("./data/argentina-latest.osm.pbf",
                   boundary = study_area_bbox, # more specific study area boundary (this helps speed up processing)
                   boundary_type = c("spat","clipsrc"),
                   layer = "multipolygons",
                   stringsAsFactors = FALSE,
                   quiet = FALSE,
                   force_download = TRUE,
                   extra_tags=keys)

# Confirm the box is the correct coordinates for you study area 
plot(study_area_bbox, axes = TRUE)

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
lin_feat <- osmextract::oe_get(place = place,
                               layer = "lines", 
                               boundary = study_area_bbox,
                               boundary_type = 'clipsrc',
                               quiet = FALSE,
                               force_download = TRUE,
                               stringsAsFactors = FALSE, 
                               extra_tags=keys)

# Read in downloaded OSM data
lin_feat <- oe_read("./data/argentina-latest.osm.pbf",
                    layer = "lines",
                    boundary = study_area_bbox, 
                    boundary_type = "clipsrc",
                    stringsAsFactors = FALSE,
                    quiet = FALSE,
                    force_download = TRUE,
                    extra_tags=keys)

# for Argentina example read in:
lin_feat <- readRDS("./data/lin_feat.rds")

# read in ESA raster data
# change file name to your study area .tif
my_map = rast("./data/ESA_WorldCover_10m_2021_v200_S42W072_Map.tif") 

