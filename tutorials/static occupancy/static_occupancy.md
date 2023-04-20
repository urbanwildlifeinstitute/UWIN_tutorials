# UWIN Tutorial: Static Occupancy
*Created by Kimberly Rivera - last updated April 2023 by Kimberly Rivera*

This tutorial is aimed at folks interested and new to occuapncy modeling, or as refesher for those already familiar. This tutorial was designed with the support of outside resources listed below and via workshops developed by Mason Fidino.

### Some helpful references:
1. USGS's ['Occupancy to study wildlife'](https://pubs.usgs.gov/fs/2005/3096/fs20053096.pdf) - Larrisa Bailey
2. Lodestar's [Guide to 'Fitting occupancy models in unmarked'](https://doi90.github.io/lodestar/fitting-occupancy-models-with-unmarked.html) - David Wilkinson

### Tutorial Aims:

#### <a href="#occupancy"> 1. What is occuancy?</a>

#### <a href="#assumptions"> 2. Occupancy model assumptions</a>

#### <a href="#formatting"> 3. Formatting data</a>

#### <a href="#models"> 3. Fitting models</a>

#### <a href="#plots"> 3. Plotting model outputs</a>


<a name="occupancy"></a>

## 1. What is occuancy?

Often in wildlife ecology, we are interested in unpacking the relationship between species occurence and the environment, or species' occupied habitat (where species are found in space and time). Occupancy is a low cost, effective way to model the occurence of species across space and time. 'Occupany' can be defined as the probability that a site is occupied by a particular species. Rather then try to count or estimate the abundance of species in a given environment, we can use passive tools such as cameras traps or acoustic detectors to monitor environments that may or may not host our species (specifically 'unmarked species') of interest. 

<a name="assumptions"></a>

## 1. Occupancy model assumptions

Because detecting wildlife via camera traps, acoustic detectors, etc. is imperfect, we can use occupancy modeling to account for the differences between our observations and reality. We do so by repeatedly visiting sites to determine if our species of interest was detected or not. During this monitoring period we assume that:

1. Detectiton probability is constant across sites or vists or explained by covariates
2. Occupancy probability is constant across sites or visits or explained by covariates
3. The occupancy status does not change over our repeated surveys

We comply to these assumptions by carefully developing our study design (based on our research questions) and by incorperating relevant and measurable covariates. 

<a name="formatting"></a>

## 1. Formatting data

Let's learn more about occupancy through an exmaple. We will use red fox data collected from UWIN Chicago in the summer of 2021. For those who use the Urban Wildlife Information Network's online database, you are welcome to work through your own data. Simply navigate to the [UWIN Database](https://www.urbanwildlifenetwork.org/)> Reports> Occupancy Report. Here you can select one species of interest over a specific date/time range. We would recommend starting with one sampling season (as species may change their occupancy season to season--another type of occupancy model!).  

Let's take a peek at the data! Start by loading in neccessary libraries and `chicago_red_fox.csv`. We will continue to use `dplyr` and `ggplot2`.

```R
# Load in libraries
library(dplyr)
library(ggplot2)

# Set your local working directory
setwd()
fox <- read.csv("full_capture_history.csv", header = TRUE) 

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
