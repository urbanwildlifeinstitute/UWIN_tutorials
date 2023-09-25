# UWIN Challenge: Basic Data Manipulation
## Coding Club Reference tutorial [__here.__](https://ourcodingclub.github.io/tutorials/data-manip-intro/)

### Cleaning and classifying data using basic functions
Now that we have a few basic tool we can use to manipulate and clean data, we can test our skills with some data we may see while conducting urban wildlife research with UWIN. We will also apply the same skills to managing and manipulating time data.

```R
# Load in libraries
library(dplyr)
library(ggplot2)

# Set your local working directory
setwd()
field_data <- read.csv("field_data.csv", header = TRUE) 
cap_hist <- read.csv("capture_history.csv", header = TRUE) 

# Check out what data we're working with
head(field_data)
head(cap_hist)

str(field_data)
str(cap_hist)
```

## Challenge 1. 
### Classifying time data
By examining our data with 'str()' above, we can see that 'date' and 'time' are classified as characters. 

```R
class(field_data$Date)
class(field_data$Time)
```
However, we will need to classify these as an appropriate date/time format if we want to extract and manipulate data with helpful R functions

As in the coding club tutorial, where we converted 'zone' from a character to a factor, we need to convert 'Date' and 'Time' to a usebale time format, specifically to a format called 'POSIXct' which can store date and time together with their affiliated time zone in one column (or two). For more information on this time class and other formats review [NEON's Time Series Tutorial](https://www.neonscience.org/resources/learning-hub/tutorials/dc-convert-date-time-posix-r).

An easy way to manipulate time series data is using the `lubridate` package. 
```R
library(lubridate)
?lubridate
OlsonNames()
```
Review the lubridate help file and convert 'Date' and 'Time' fields into a POSIXct format. 

<details closed><summary>Solution</a></summary>

```R
# reclass 'Date'
field_data$Date <- mdy(field_data$Date, tz = "US/Central")
# confirm this worked
class(field_data$Date)

# reclass 'Time'
field_data$Time <- hm(field_data$Time)
# confirm this worked
class(field_data$Time)
```
             
</details>

Nice work. This package is very handy and can be used to easily extract specific time components, for example:
```R
minute(field_data$Time)
day(field_data$Date)
```

## Challenge 2. 
### Cleaning data
Nice work! We decided we're interested in examining four east coast cities: `atga`, `wide`, `rony`, and `safl`. We specifically want to summarize how detections of raccoons vary across these cities (across all sites) and make a bar plot to visualize the differences. 
  
Start by creating a new data set `UWIN_east` for these cities which only includes raccoon detections.
  
<details closed><summary>Solution</a></summary>
  
```R
# Use the filter function to focus on four cities of interest
UWIN_east <- filter(UWIN_data, City %in% c("atga", "wide", "rony", "safl")) 

# We can check this worked by viewing the unique cities
unique(UWIN_east$City)
             
# filter only species of interest
raccoon_east <- filter(UWIN_east, Species == "raccoon")
unique(raccoon_east$Species)
```
             
</details>

Now we want to sum all raccoon detections across all of the sites for each city. Create a new 2-column dataframe called `det_total` which is a count of all raccoon detections for each east coast city
  
<details closed><summary>Solution</a></summary>
  
```R
det_city <- raccoon_east %>% 
  group_by(City) %>% 
  summarise(det_total = sum(det_days))
```
             
</details>

Good deal. Let's use this new dataframe to make a bar plot. 
  
<details closed><summary>Solution</a></summary>
  
```R
# This can be done using the 'geom_bar' function
ggplot(data = det_city, aes(x = City, y = det_total)) +
  geom_bar(stat = "identity", fill = "lightblue") +
  labs(title = "Raccoon Detections", x = "City", y = "Detections") +
  theme_minimal() 

# or the 'geom_col' function
ggplot(data = det_city, aes(x = City, y = det_total)) +
  geom_col(fill = "lightblue") +
  labs(title = "Raccoon Detections", x = "City", y = "Detections") +
  theme_minimal() 
```

<p float="left">
  <img src="./plots/raccoon_det.png" alt="A plot of raccoon detections in four cities." width="500" height="auto" />
</p>

</details>

  
## Challenge 3. 
### More filtering and plotting pratice
Wow, there is a lot of variability of raccoon detections across these cities! Let's see how detections vary across a few other species in two of these cities. Choose two of these cities and create a new dataframe for three new species (e.g. not raccoon) which occur in both cities. Hint: the `intersect` function may come in handy. 
  
Then create a barplot that plots the detections for each species (on the x-axis) for each City using colors. Hint: see 'Barplot of diet' from the Coding Club Tutorial.
    
<details closed><summary>Solution</a></summary>

To determine which species occur in both cities of your choosing, start by filtering down to these cities AND filter to detections `det_days` greater than zero. 
```R
# filter to cities of interest
UWIN_subset <- filter(UWIN_data, City %in% c("atga", "wide")) 

# Filter out zero detections to find species present in your cities of interest
UWIN_subset <- filter(UWIN_subset, det_days > 0)

# Now let's see which species occur in both cities
UWIN_atga <- filter(UWIN_subset, City == "atga")
UWIN_wide <- filter(UWIN_subset, City == "wide")

int <- intersect(UWIN_atga$Species, UWIN_wide$Species)
int
```
       
Filter down to 3 species of interest which occur in both cities
```R
UWIN_subset <- filter(UWIN_subset, Species %in% c("virginia_opossum", "red_fox",
                                                   "weasel_sp"))
```
  
Now, plot detections for each species
```R
ggplot(data = UWIN_subset, aes(x = Species, y = det_days, fill = City)) +
  geom_bar(stat = "identity") +
  labs(title = "Species Detections", x = "Species", y = "Detections") +
  theme_minimal() 
```

<p float="left">
  <img src="./plots/sp_det.png" alt="A plot of species detections in two cities." width="500" height="auto" />
</p>
             
</details>


  
