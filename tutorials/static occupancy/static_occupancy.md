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

#### <a href="#models"> 4. Fitting models</a>

#### <a href="#plots"> 5. Plotting model outputs</a>


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

Let's learn more about occupancy through an exmaple. We will use raccoon data collected from UWIN Chicago in the summer of 2021. For those who use the Urban Wildlife Information Network's online database, you are welcome to work through your own data. Simply navigate to the [UWIN Database](https://www.urbanwildlifenetwork.org/)> Reports> Occupancy Report. Here you can select one species of interest over a specific date/time range. We would recommend starting with one sampling season (as species may change their occupancy season to season--another type of occupancy model!).  

Let's take a peek at the data! Start by loading in neccessary libraries and `chicago_raccoon.csv`. We will continue to use `dplyr` and `ggplot2`.

```R
# Load in libraries
library(dplyr)
library(ggplot2)

# Set your local working directory
setwd()
raccoon <- read.csv("chicago_raccoon.csv", head = TRUE, skip = 3) 

# Check out what data we're working with.
head(raccoon)
```
We see that this data contains information from 170 sites. We can choose to consider each 'day' as a visit or, if our species are rare or hard to detect, we can collapse each visit into multiple days as an 'occasion'. Given the large 'zero' or 'unoccupied' occurrence of raccoons, we will collapse each visit into a ~6 day occasions.

```R
# let's confirm that there are no repeated sites
length(unique(raccoon$Site))

# Great, no repeats! Now let's collapse our data into 6-day sampling occasions. We can manually collapse days into weekly visits by summing selected rows...
raccoon_wk <- raccoon %>%
  mutate(visit_1 = select(., Day_1:Day_6) %>% rowSums(na.rm = TRUE)) %>% 
  mutate(visit_2 = select(., Day_7:Day_12) %>% rowSums(na.rm = TRUE)) %>% 
  mutate(visit_3 = select(., Day_13:Day_18) %>% rowSums(na.rm = TRUE)) %>% 
  mutate(visit_4 = select(., Day_19:Day_24) %>% rowSums(na.rm = TRUE)) %>% 
  mutate(visit_5 = select(., Day_25:Day_31) %>% rowSums(na.rm = TRUE)) %>% 
  select(-c(Day_1:Day_31))
  
# Then changing counts >0 to '1' and count = 0, to '0'
raccoon_wk <- raccoon_wk %>% 
  mutate(visit_1 = ifelse(visit_1 >= 1, 1, 0)) %>% 
  mutate(visit_2 = ifelse(visit_2 >= 1, 1, 0)) %>% 
  mutate(visit_3 = ifelse(visit_3 >= 1, 1, 0)) %>% 
  mutate(visit_4 = ifelse(visit_4 >= 1, 1, 0)) %>% 
  mutate(visit_5 = ifelse(visit_5 >= 1, 1, 0))
```
There are many ways to collapse this data, so use methods most familiar to you. If you are working with a larger dataset, it may be helpful to build a function to do this or loop through your data and collapse visits into occasions.

Though raccoons have adapted to urban ecosystems, we hypothesize that raccoon occupancy will be highest in proximity to forests and water sources given their preference for wooded and wetlands areas to den and forage. We will use the National Land Cover Database developed by the [United States Geological Survey](https://www.usgs.gov/centers/eros/science/national-land-cover-database) and join landcover covarites to our occasion data. These data was extracted using the `FedData` package in R. Column values are the percent landcover within 1000m of each camera site.  

```R
landcover <- read.csv("Chicago_NLCD_landcover.csv", head = TRUE)
head(landcover)

# Let's join this dataset to our raccoon data. First we need to make sure 'sites' are named the same to join these datasets
colnames(raccoon_wk)
colnames(landcover)

# we'll go ahead and rename 'sites' to 'Site' in the 'landcover' dataset
landcover <- rename(landcover, Site = sites)

# Now we can join our datasets
raccoon_wk <- left_join(raccoon_wk, landcover, by = 'Site')
```



We will be formatting our data to methods outlines in the `unmarked` package. 



