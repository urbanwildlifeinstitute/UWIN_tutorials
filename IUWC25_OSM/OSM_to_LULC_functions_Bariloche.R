####OSMtoLULC_vlayers #####


#requires(dplyr)

# If you want to change (add or remove) vlayers, need to adapt the reference table

OSMtoLULC_vlayers <- function(OSM_polygon_layer, OSM_line_layer){
  
  # Create list to hold vector layers
  classL1 <- list()
  
  #class_01 <- industrial  
  classL1[[1]] <- OSM_polygon_layer %>% filter(landuse %in% c("industrial", "fairground") |
                                                 industrial %in% c("factory") |
                                                 power %in% c("substation"))
  #class_02 <- commercial 
  classL1[[2]] <- OSM_polygon_layer %>% filter(landuse %in% c("commercial", "retail"))
  
  # class_03 <- institutional  
  classL1[[3]] <- OSM_polygon_layer %>% filter(landuse %in% c("institutional", "education", "religious", "military") |
                                                 amenity %in% c("school", "hospital", "university", "fast_food", "clinic", "theatre", "conference_center", "place_of_worship", "police") |
                                                 leisure %in% c("golf_course")|
                                                 healthcare %in% c("clinic", "hospital"))
  #class_04 <- residential
  classL1[[4]] <- OSM_polygon_layer %>% filter(landuse %in% c("residential"))
  
  #class_05 <- landuse_railway
  classL1[[5]] <- OSM_polygon_layer %>% filter(landuse %in% c("railway"))
  
  #class_06 <- open_green
  classL1[[6]] <- OSM_polygon_layer %>% filter(landuse %in% c("park", "grass", "cemetery", "greenfield", "recreation_ground", "winter_sports")|
                                                 (!is.na(golf) & !(golf %in% c("rough","bunker"))) |
                                                 amenity %in% c("park") |
                                                 leisure %in% c("park", "stadium", "playground", "pitch", "sports_centre", "stadium", "pitch", "picnic_table", "pitch", "dog_park", "playground")|
                                                 sport %in% c("soccer")|
                                                 power %in% c("substation")|
                                                 surface %in% c("grass"))
  # class_07 <- protected_area
  classL1[[7]] <- OSM_polygon_layer %>% filter(leisure	%in% c("nature_reserve")|
                                                 #boundary %in% c("protected_area","national_park")|
                                                 protected_area %in% c("nature")|
                                                 landuse %in% c("nature_reserve", "natural_reserve", "landscape_reserve"))
  # class_08 <- resourceful_area
 
   classL1[[8]] <- OSM_polygon_layer %>% filter(landuse %in% c("orchard","farmland", "landfill","vineyard", "farmyard", "allotments", "allotment", "farmland")|
                                                 leisure %in% c('garden')|
                                                 !is.na(allotments))
  # class_09 <- heterogenous_green 
  classL1[[9]] 	<- OSM_polygon_layer %>% filter(natural %in% c("garden", "scrub", "shrubbery", "tundra", "cliff", "shrub", "wetland", "grassland", "fell",
                                                               "heath","moor")|
                                                  landuse	%in% c("plant_nursery", "meadow", "flowerbed", "wetland")|
                                                  #!is.na("meadow")| # This part creates an error
                                                  golf %in% c("rough") | 
                                                  grassland %in% c("pairie"))
  
  #class_10 <- barren_soil 
  classL1[[10]] 	<- OSM_polygon_layer %>% filter(natural %in% c("mud", "dune", "sand","scree","sinkhole", "beach")|
                                                   landuse	%in% c("brownfield", "construction")|
                                                   golf	%in% c("bunker"))
  #class_11 <- dense_green
  classL1[[11]] <- OSM_polygon_layer %>% filter(landuse %in% c("forest")|
                                                  natural  %in% c("wood")|
                                                  boundary %in% c("forest", "forest_compartment"))
  #class_12 <- water 
  classL1[[12]]  <- OSM_polygon_layer %>% filter(landuse %in% c("basin")|
                                                   natural	 %in% c("water", "spring", "waterway")|
                                                   waterway	 %in% c("river", "stream", "tidal_channel", "canal", "drain", "ditch", "yest")|
                                                   (!is.na(water) & water != "intermittent")|
                                                   basin  %in% c("detention")|
                                                   intermittent != "yes"|
                                                   seasonal	!= "yes"|
                                                   tidal!= "yes")
  # # class_12_lines <- water_lines
  # classL1[[13]]  <- OSM_line_layer %>% filter(landuse %in% c("basin")|
  #                                               natural	 %in% c("water", "spring", "waterway")|
  #                                               waterway	 %in% c("river", "stream", "tidal_channel", "canal", "drain", "ditch", "yest")|
  #                                               (!is.na(water) & water != "intermittent")|
  #                                               basin  %in% c("detention")|
  #                                               intermittent != "yes"|
  #                                               seasonal	!= "yes"|
  #                                               tidal!= "yes")
  
  # class_13 <- parking_surface 
  classL1[[13]] <- OSM_polygon_layer %>% filter(parking	%in% c("surface")|
                                                  aeroway	%in% c("runway", "apron"))
  
  # class_14 <- building
  classL1[[14]] 	<- OSM_polygon_layer %>% filter( #!is.na("building")| # This part creates an error
    building %in% c("hospital", "parking", "industrial", "school", "commercial", "terrace", "detached", "semideatched_house", "house", "retail", "hotel", "apartments", "yes", "airport", "university")|
      parking	%in% c("multi-storey")|
      aeroway	%in% c("terminal"))
  
  # class_15 <- roads_very_high_traffic	
  classL1[[15]] <-  OSM_line_layer %>% filter(highway	%in% c("motorway",'motorway_link', "motorway_junction") &
                                                !grepl('/"bridge/"=>/"yes/"', OSM_line_layer$other_tags))
  
  # class_16 <- roads_sidewalk	
  classL1[[16]]	<- OSM_line_layer %>% filter(footway	%in% c("sidewalk"))
  
  # class_17 <- roads_unclassified
  classL1[[17]] <- OSM_line_layer %>% filter(!(highway %in% c("footway","construction","escape","cycleway","steps","bridleway","construction","path","pedestrian","track","abandoned", "turning_loop","living_street", "bicycle road", "cyclestreet", "cycleway lane","cycleway tracks", "bus and cyclists", "service","services", "busway", "sidewalk", "residential", "rest_area", "primary", "motorway_junction", "secondary", "secondary_link", "tertiary", "tertiary_link", "motorway","motorway_link","trunk_link", "trunk", "corridor","elevator","platform","crossing","proposed", "razed")))
  
  # class_18 <- roads_very_low_traffic
  classL1[[18]] <-  OSM_line_layer %>% filter(highway	 %in% c("services","service","turning_loop","living_street"))
  
  # class_19 <- roads_low_traffic
  classL1[[19]] <- OSM_line_layer %>% filter(highway	%in% c("residential", "rest_area", "busway"))
  
  # class_20 <- roads_med_traffic 
  classL1[[20]] <- OSM_line_layer %>% filter(highway	%in% c("tertiary", "tertiary_link"))
  
  # class_21 <- roads_high_traffic_low_speed
  classL1[[21]] <-  OSM_line_layer %>% filter(highway	%in% c("primary", "primary_link", "secondary", "secondary_link"))
  
  # class_22 <- roads_high_traffic_high_speed
  classL1[[22]] <- OSM_line_layer %>% filter(highway	%in% c("trunk", "trunk_link"))
  
  # class_23 <- streetcars
  classL1[[23]] <- OSM_line_layer %>% filter(railway	%in% c("tram"))
  
  # class_24 <- pedestrian_trails
  classL1[[24]] <- OSM_line_layer %>% filter(highway	%in% c("footway","construction","escape", "cycleway","steps","bridleway","path","pedestrian","track", "abandoned","bicycle road", "cyclestreet", "cycleway lane", "cycleway tracks", "bus and cyclists")|
                                               footway	!= "sidewalk")
  
  # class_25 <- railway	
  classL1[[25]] <- OSM_line_layer %>% filter(railway	%in% c("light_rail","narrow_gauge","rail","preserved")|
                                               railway != "tram")
  # class_26 <- linear_features_not_in_use
  classL1[[26]] <- OSM_line_layer %>% filter(railway	%in% c("abandonded","construction","disused")|
                                               highway	%in% c("construction"))
  # class_27 <- barriers
  #classL1[[28]] <- OSM_line_layer %>% filter(!is.na("barrier"))
  classL1[[27]] <- OSM_line_layer %>% filter(barrier !='')
  
  return(classL1)
  
}

#### OSMtoLULC_rlayers ####

# Questions --------------------------------------------------------------------
# How do we know what is a polygon vs. linear feature? Inspecting the feature in OSM? Metadata?

#needs a list of vectors with a priority class, and the study area's extent as a spatextent object, 
#which can be obtained directly from the polygon layer obtained with osmextract::oe_get uisng the ext() function e.g. ext(pol_feat) or any other spatial dataframe objects

OSMtoLULC_rlayers <- function(OSM_LULC_vlayers, study_area_extent){
  classL1 <- OSM_LULC_vlayers
  rtemplate <- rast(res=0.001, ext = study_area_extent, crs= "EPSG:4326") #the resolution may cause an error depending on GDAL space (try red = .00001 to start)
  # rtemplate5 <- terra::project(rtemplate, "EPSG:5070")
  classL1  <- Filter(Negate(is.null), classL1) #eliminates any nulls
  
  refTable <- cbind.data.frame(
    "rid"=c(1:27), 
    "feature"=c("industrial", "commercial", "institutional", "residential", "landuse_railway",
                "open_green","protected area", "resourceful_area", "heterogenous_green", "barren_soil",
                "dense green","water", "parking_surface", "building","roads_very_high_traffic", 
                "roads_sidewalk", "roads_unclassified","roads_very_low_traffic", "roads_low_traffic",
                "roads_med_traffic", "roads_high_traffic_low_speed", "roads_high_traffic_high_speed",
                "streetcars", "pedestrian_trails", "railway", "linear_features_not_in_use","barriers"),
    "priority"=c(1:27),
    "geometry"=c(rep("poly",14), rep("line",13)),
    "buffer"=c(rep(NA,12),6,NA,24,3,3,12,6, 12,18,36,6,3,12,6,1) # buffer in meters
  )
  
  classL2 <- list()
  i = 14
  for(i in 1:27){
    if(as.character(st_geometry_type(classL1[[i]], by_geometry = FALSE)) %in% c("POLYGON","MULTIPOLYGON", "GEOMETRY")){
      temp1 <- classL1[[i]]
      if(nrow(temp1)>0){
        temp1 <- st_make_valid(temp1) #PR
        temp1 <- temp1 %>%  filter(!st_is_empty(.)) #PR
        temp1 <- st_make_valid(temp1) # PR
        temp1 <- terra::project(svc(temp1)[1], rtemplate)
        temp1$priority <- refTable$priority[i]
        #classL2[[i]] <- terra::rast(temp1, rtemplate, field="priority") 
        classL2[[i]] <- terra::rasterize(temp1, rtemplate, field="priority", touches = TRUE) 
        print(paste0("layer ", i, "/27 ready"))
      }
    }else{
      temp1 <- classL1[[i]]
      if(!is.null(temp1)){
        temp1 <- st_make_valid(temp1) #PR
        temp1 <- temp1 %>%  filter(!st_is_empty(.)) #PR
        temp1 <- st_make_valid(temp1) # PR
        temp1 <- st_transform(temp1, "EPSG:5070")
        temp1 <- st_buffer(temp1, dist=refTable$buffer[i])
        temp1 <- terra::project(svc(temp1)[1], rtemplate)
        temp1$priority <- refTable$priority[i]
        classL2[[i]] <- terra::rasterize(temp1, rtemplate, field="priority", touches = TRUE)
        print(paste0("layer ", i, "/27 ready"))
      }else{print(paste0("layer ", i, "/27 null"))}
    }
  }
  return(classL2)
}

#### OSM_only_LULC_map ####

#needs a list of rasters with a value indicating their overlay priority

merge_OSM_LULC_layers <- function(OSM_raster_layers){ 
  classL2 <- OSM_raster_layers
  classL2 <- Filter(Negate(is.null), classL2)
  classL2 <- rev(classL2) #Seattle loses class 16 when we revert but reverting works as expected to overlay classes
  r3 <- terra::app(rast(classL2), fun='first', na.rm=TRUE)
  return(r3)
}

#### integrate_OSM_to_globalLULC ####

#requires an OSM_only map, a global LULC map and a reclassification table between these, including the designation of any urban/developed landcover classes in the global LULC map as class number 28 (developed_na)

integrate_OSM_to_globalLULC <- function(OSM_lulc_map, global_lulc_map, reclass_table){
  
  #load global lulc raster that will work as a backgroudn layer to cover any missing data in the OSM_database
  r5 <-  global_lulc_map
  r3 <-  OSM_lulc_map

  r3p <- project(r3, crs(r5)) #reproject OSM-only raster to global LULC raster to crop the global LULC
  r5 <- crop(r5, r3p) #crop
  #writeRaster(r5, "global_landcover_maps/*.img")
  
  # Given that one is Geographic and the other planar, it is safer to project
  # fact1 <- round(dim(r5)[1:2] / dim(terra::project(r3, r5))[1:2])
  # r5 <- terra::aggregate(r5, fact1, fun="modal", na.rm=T)
  
  #reproject cropped global LULC to our frameworks projection
  # transform cropped raster crs to EPSG 3857 , "EPSG:3857"
  r6 <- terra::project(r5, r3, method="near", align=TRUE)

  # crop again after reprojection to ensure rasters have the same extent #crop again just in case (?)
  r6 <- terra::crop(r6, r3)
  r6 <- terra::extend(r6, r3) # this is to ensure the rasters line up before masking.
  r7 <- classify(r6, reclass_table)

  r4 <- ifel(is.na(r3), r7, r3)
 
  return(as.factor(r4))
} 


