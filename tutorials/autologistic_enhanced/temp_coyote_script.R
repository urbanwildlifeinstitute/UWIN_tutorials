library(autoOcc)
library(sf)
library(exactextractr)
library(FedData)
library(dplyr)
library(terra)
library(GSODR)
library(lubridate)
# turn off spherical geometry as it's slow
sf::sf_use_s2(FALSE)

# read in the data
dat <- read.csv(
  "./data/chicago_coyote.csv"
)

# get just the coordinates
sites <- dplyr::distinct(
  dat[,c("Site", "Long", "Lat")]
)

sites <- sf::st_as_sf(
  sites,
  coords = c("Long", "Lat"),
  crs = 4326
)

sites <- sf::st_transform(
  sites,
  crs = 32616
)

sites_buff <- sf::st_buffer(
  sites,
  dist = 1000
)

land <- terra::rast(
  "D:/GIS/cmap/landcover_2010_chicagoregion.img"
)


test <- exactextractr::exact_extract(
  land,
  sites_buff,
  fun = "frac"
)

covs <- data.frame(
  tree = test$frac_1,
  imperv = rowSums(test[,c("frac_5", "frac_6", "frac_7")])
)
covs$Site <- sites_buff$Site

hou <- sf::read_sf(
  "D:/GIS/housing_density/il_blk10_Census_change_1990_2010_PLA2.shp"
)


sites_buff <- sf::st_transform(
  sites_buff,
  sf::st_crs(hou)
)


hou_covs <- sf::st_interpolate_aw(
  hou["HHUDEN10"],
  sites_buff,
  na.rm = TRUE,
  extensive = FALSE
)


covs <- dplyr::inner_join(
  covs,
  data.frame(hou_covs)[,c("HHUDEN10", "Site")],
  by = "Site"
)
hou_covs$Site <- sites_buff$Site
covs <- covs[,c(3,1,2,4)]
colnames(covs)[4] <- "housing_density"


streams <- sf::read_sf(
  "D:/GIS/water/IL_Streams_From_100K_DLG_Ln.shp"
)

sites <- sf::st_transform(
  sites,
  crs = st_crs(streams)
)

streams <- streams[streams$ENR > 400000,]

streams <- sf::st_crop(
  streams,
  sites
)

nearest_feat <- sf::st_nearest_feature(
  sites,
  streams
)

nearest_dist <- sf::st_distance(
  sites,
  streams[nearest_feat,],
  by_element = TRUE
)
covs$dist_stream <- round(as.numeric(nearest_dist) / 1000,3)

covs$tree <- round(covs$tree, 3)
covs$imperv <- round(covs$imperv,3)
covs$housing_density <- round(covs$housing_density,3)
write.csv(
  covs,
  "./data/coyote_covariates.csv",
  row.names = FALSE
)

y <- autoOcc::format_y(
  x = dat,
  site_column = "Site",
  time_column = "Season",
  history_columns = "Week"
)

my_stations <- GSODR::nearest_stations(
  LON = -87.84102,
  LAT = 41.87662,
  distance = 50
)


my_temps <- GSODR::get_GSOD(
  years = 2017:2020,
  station = my_stations$STNID
)

# get days within the given weeks
date_start <- unique(dat$Start)
date_start <- ymd(date_start)

week_start <- lapply(
  date_start,
  function(x){
    seq(
      x,
      by = "1 week",
      length.out = 10
    )
  }
)
my_temps$weekID <- NA
my_temps$season <- NA
names(week_start) <- unique(dat$Season)

weekID <- paste0(
  "Week_",1:9
)
for(i in 1:length(week_start)){
  
  for(j in 2:length(week_start[[i]]))  {
    first_day <- week_start[[i]][j-1]
    last_day <- week_start[[i]][j] - days(1)
    if(
      any(
        dplyr::between( my_temps$YEARMOD, first_day, last_day)
      )
    ){
      rowid <- which(dplyr::between( my_temps$YEARMOD, first_day, last_day))
      my_temps$weekID[rowid] <- weekID[j-1]
      my_temps$season[rowid] <- names(week_start)[i]
    }
  }
}

to_go <- which(
  is.na(
    my_temps$weekID
  )
)

my_temps <- my_temps[-to_go,]


temp_sum <- my_temps %>% 
  dplyr::group_by(STNID, NAME, weekID, season) %>% 
  dplyr::summarise(
    temp = mean(TEMP, na.rm = TRUE),
    lat = mean(LATITUDE, na.rm = TRUE),
    lon = mean(LONGITUDE, na.rm= TRUE)
    )
# make sure we have complete data, otherwise generate an average
full_temp <- expand.grid(
  STNID = unique(temp_sum$STNID),
  season = unique(temp_sum$season),
  weekID = unique(temp_sum$weekID)
)

full_temp <- dplyr::left_join(
  full_temp,
  temp_sum,
  by = c("STNID", "season", "weekID")
)

my_avs <- temp_sum %>% 
  dplyr::group_by(season, weekID) %>% 
  dplyr::summarise(temp = mean(temp))
for(i in 1:nrow(full_temp)){
  if(!is.na(full_temp$temp[i])){
    next
  } else {
    to_fix <- full_temp[i,]
    to_fix$temp <- my_avs$temp[
      my_avs$season == to_fix$season &
        my_avs$weekID == to_fix$weekID
    ]
    to_fix$lat <- mean(temp_sum$lat[
      temp_sum$STNID == to_fix$STNID
    ])
    to_fix$lon <- mean(temp_sum$lon[
      temp_sum$STNID == to_fix$STNID
    ])
    to_fix$NAME <- unique(temp_sum$NAME[
      temp_sum$STNID == to_fix$STNID
    ])
    full_temp[i,] <- to_fix
    
  }
}

temp_data <- expand.grid(
  Site = unique(dat$Site),
  Season = unique(dat$Season),
  Week = weekID
)

temp_sf <- sf::st_as_sf(
  dplyr::distinct(full_temp[c("STNID", "lat", "lon")]),
  coords = c("lon", "lat"),
  crs = 4326
)


temp_nearest <- sf::st_nearest_feature(
  sites,
  temp_sf
)

temp_data <- split(
  temp_data,
  factor(temp_data$Site)
)
for(i in 1:nrow(sites)){
  tmp <- temp_data[[i]]
  site_id <- full_temp[which(full_temp$STNID == full_temp$STNID[temp_nearest[i]]),]
  tmp <- dplyr::left_join(
    tmp,
    site_id[,c("weekID", "season", "temp")],
    by = c("Week" =  "weekID","Season" = "season")
  )
  temp_data[[i]]  <- tmp
}

temp_data <- dplyr::bind_rows(temp_data)

temp_data$Season <- factor(
  temp_data$Season,
  levels = unique(dat$Season)
)
temp_data <- temp_data[order(temp_data$Site, temp_data$Season, temp_data$Week),]

write.csv(
  temp_data,
  "./data/weekly_temp_data.csv",
  row.names = FALSE
)
