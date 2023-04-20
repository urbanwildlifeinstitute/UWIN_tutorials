# UWIN Tutorial: Static Occupancy
*Created by Kimberly Rivera - last updated April 2023 by Kimberly Rivera

This tutorial is aimed at folks interested and new to occuapncy modeling, or as refesher for those already familiar. This tutorial was designed with the support of outside resources listed below and via previous tutorials developed by Mason Fidino.

### Tutorial Aims:

#### <a href="#occupancy"> 1. What is occuancy?</a>

#### <a href="#assumptions"> 2. Occupancy Model Assumptions</a>

#### <a href="#formatting"> 3. Formatting data</a>

#### <a href="#models"> 3. Fitting models</a>

#### <a href="#plots"> 3. Plotting model outputs</a>

<a name="occupancy"></a>

## 1. What is occuancy?

### Subheadings like this

Some text



Coding Club Reference tutorial [__here.__](https://ourcodingclub.github.io/tutorials/data-manip-creative-dplyr/)

Let's take a peek at some real data collected by the Urban Wildlife Information Network. Start by loading in neccessary libraries and UWIN data. Today we are going to use `ggplot2` and `dplyr`.

```R
# Load in libraries
library(dplyr)
library(ggplot2)

# Set your local working directory
setwd()
UWIN_data <- read.csv("full_capture_history.csv", header = TRUE) 

# Check out what data we're working with.
head(UWIN_data)
```

### Breaking down our data
These data are summary statistics of wildlife found at unquie sites sampled by camera traps in 19 cities across the US and Canada. Below is a table of City acronyms...

| City                      | Code   |
|---------------------------|--------|
| Atlanta, Georgia          | `atga` |
| Austin, Texas             | `autx` |
| Chicago, Illinois         | `chil` |
| Denver, Colorado          | `deco` |
| Edmonton, Alberta         | `edal` |
| Fort Collins, Colorado    | `foco` |
| Iowa City, Iowa           | `icia` |
| Indianapolis, Indiana     | `inin` |
| Jackson, Mississippi      | `jams` |
| Manhattan, Kansas         | `maks` |
| Madison, Wisconsin        | `mawi` |
| Orange County, California | `occa` |
| Phoenix, Arizona          | `phaz` |
| Rochester, New York       | `rony` |
| Sanford, Florida          | `safl` |
| Salt Lake City, Utah      | `scut` |
| Seattle, Washington       | `sewa` |
| Tacoma, Washington        | `tawa` |
| Wilmington, Delaware      | `wide` |

and descriptions of each column header... 

| Column  | Type      | Description                                                                                                                                       |
|---------|-----------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| Site    | Character | The code for the site name.                                                                                                                       |
| Long    | Longitude | Longitude of site (crs = 4326).                                                                                                                   |
| Lat     | Latitude  | Latitude of site (crs = 4326).                                                                                                                    |
| Crs     | Integer   | Coordinate reference system for the site coordinates.                                                                                             |
| Species | Character | The common-name of a given species.                                                                                                               |
| Season  | Character | The four letter sampling period abbreviation. JA = January, AP = April, JU = July, OC = October. The numbers designate the year (e.g., 19 = 2019) |
| City    | Character | The city code for a given city.                                                                                                                   |
| Y       | Integer   | The number of days the species was detected, Y <= J.                                                                                              |
| J       | Integer   | The number of days a camera was operational on a given deployment at a site.                                                                      |

## Challenge 1. 
### Changing column names
We decided that `Y` and `J` are confusing column names, we keep forgetting what they stand for! Let's update these to be more descriptive names. We will change `Y` to `det_days` and `J` to `cam_days` using `dplyr` functions.

<details closed><summary><a href="https://hello.ca">Solution</a></summary>

```R
UWIN_data <- rename(UWIN_data, det_days = Y, cam_days = J)
head(UWIN_data)
```
             
</details>

  
## Challenge 2. 
### Summarizing and plotting data
Nice work! We decided we're interested in examining four east coast cities: `atga`, `wide`, `rony`, and `safl`. We specifically want to summarize how detections of raccoons vary across these cities (across all sites) and make a bar plot to visualize the differences. 
  
Start by creating a new data set `UWIN_east` for these cities which only includes raccoon detections.
  
<details closed><summary><a href="https://hello.ca">Solution</a></summary>
  
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
  
<details closed><summary><a href="https://hello.ca">Solution</a></summary>
  
```R
det_city <- raccoon_east %>% 
  group_by(City) %>% 
  summarise(det_total = sum(det_days))
```
             
</details>

Good deal. Let's use this new dataframe to make a bar plot. 
  
<details closed><summary><a href="https://hello.ca">Solution</a></summary>
  
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
             
</details>

  
## Challenge 3. 
### More filtering and plotting pratice
Wow, there is a lot of variability of raccoon detections across these cities! Let's see how detections vary across a few other species in two of these cities. Choose two of these cities and create a new dataframe for three new species (e.g. not raccoon) which occur in both cities. Hint: the `intersect` function may come in handy. 
  
Then create a barplot that plots the detections for each species (on the x-axis) for each City using colors. Hint: see 'Barplot of diet' from the Coding Club Tutorial.
    
<details closed><summary><a href="https://hello.ca">Solution</a></summary>

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
             
</details>
