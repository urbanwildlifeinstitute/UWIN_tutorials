# UWIN Tutorial: Static Occupancy
*Created by Kimberly Rivera - last updated October 2023 by Kimberly Rivera*

This tutorial is aimed at folks interested and new to occupancy modeling, or as a refresher for those already familiar. This tutorial was designed with the support of outside resources listed below and via workshops developed by Mason Fidino.

### Some helpful references:
1. USGS's ['Occupancy to study wildlife'](https://pubs.usgs.gov/fs/2005/3096/fs20053096.pdf) - Larrisa Bailey
2. Lodestar's [Guide to 'Fitting occupancy models in unmarked'](https://doi90.github.io/lodestar/fitting-occupancy-models-with-unmarked.html) - David Wilkinson

### Tutorial Aims:

#### <a href="#occupancy"> 1. What is occupancy?</a>

#### <a href="#assumptions"> 2. Occupancy model assumptions</a>

#### <a href="#formatting"> 3. Formatting data</a>

#### <a href="#models"> 4. Fitting models</a>

#### <a href="#plots"> 5. Predicting & plotting model outputs</a>


<a name="occupancy"></a>

## 1. What is occupancy?

Often in wildlife ecology, we are interested in unpacking the relationship between species presence and the environment, or species' occupied habitat (where species are found in space and time). 'Occupancy' is an effective way to model the occurrence of species and can be defined as the probability that a site (space) is occupied by a particular species at a particular time, mathematically represented as $\Psi$.

Rather then try to count or estimate the abundance of species in a given environment, we can use passive tools such as cameras traps or acoustic detectors, to monitor areas that may or may not host species (specifically 'unmarked species') of interest. The term 'unmarked' means individuals cannot be identified via unique markings or tags (such as ear tags or spot patterns).


However, survey tools and our ability to detect species is imperfect. Thankfully, we can use occupancy models to account for these uncertainties, therefore improving our estimate of a species 'true' occupancy (the true presence of a species) state from our 'observed' occupancy state (data we collect on species presence). We do this by repeatedly visiting sampling sites, collecting information about our sites, and feeding this information into our model. When conducting surveys, the following may occur:

<p float="center">
  <img src="./plots/det_states.jpg" alt="Figure on occupancy states" width="500" height="auto" />

</p>

<a name="assumptions"></a>



We can convert surveys into mathematical equations by creating 'detection histories'. These typically are formed as tables of '0's (no species was detected) and '1's (a species was detected) where rows indicate sites and columns indicate repeat visits. For example:

<p float="center">
  <img src="./plots/det_hist.png" alt="Figure of two detection histories along with their mathematical counterparts" width="700" height="auto" />
</p>

<a name="assumptions"></a>
In these equations, $\Psi$ represents the probability a site is occupied by a species while ***p*** represents the probability of detecting a species during that particular visit.  


## 2. Occupancy model assumptions

Under this model we assume that:

1. Detection probability is constant across sites or visits, or explained by covariates
2. Occupancy probability is constant across sites or visits. or explained by covariates
3. The occupancy status does not change over our repeated surveys (also known as 'closed' to change)
4. There are no false detections (detecting a species when it is truly *not* there or misidentifying a species)


We comply to these assumptions by carefully developing our study design (based on our research questions) and by incorporating relevant and measurable covariates (e.g. environmental variability). 

<a name="formatting"></a>

## 3. Formatting data

Let's learn more about occupancy through an example. We will use raccoon data collected from UWIN Chicago in the summer of 2021. For those who use the Urban Wildlife Information Network's online database, you are welcome to work through your own data. Simply navigate to the [UWIN Database](https://www.urbanwildlifenetwork.org/)> Reports> Occupancy Report. Here you can select one species of interest over a specific date/time range. We would recommend starting with one sampling season (as species may change their occupancy season to season--another type of occupancy model!).  

Let's take a peek at the data! Start by loading in necessary libraries and `chicago_raccoon.csv`. We will continue to use `dplyr` and `ggplot2`.

```R
# Load in libraries
install.packages("dplyr")
install.packages("ggplot2")
library(dplyr)
library(ggplot2)

# Set your local working directory
setwd()
raccoon <- read.csv("chicago_raccoon.csv", head = TRUE, skip = 3) 

# Check out what data we're working with.
head(raccoon)
```
By glancing at our environment, we see that this data contains information from 170 sites. We can choose to consider each 'day' as a visit or, if our species are rare or hard to detect, we can collapse each visit into multiple days as an 'occasion'. Given the large 'zero' or 'unoccupied' occurrence of raccoons, we will collapse each visit into a ~6 day occasions.

```R
# Let's confirm that there are no repeated sites
length(unique(raccoon$Site))

# Great, no repeats! Now let's collapse our data into 6-day sampling occasions. Let's grab all the columns that start with day...
day_cols <- raccoon[,grep("^Day_",colnames(raccoon))]

# split them into six day groups...
n_weeks <- ceiling(ncol(day_cols)/6)
week_groups <- rep(1:n_weeks, each = 6)[1:ncol(day_cols)]

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
week_summary <- t( # this transposes our matrix
  apply(
    day_cols, 
    1, # 1 is for rows
    combine_days,
    groups = week_groups
  )
)

# Now update names
colnames(week_summary) <- paste0("Week_",1:n_weeks)

# drop visits
raccoon_wk <- raccoon[,-grep("^Day_", colnames(raccoon))]

# and add occasions
raccoon_wk <- cbind(raccoon_wk, week_summary)
```
Now, one issue that may arise from grouping occasions on a specific number of days is that when occasion lengths don't evenly break down into our total sampling days, we may have uneven occasions lengths as seen above (6 occasions in 31 days). We can either combine the remainder day into the fifth occasion or simply drop that day. For now, we will drop the last sampling day.

```R
raccoon_wk <- raccoon_wk %>% 
  select(-Week_6)
```

Though raccoons have adapted to urban ecosystems, we hypothesize that raccoon occupancy will be highest in proximity to forests and water sources given their preference for wooded and wet areas to den and forage. We will use the National Land Cover Database developed by the [United States Geological Survey](https://www.usgs.gov/centers/eros/science/national-land-cover-database) and join landcover covariates to our occasion data. These data were extracted using the `FedData` package in R. Learn more about mapping in the ['Detection Mapping'](https://github.com/urbanwildlifeinstitute/UWIN_tutorials/tree/main/tutorials/Detection%20Mapping) tutorial. Column values are the percent landcover within 1000m of each camera site.  

```R
landcover <- read.csv("Chicago_NLCD_landcover.csv", head = TRUE)
head(landcover)

# Let's join this dataset to our raccoon data. First we need to make sure 'sites' are named the same to join these datasets
colnames(raccoon_wk)
colnames(landcover)

# we'll go ahead and rename 'sites' to 'Site' in the 'landcover' dataset
landcover <- rename(landcover, Site = sites)

# Now we can join our datasets and drop NA's. 
raccoon_wk <- left_join(raccoon_wk, landcover, by = 'Site') %>% 
  na.omit(.)
```
Be mindful that it is OK to have missing or NA observation data BUT for each observation, there must be affiliated covariate data, otherwise this data will not be considered in the model and we won't be able to compare models using AIC. We only have landcover data for 119/170 sites, so these sites are dropped using `na.omit()`.

We will be using the `unmarked` R package to model our data. Therefore, our data has to be formatted to `occu()` model fitting function within the package using a `unmarkedFrameOccu()` dataframe. 

```R
install.packages("unmarked")
library("unmarked")
?unmarkedFrameOccu()
```
We see there are a few necessary arguments we need to specify to run the `occu()` function: `y`, `siteCovs`, and `obsCovs`. Remember assumptions 1&2 from above? Occupancy and detection probability is constant across sites or visits, unless they are explained by covariates. For our study, we believe that our detection probability is constant, but raccoon occupancy will be explained by tree cover and water. Let's continue formatting our data to model an occupancy model based on this hypothesis.

```R
y <- raccoon_wk %>% 
  select(Week_1:Week_5)

siteCovs <- raccoon_wk %>% 
  select(c(water, forest))

```
We should also examine our covariates and note their structure, scale, and distribution.
```R
ggplot(raccoon_wk, aes(x = water)) +
  geom_histogram() +
  theme_minimal() +
  theme(text = element_text(size = 18)) +
  labs(x = "Proportion water", y = "Site count")

ggplot(raccoon_wk, aes(x = forest)) +
  geom_histogram() +
  theme_minimal() +
  theme(text = element_text(size = 18)) +
  labs(x = "Proportion forest", y = "Site count") 
```

<p float="left">
  <img src="./plots/water_hist.png" alt="A plot of counts of proportion of water at each site" width="400" height="auto" />
  <img src="./plots/forest_hist.png" alt="A plot of counts of proportion of forest at each site" width="400" height="auto" /> 
</p>

In this example, we have two covariates which share the same scale/units and fall within a small range of values. Therefore, our model should converge without problem. However, it is common in occupancy models to incorporate covariates of various scales and ranges, thus scaling would be necessary. In addition, we also need to consider the biological meaning of each covariate within the framework of our model and system. For occupancy, it is generally helpful to make the intercept of the model the mean of each covariate. This can help us interpret whether species occurrence falls below or above average values. 

Thus, we will scale both 'water' and 'forest' before adding them to our `occu()` data.frame.

```R
# scale covariates
siteCovs <- siteCovs %>% 
  mutate(water_scale = scale(water)) %>% 
  mutate(forest_scale = scale(forest))

siteCovs_df <- data.frame(siteCovs)

# Now we can make our unmarkedFrameOccu() dataframe
raccoon_occ <- unmarkedFrameOccu(y = y, siteCovs = siteCovs_df)

# examine covariate details and site summary
summary(raccoon_occ)
```

<a name="models"></a>

## 4. Fitting models

Let's fit two models, one for a null hypothesis and one which considers the habitat metrics mentioned above: <br />
**null** - raccoon occupancy is constant across sites <br />
**habitat hypothesis** - raccoon occupancy is explained by habitat variables, water and forest, where raccoon occupancy increases with increasing proportions of water and forests

```R
# learn more about this function modeled after MacKenzie et al. (2002)
?occu()

null_model <- occu(~1 # detection
                        ~1, # occupancy
                        data = raccoon_occ)

habitat_model <- occu(~1 # detection
                      ~ forest_scale + water_scale, # occupancy
                        data = raccoon_occ)
# examine model estimates and standard errors
null_model
habitat_model
```

We can also use functions `fitList` and `modSel` in `unmarked` to compare our models using AIC (Akaike information criterion which  estimates the prediction error/ quality of the models).

```R
fitlist <- fitList(m1 = null_model, m2 = habitat_model)
modSel(fitlist)
```
Our best fit model is that with the lowest AIC. Here, we see that our null model has the lowest AIC. Let's examine the model parameters for detection and occupancy from this model

```R

# We can also use `confit` to calculate the associated error for each estimate
# 95% confidence intervals for occupancy
occ_error <- cbind(coef(null_model, type = "state"),
                         confint(null_model, type = "state"))
# 95% confidence intervals for detection
det_error <- cbind(coef(null_model, type = "det"),
                         confint(null_model, type = "det"))
```
This occupancy model is fit with a log-link function, thus our estimates are given as log-odds or the ratio of the probability of success and the probability of failure. These can be tricky to interpret so it is good practice to convert these estimate to probabilities on a scale of 0 to 1. 

```R
# Convert confidence intervals back to probability from log-odds estimate
# plogis() = to exp() / 1 + exp()
plogis(occ_error)
plogis(det_error)
```
How about **naive occupancy**? You may have heard of this term before and it simply means the raw estimate without accounting for imperfect detection. This is calculated by counting the number of sites where the species was observed and dividing that number by the total number of sites. Note that this value should always be smaller than the estimated occupancy. 

```R
# Our naive occupancy
siteValue <- apply(X = y,
                   MARGIN = 1, # 1 = across rows
                   FUN = "max", na.rm = TRUE) # This function finds the max value

mean(siteValue)
```

<a name="plots"></a>

## 5. Predicting & plotting model outputs

Though our null hypothesis was most supported (e.g. a lower AIC), we can use the `habitat_model` to exemplify how to predict occupancy across covariates, or in this example, proportion of forest or water. Let's plot how occupancy changes across varying proportions of forest.

To do this we need to consider two types of data, our original forest values, and the scaled values we fed into our model. Let's examine the ranges of those data to inform our prediction data set.

```R
# examine the ranges of both data types
range(siteCovs_df$forest)
range(siteCovs_df$forest_scale)
```
Since we want to make a 'clean' or pretty plot, we will want to use the real range of our forest data to pick our plotting values without extrapolating our model. Here, our real (unscaled) 'forest' data ranges from 0 to .49. For plotting purposes, we will create a new prediction dataframe from 0 to .5 and scale this clean data set in the same way we scaled our real data fed into the model. We must also add other model covariate data into our predicted dataframe, in this case, water. Since we are just interested in how occupancy changes across variation in forest cover, we will hold water to it's mean scaled value, or zero (remember when we scale data, the means will center on zero). 

```R
# recreate 'clean' data for plotting later
forest_real <- c(0, 0.5)

# Create a prediction dataframe and make sure to use the same covariate names as included in the occupancy model
dat_plot <- data.frame(
  forest_scale = seq(forest_real[1], forest_real[2], length.out = 400),
  water_scale = 0 # zero because water has been scaled/centered
)

# rescale 'clean' forest data exactly how we did in our model
dat_pred <- dat_plot
dat_pred$forest_scale <- (dat_pred$forest_scale - mean(siteCovs_df$forest)) / sd(siteCovs_df$forest)
```
Now that we have the cleaned version of our data scaled, we are ready to make predictions and plot. 
```R
# Make predictions with these data
pred_forest <- predict(habitat_model, type = "state", newdata = dat_pred)
head(pred_forest)
```
Note that the `predict()` function converts data into probabilities so we do not need to use `plogis()` as we have done previously with the output of the `occu()`

We can use base R to plot our predicted occupancy values and confidence intervals on the y-axis and our clean/pretty covariate data on the x-axis.
```R
plot(pred_forest$Predicted ~ dat_plot$forest_scale, # y-axis ~ x-axis
     type = "l",  # plot out a line
     bty = "l", # box type is an L around plot
     xlab = "Proportion forest", # x label
     ylab = "Occupancy", # y label
     ylim = c(0, 1), # range to y axis
     xlim = c(0,.5),
     lwd = 2, # width of the line
     las = 1 # have numbers on y axis be vertical
)
# add 95% confidence intervals
lines(pred_forest$lower ~ dat_plot$forest_scale, # y-axis ~ x-axis
      lty = 2 # make a checked line
) 
lines(pred_forest$upper ~ dat_plot$forest_scale, # y-axis ~ x-axis
      lty = 2 # make a checked line
)
```

<p float="center">

  <img src="./plots/occ_forest_basic_corrected.png" alt="Occupancy plot of raccoons using plot()" width="500" height="auto" />

</p>

We can also plot this figure using `ggplot` functions.
  
```R
# first merge the two datasets (predicted occupancy and forest data)
all_dat <- bind_cols(pred_forest, dat_plot)

ggplot(all_dat, aes(x = forest_scale, y = Predicted)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "orange", alpha = 0.5) +
  geom_path(size = 1) + # adds line
  labs(x = "Proportion forest", y = "Occupancy probability") +
  ggtitle("Raccoon Occupancy")+
  scale_x_continuous(limits = c(0,.5)) +
  ylim(0,1)+
  theme_classic()+ # drops gray background and grid
  theme(plot.title=element_text(hjust=0.5), axis.text.x = element_text(size = 15), 
        text = element_text(size = 18))
  ```
<p float="center">
  <img src="./plots/occ_forest_ggplot_corrected.png" alt="Occupancy plot of raccoons using ggplot" width="500" height="auto" />
</p>


Nice work! If you are interested in furthering your occupancy journey, try this tutorial again with your own data or check out other UWIN tutorials like ['Autologistic occupancy'](https://github.com/urbanwildlifeinstitute/UWIN_tutorials/tree/main/tutorials/Auto-logistic%20occupancy).


<p float="center">
  <img src="./plots/raccoon.png" alt="Image of raccoon" width="500" height="auto" />
</p>


