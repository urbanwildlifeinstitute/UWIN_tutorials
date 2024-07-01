# UWIN Workshop Series: Static Occupancy
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
    "dplyr", "ggplot2", "unmarked"
  )
)


setwd("D:/GitHub/UWIN_tutorials/tutorials/data_manipulation")

library(dplyr) # grammar of data manipulation using set of verbs; tidyverse 
library(tidyr) # tidy data; tidyverse
library(readr) # reads csv files; tidyverse
library(magrittr) # has the original pipe operator %>%
library(janitor) # to clean names of variables 

occ.data <- readr::read_csv(file = './data/OccupancyReport.csv', 
                            # Skip row 1-3
                            skip = 3,
                            # identify how not available data are coded, you can use c('NA', 'N/A')
                            na = 'NA', 
                            # define column types, readr guesses the ones we don't specify
                            col_types = c('f', 'd', 'c', 'd', 'd'))

# With glimpse we can see the name of each column, type, and the first rows 
dplyr::glimpse(occ.data)

occ.info <- read_csv(file = './data/OccupancyReport.csv', 
                     n_max = 1) |> 
  # Selecting the columns we want
  select('Start Date', 'End Date')

glimpse(occ.info)

# clean_names has the following cases: 
# "snake"
# "lower_camel"
# "upper_camel"
# "title" 
# detect abbreviations with abbreviations = c()
occ.data <- janitor::clean_names(dat = occ.data, 
                                 case = 'snake')
glimpse(occ.data)

# distinct keeps only unique rows from a data frame 
# .keep_all = TRUE let's us keep all the columns in the data frame 
# .keep_all = FALSE to only keep the column we specified in distinct. Deletes the rest. 
occ.data |> 
  dplyr::distinct(species)

# Separate only the days 
days_oc <- occ.data |> 
  # filter only the rows that contain Coyote
  dplyr::filter(species == 'Coyote')|> 
  # select variables that contain the string 'day_'
  dplyr::select(contains('day_')) 

# Calculate number of weeks or occasions based on 7 day groups 
n_weeks <- ceiling(ncol(days_oc)/7)
# Create a vector where you assign the number of week to the day
week_groups <- rep(1:n_weeks, each = 7)[1:ncol(days_oc)]

# and write a function that keeps each occasion with all NA's as such and those with all 0's as 0, and those with at least 1 detection, as 1
combine_days <- function(y, groups){
  ans <- rep(NA, max(groups))
  for(i in 1:length(groups)){
    tmp <- as.numeric(y[groups == i])
    if(all(is.na(tmp))){
      next
    } else {
      ans[i] <- as.numeric(sum(tmp, na.rm = TRUE)>0)
    }
  }
  return(ans)
}

# Apply this function across rows (in groups of 6)
data.weeks <- t( # this transposes our matrix
  apply(
    days_oc, 
    1, # 1 is for rows
    combine_days,
    groups = week_groups
  )
)

# Rename columns to match number of week 
data.wk <- data.weeks |> 
  # coerce to data frame because data.weeks is a matrix 
  as.data.frame() |> 
  # dplyr::rename() let's us rename any column in a ata frame 
  # syntax: new_name = old_name
  # rename_with() renames columns using a function 
  dplyr::rename_with(~paste0('week_', 1:n_weeks))

# Now we can combine the species, season, site, latitude, longitude from coyote.data to our occasions.
data.occ <- occ.data |> 
  # we filter the rows that only include Coyote
  dplyr::filter(species == 'Coyote')|> 
  # we select these columns to be in the final data frame 
  dplyr::select(species, season, site, latitude, longitude) |> 
  # bind dataframes by column making a wider result 
  dplyr::bind_cols(data.wk)


library(ggplot2)

occ_long <- data.occ |> 
  pivot_longer(cols = starts_with('week_'), 
               names_to = 'week', 
               values_to = 'values') |> 
  mutate(values = factor(values))

ggplot(occ_long, aes(x = week, y = site, fill = values))+
  geom_tile( 
    color = 'white', 
    lwd = 1, 
    linetype = 1)+
  coord_equal()+
  labs(title = paste0('Weekly detections by site'))+
  scale_fill_manual(values = c('#6F9CDE', '#FC8955'), 
                    na.value = '#A9A9A9') +
  theme(legend.position = 'left', 
        axis.text.x = element_text(angle = 90), 
        legend.title = element_blank(), 
        axis.title = element_blank(), 
        plot.title = element_text(hjust=0, face = 'bold', size = 16)) -> tile.plot 

tab <- as.data.frame(
  c(Start = occ.info$`Start Date`, 
    End = occ.info$`End Date`, 
    Sites = nrow(data.occ), 
    Species = as.character(occ_long$species[[1]]), 
    Occassions = n_weeks, 
    'Days per occassion' = 7)
)

library(gridExtra)
p_tab <- tableGrob(unname(tab), theme = ttheme_minimal(core=list(fg_params=list(hjust=0, x=0)),
                                                       rowhead=list(fg_params=list(hjust=0, x=0, 
                                                                                   col = 'black'))))
grid.arrange(tile.plot, p_tab, ncol = 2, padding = unit(0, 'cm'))

# read in the file with covariates 
covariates <- read_csv('./data/covariates.csv')

# make sure column names follow snake convention 
covariates <- janitor::clean_names(covariates, 
                                   "snake")
glimpse(covariates)

covariates.sc <- covariates |> 
  # Select only the columns you wish to scale
  select(forest:dist_water) |>
  # mutate across all the columsn you wish to scale 
  mutate(across(forest:dist_water, 
                ~as.vector(scale(.x)))) |> 
  # rename the columns you selected and add _scaled at the end of each one
  rename_with(~paste0(.x, '_scaled')) |> 
  # combine all the columns here and with the file covariates
  dplyr::bind_cols(covariates) |> 
  # reorganize the columns in the order you want
  relocate(site, latitude, longitude, forest, ag, dist_water, forest_scaled, ag_scaled, dist_water_scaled)

glimpse(covariates.sc)

temp_covs <- read_csv('./data/temp_covs.csv') |> 
  select(!Site) # this selects everything except 'site'

# We have to summarize it for each occasion, remember you only have 6 occasions 
library(purrr)
row_means <- function(data) {
  map(seq(1, ncol(data), by = 7),
      ~rowMeans(select(data, .x:min(.x + 6, ncol(data))), na.rm = TRUE)) |> 
    set_names(paste0("week_", seq(1, 6, by = 1))) |> 
    tibble::as_tibble()
}


# Apply the function and coerce the object to be a matrix 
temp_avg <-  row_means(temp_covs)

library(unmarked)

# Detection data must only include the columns with the occasions
y <- data.occ |> 
  # select the columns with detection only 
  select(week_1:week_6)

# Site covariates must only be the columns with the scaled covariates   
siteCovs <- covariates.sc |> 
  # select the columns with scaled values of covariates only 
  select(forest_scaled:dist_water_scaled)

# You need a list of matrices for the observation covariates, 
# And each matrix must be named 
obsCovs <- list(temp_avg=temp_avg)

# Put your detection, spatial covariates, and observational covariates into 
# an unmarkedFrameOccu 
occu.df <- unmarked::unmarkedFrameOccu(y = y, # detection
                                       siteCovs = siteCovs, # spatial covariates 
                                       obsCovs = obsCovs) # observational covariates 
