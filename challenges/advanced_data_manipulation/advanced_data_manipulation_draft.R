# Coding Club: Advanced Data Manipulation
# Original tutorial: https://ourcodingclub.github.io/tutorials/data-manip-creative-dplyr/

# Load relevant libraries
library(dplyr)
library(ggplot2)

# Load in challenge data
setwd("E:/GitHub/UWIN_tutorials/challenges/advanced_data_manipulation")
UWIN_data <- read.csv("full_capture_history.csv", header = TRUE) 

# View data
head(UWIN_data)

### Mason Table on data here ###

# We keep forgetting what Y and J stand for, let's update these to be more descriptive names
# Lets change 'Y' to 'det_days' and 'J' to 'cam_days'

UWIN_data <- rename(UWIN_data, det_days = Y, cam_days = J)
head(UWIN_data)

# We are interested in comparing raccoon detections across all sites for east coast cities: 
# 'atga', 'wide', 'rony', and 'safl'. 

# Create a new dataset that summarizes the
# total raccoon detections for each of these cities and make a barplot. Hint: This can be plotted 
# with geom_count() or geom_bar()  

# UWIN_data = UWIN_data %>%
#   mutate(region = case_when(Lat > 0 & Long >= -85 ~ "East",
#                             TRUE ~ "West")) %>%
#   glimpse()
# 
# UWIN_east = UWIN_data %>% 
#   filter(region == "East")

# filter only cities of interest
UWIN_east <- filter(UWIN_data, City %in% c("atga", "wide", "rony", "safl")) 

# We can check this worked by viewing the unique cities
unique(UWIN_east$City)

# filter only species of interest
raccoon_east <- filter(UWIN_east, Species == "raccoon")

# Again, we can confirm by looking at unique species
unique(raccoon_east$Species)

# Now we want to sum all raccoon detections across all of the sites for each city. Create a new 
# column called 'det_total' which is a count of all detections for each city
det_city <- raccoon_east %>% 
  group_by(City) %>% 
  summarise(det_total = sum(det_days))


ggplot(data = det_city, aes(x = City, y = det_total)) +
  geom_bar(stat = "identity", fill = "lightblue") +
  labs(title = "Raccoon Detections", x = "City", y = "Detections") +
  theme_minimal() 
  
ggplot(data = det_city, aes(x = City, y = det_total)) +
  geom_col(fill = "lightblue") +
  labs(title = "Raccoon Detections", x = "City", y = "Detections") +
  theme_minimal() 


# Wow, there is a lot of variability of raccoon detections across these cities!
# Let's see how detections vary across a few other species in two of these cities
# Let's create a new dataset for these cities for three new species which
# occur in both cities

# select 3 species which occur in both cities 
atga <- filter(UWIN_data, City == "atga")
wide <- filter(UWIN_data, City == "wide")


unique(atga$Species)
unique(wide$Species)

int = intersect(atga$Species, wide$Species)
int

# filter only cities of interest
UWIN_subset <- filter(UWIN_data, City %in% c("atga", "wide")) 

# filter only species of interest
UWIN_east_sp <- filter(UWIN_subset, Species %in% c("virginia_opossum", "coyote",
                                              "raccoon")) 

# Then lets make another barplot that categorizes the detections by species (on the x-axis)
# and by City using colors.
ggplot(data = UWIN_east_sp, aes(x = Species, y = det_days, fill = City)) +
  geom_bar(stat = "identity") +
  labs(title = "Species Detections", x = "Species", y = "Detections") +
  theme_minimal() 



