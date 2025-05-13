#install packages
install.packages("palmerpenguins")
install.packages("tidyr")
install.packages("dplyr")
install.packages("readxl")
install.packages("janitor")

#load packages
library(tidyr)
library(dplyr)
library(readxl)
library(palmerpenguins)
library(janitor)

# Things to keep in mind
# R likes .csv files
# R doesn't like spaces in names


# Read in data 'penguins' and 'penguins_raw' 
data(package = 'palmerpenguins')
wide_data <- read_excel("reformat_data.xlsx", skip = 1)
site_data <- read_csv("site_data.csv")

# Reading in excel files with multiple sheets-----------------------------------
# Read in excel sheet' and unique tabs as a character vector
# Note it helps to name them without spaces, this makes it easier to read in R
sheets_to_read <- readxl::excel_sheets("samples.xlsx")

# Create a function to read in excel sheet and all tabs 
df_list <- lapply(sheets_to_read, function(sheet) { #lapply moves over each tab
    readxl::read_excel("samples.xlsx", sheet = sheet) %>% 
    mutate(Site = sheet)}) # we create a new column to track the 'tab name', here sites

names(df_list) <- paste0("df_", make.names(sheets_to_read)) # assigns df_ to beginning of each tab
list2env(df_list, envir = .GlobalEnv)

# To subset to specific sheets use [,]
# df_list <- lapply(sheets_to_read[1:2], function(sheet) {
#   readxl::read_excel("samples.xlsx", sheet = sheet) %>%
#     mutate(tabname = sheet)
# })
# 
# names(df_list) <- paste0("df_", make.names(sheets_to_read[1:2]))
# list2env(df_list, envir = .GlobalEnv)

# Combine all data into one data.frame
all_samples <- df_Site.1 %>% 
  bind_rows(df_Site.2) %>% 
  bind_rows(df_Site.3)

write.csv(all_samples, "KameleonData.csv", row.names=FALSE)

KameleonData <- read_csv("KameleonData.csv")

# Mess up some dates
KameleonData[9,1] <- ymd_hms("2005-01-09 05:40:00", tz = 'Indian/Antananarivo') # note 9 = row and 1 = column
KameleonData[109,1] <- ymd_hms("2000-05-18 01:40:00", tz = 'Indian/Antananarivo') # note 109 = row and 1 = column

# Let's practice using a few useful functions to help us tidy our data
# rename, mutate, group_by, and reframe---------------------------------------

# Clean up naming, R does not like spaces (naming examples here)
# we will use 'snake case'
# PRACTICE RENAME
colnames(KameleonData)

KameleonData <- janitor::clean_names(dat = KameleonData, 
                                     case = 'upper_camel')

glimpse(KameleonData)

KameleonData <- KameleonData %>% 
  rename("Date" = "CollectionDate")

KameleonData %>% dplyr::distinct(SpeciesName)

# Let's review our data and confirm it makes sense
# look at data 'class'
dplyr::glimpse(KameleonData)


# Some cleaning tricks

# Look at sex columns for mistakes
unique(KameleonData$Sex)

# lets lowercase them all
# note we have to tell R where we want to store our new data
KameleonData <- KameleonData %>% 
  mutate(Sex = tolower(Sex))

# Check again at sex columns for mistakes, we're all fixed!
unique(KameleonData$Sex)

# To get rid of leading or removing spaces
unique(KameleonData$Subsite)

KameleonData <- KameleonData %>% 
  mutate(across(SpecimenCode:Site, ~ trimws(.))) # ~trimws() tells it to apply the function across all columns

# clean up Alive column to be more clear, yes or no
unique(KameleonData$Alive)

# Note '==' is for single values and '%in%' is for multiple values
# discuss the importance of imputing NA values (NA, zero, vs. )
# NA = not applicable, not available, not assessed, or no answer

KameleonData <- KameleonData %>% 
  mutate(Alive = case_when(
    Alive %in% c("x", "xx", "X") ~ "yes",
    is.na(Alive) ~ "no", # Note R will usually populate empty cells with NA's
    TRUE ~ Alive))

unique(KameleonData$Alive)

# Working with dates - create date data for fake dataset
Date_seq <- seq(as.POSIXct('2025/01/01', tz = 'Indian/Antananarivo'),
                   as.POSIXct('2025/07/01', tz = 'Indian/Antananarivo'),
                   by = "20 mins")

Date_sample <- as.data.frame(sample(Date_seq,
                      size = 150,
                      replace = TRUE)) 

colnames(Date_sample) <- "Date" 

Date_sample <- Date_sample %>% 
  arrange(ymd_hms(Date))

write.csv(Date_sample, "Date_sample.csv",  row.names=FALSE)

# Start by looking at Dates-----------------------------------------------------
# Working with dates can be tricky. Lets first examine our data.

# A helpful practice is to plot our date/time data to make sure it makes sense.

hist(
  KameleonData$Date,
  breaks = "years"
)

# Assuming we only collected data in 2025, it looks like there are some errors in our data, 
# let's look only at the years which were recorded
unique(year(KameleonData$Date))

# Now we know we need to change these specific instances. Let's look at the incorrect date/time data.
KameleonData %>% filter(year(KameleonData$Date) < 2025)

# Since the data was incorrectly written as 2005 and 2000, we can tell R to change any years that are 
# less then 2025, to 2025. Or we could tell if to chnage 
test <- KameleonData %>% 
  mutate(Date = case_when(
    year(Date) %in% c("2000", "2005") ~ update(Date, year = 2025), # update is a lubridate function that allows us to select specific parts of the date/time
    TRUE ~ Date))


# PRACTICE MUTATE
# Confirm date column is class 'date'
# https://evoldyn.gitlab.io/evomics-2018/ref-sheets/R_lubridate.pdf

# We can use the package lubridate to extract parts of the date and time
# for example, here's how we could extract year
KameleonData <- KameleonData %>% 
  mutate(Year = lubridate::year(Date)) 

# Let's try to do the year AND hour in one mutation
KameleonData <- KameleonData %>% 
  mutate(Year = lubridate::year(Date),
         Hour = lubridate::hour(Date)) 


class(KameleonData$Date)

# Correct wrongly entered years 
KameleonData <- KameleonData %>%
  mutate(Date = ifelse(year(Date) < 2025,
                       make_date(2025, month(Date), day(Date)),
                       Date))

# Working with lubridate
# all_samples <- all_samples %>% 
#   mutate(Year = year(Date))


# PRACTICE group_by and reframe
# Lets check out how many species we have detected at all of our subsites at each of 
# our three sites

# mention importance of running each function alone to confirm it is working as expected

Site_species <- KameleonData %>% 
  #select(SpeciesName, Subsite, Site) %>% # this limits our data to only these three columns
  group_by(Site, SpeciesName) %>% 
  summarise(
    count = n()) 

# Perhaps we only want to look at data from Site 1 and conduct analyses with only these data
# lets isolate only Site 1 data with a new object using the function filter()
# Note anytime we want to call a column of characters, such as names, we need to put it in quotations

Site_1 <- KameleonData %>% 
  filter(Site == "Site 1")

# Playing with wide data
colnames(wide_data) <- c("Week", "Seedling",
                         "Warm_Species1", "Warm_Species2",
                         "Cold_Species1", "Cold_Species2",
                         "Control_Species1", "Control_Species2")

long_data <- wide_data %>%
  pivot_longer(cols = starts_with(c("Warm", "Cold", "Control")),
               names_to = "Condition_Species",
               values_to = "Height") %>%
  separate(Condition_Species, into = c("Condition", "Species"), sep = "_") %>%
  fill(Week, .direction = "down")  # Fill in missing Week values, fucntion will stop before next group (here week 2)

# Combine species data with site information 
# Inner join:
# inner_join(x, y) keeps observations appearing in both tables.

# Outer joins:
# left_join(x, y) keeps all observations in x and only adds matches from y.
# right_join(x, y) keeps all observations in y and only adds matches from x. (Note: it is the same as left_join(y, x).)
# full_join(x, y) keeps all observations in x and y; if there’s no match, it returns NAs.
# all_samples <- left_join(all_samples, site_data, by = "Subsite")

# change percent to decimal value
# we can also use mutate to perform equations
all_samples <- all_samples %>% 
  mutate(PercentTreeCover = PercentTreeCover/100)
