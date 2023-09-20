# Coding Club: Basic Data Manipulation
# Original tutorial: https://ourcodingclub.github.io/tutorials/data-manip-intro/

# Load relevant libraries
library(dplyr)
library(ggplot2)

# Load in challenge data
setwd("E:/GitHub/UWIN_tutorials/challenges/basic_data_manipulation")
field_data <- read.csv("field_data.csv", header = TRUE) 
cap_hist <- read.csv("capture_history.csv", header = TRUE) 

# View data
head(field_data)
head(cap_hist)

str(field_data)
str(cap_hist)

# By examining the variable types, we can see that a few columns need specifying.
# This includes 'Date' and 'Time' in 'field_data'

# As in the coding club tutorial, where we change 'zone' to factor, we need to convert
# Date and Time to usebale time classes, specifically a format called 'POSIXct' which
# can store date and time together with their affiliated time zone in one column (or two).

# Helpful resources here: https://www.neonscience.org/resources/learning-hub/tutorials/dc-convert-date-time-posix-r

# Lubridate is a package used to manage time classes. It is built into the 'tidyverse' package. Since we are only 
# loading in the 'dplyr' package and not the entire 'tidyverse' we will need to 
# add this library

# see this lubridate .pdf for more details: https://rawgit.com/rstudio/cheatsheets/main/lubridate.pdf

library(lubridate)

# If you want to specify the time zone, it can be found with this function:
OlsonNames()

field_data$Date <- mdy(field_data$Date, tz = "US/Central")
# confirm this worked
class(field_data$Date)

# We will use the same package to correct time from a character 
field_data$Time <- hm(field_data$Time)
class(field_data$Time)

# This package is very handy and can be used to easily extract certain time components
minute(field_data$Time)
day(field_data$Date)

# we notice there is an issue with our Date field. One value was converted to an 'NA'. If we reload the data 
# we can see that there was an error when someone entered the data. Let's correct it using our new skills.
# we know that this date should be 6/30/2022

#field_data <- read.csv("field_data.csv", header = TRUE) 

# do this first with the row and column location of the incorrect date
field_data[10,9] <- mdy("6/30/2022", tz = "US/Central") 

# If we wanted to do this using logical conditions (by column names), 
# we would need to reload and convert the data again. Try this way now starting with:
field_data <- read.csv("field_data.csv", header = TRUE) 
field_data[field_data$Date == "6/39/2022",]$Date <- "6/30/2022" 

# Now we need to update Date and Time variables with corrected data
field_data$Date <- mdy(field_data$Date, tz = "US/Central")
field_data$Time <- hm(field_data$Time)

# We also notice when examining our data that one year was entered incorrectly, 
unique(field_data$Year)
# let's use logical conditions to look at the whole row including this data point
field_data[field_data$Year == "2003",] 
# based on the 'Date' column, we can correct the 'Year' to 2023. Try this now.
field_data[field_data$Year == "2003",]$Year <- "2023" 

# Use the same system to correct Camera.sensitivity from 'Nrmal' to 'normal'
# and 'Lure' from 'None' to 'none' to keep all columns consistent for later analysis.
# Remember R is case sensitive, meaning 'None' and 'none' will be read as two different
# varibales 
unique(field_data$Camera.sensitivity)
field_data[field_data$Camera.sensitivity == "Nrmal",]$Camera.sensitivity <- "normal"

unique(field_data$Lure)
field_data[field_data$Lure == "None",]$Lure <- "none"

# Now that our 'field_data' appears to be cleaned up, we can use this data or link it to other data sets like 'cap_hist'.
# When collecting or managing data, it is often helpful to break-up data into multiple data sheets (in the field) or data tables (multiple .csv's)

# However, to link these data later, it is important to have a column, or 'key', that is shared
# across datasets. 

# For our example, we may want to know if there were lures affiliated with our species detections. However, lure
# is not a column in our 'cap_hist' data.frame. We can add this to the 'cap_hist' data.frame with the join() function. 
# It's important to note that the best way to link data is through a unique identifier. In our case, one table, 'field_data' contains
# data specific to camera deployments or visits while the other table 'cap_hist' is specific to a camera station. 

# It is still possible to link these tables but certain columns may be repeated depending on what we seek to link. 
# Therefor it is important to consider how variables are linked and what variables are necessary to your analyses.

# If we assume that lures have an equal impact on detections across a sampling periods
# (e.g. the lure impact does not differ across visits), we can link lure presence to each camera station for each year
# (to account for lure presence which may vary year to year). 

# What column should we use to link these datasets?
# Station.ID = Site
# We need to tell R when joining
lure_data <- left_join(cap_hist, field_data, by = c("Site" = "Station.ID"))

# Now we have two 'Season' columns, 'Season.x' and 'Season.y'. Final challenge is to 
# drop 'Season.y' column and rename 'Season.x' back to 'Season'
lure_data <- select(lure_data, -"Season.y")
lure_data <- rename(lure_data, 'Season' = 'Season.x')


######## PLAYING AROUND #############
# Try joining these data.frames using key = 'Station.ID'
all_data <- left_join(field_data, cap_hist, by = "Station.ID")

# Why didn't this work? Remember, the key is linking both datasets, therefor is must be the same values AND
# the same column name. In 'field_data' our key is called 'Station.ID', but the same key is called 'Site'
# in 'cap_hist'. Let's make both columns 'Station.ID' and try joining again
cap_hist <- rename(cap_hist, Station.ID = Site)
all_data <- full_join(field_data, cap_hist, by = "Station.ID")

# Ahhh, looks like we have some overlapping columns thats aren't helpful keys. Let's omit those columns
# with a different function
all_data <- merge(x = field_data, y = cap_hist[, c("Long", "Lat", "Species", "City", "Detections")], by = "Station.ID")
