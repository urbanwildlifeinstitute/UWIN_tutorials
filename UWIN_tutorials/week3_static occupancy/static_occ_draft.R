# Load in libraries
library(dplyr)
library(ggplot2)

# Helpful references
# https://doi90.github.io/lodestar/fitting-occupancy-models-with-unmarked.html
# file:///E:/LPZ%20Coordinator/uwin_R/Lesson_6_Occupancy%20modeling.pdf
# https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/writing-mathematical-expressions

# Tutorial guide
# https://github.com/ourcodingclub/tutorials-in-progress/blob/master/Tutorial_publishing_guide.md

# Set your local working directory
setwd("E:/GitHub/UWIN_tutorials/tutorials/static occupancy")

raccoon <- read.csv("chicago_raccoon.csv", head = TRUE, skip = 3) # we use skip to deal with first 3 lines of 
head(raccoon)                                                     # notes on start and end date

# We see that this data contains information from 170 sites. We can choose to consider each 'day'
# as a 'visit' or, if our species are rare or hard to detect, we can collapse each visit into 
# multiple days. Given the large 'zero' or 'unoccupied' occurrence of raccoons, we will collapse each visit into a ~6 day visits

# let's confirm that there are no repeated sites
length(unique(raccoon$Site))

# Great. Now let's collapse our data into 6-day sampling visits. We can do this a couple of ways...

# 1. We can manually collapse days into weekly visits by summing selected rows...

# First we need to make sure we remove all rows with only NA's, otherwise our next summing function
# will convert those NA's to zeros

# # Filter out rows with all NA's
# raccoon_wk <- filter(raccoon, rowSums(is.na(raccoon[7:37])) != ncol(raccoon[7:37]))
# 
# # Below is problematic b/c changes NAs to zeros
# raccoon_wk <- raccoon_wk %>%
#   mutate(visit_1 = select(., Day_1:Day_6) %>% rowSums(na.rm = TRUE)) %>% 
#   mutate(visit_2 = select(., Day_7:Day_12) %>% rowSums(na.rm = TRUE)) %>% 
#   mutate(visit_3 = select(., Day_13:Day_18) %>% rowSums(na.rm = TRUE)) %>% 
#   mutate(visit_4 = select(., Day_19:Day_24) %>% rowSums(na.rm = TRUE)) %>% 
#   mutate(visit_5 = select(., Day_25:Day_31) %>% rowSums(na.rm = TRUE)) %>% 
#   select(-c(Day_1:Day_31))
# 
# # Then changing counts >0 to '1' and count = 0, to '0'
# raccoon_wk <- raccoon_wk %>% 
#   mutate(visit_1 = ifelse(visit_1 >= 1, 1, 0)) %>% 
#   mutate(visit_2 = ifelse(visit_2 >= 1, 1, 0)) %>% 
#   mutate(visit_3 = ifelse(visit_3 >= 1, 1, 0)) %>% 
#   mutate(visit_4 = ifelse(visit_4 >= 1, 1, 0)) %>% 
#   mutate(visit_5 = ifelse(visit_5 >= 1, 1, 0))

# OR, we could use a loop to do this all at once...Mason?
# get all columns that start with day
day_cols <- raccoon[,grep("^Day_",colnames(raccoon))]

# split them into six day groups
n_weeks <- ceiling(ncol(day_cols)/6)
week_groups <- rep(1:n_weeks, each = 6)[1:ncol(day_cols)]

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

week_summary <- t( # this transposes our matrix
  apply(
    day_cols, 
    1, # 1 is for rows
    combine_days,
    groups = week_groups
  )
)

colnames(week_summary) <- paste0("Week_",1:n_weeks)
raccoon_wk <- raccoon[,-grep("^Day_", colnames(raccoon))]
raccoon_wk <- cbind(raccoon_wk, week_summary)

# Now one issue that may arrive from these groupings is that when occasion lengths don't evenly 
# break down into our total sampling days, we may have uneven occasions lengths as done above. Here we have
# five, 6 day occasions, and one, 1 day occasion. We can either combine this last day into the fifth occasion
# or drop that day. For now, let's drop that last sampling day

raccoon_wk <- raccoon_wk %>% 
  select(-Week_6)

# Though raccoons have found ways to adapt to urban ecosystems, we hypothesize that
# raccoon occupancy will be highest with proximity to forests and water sources given 
# their preference for wooded and wetlands areas to den and forage. To model this, let's use 
# the National Land Cover Database developed by the United States Geological Survey and join it with our data
# https://www.usgs.gov/centers/eros/science/national-land-cover-database

# This dataset was extracted using the FedData package. Column values are the % landcover types
# within 1000m of each site coordinate
# chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/https://cran.r-project.org/web/packages/FedData/FedData.pdf
landcover <- read.csv("Chicago_NLCD_landcover.csv", head = TRUE)
head(landcover)

# we need to make sure 'sites' are named the same to join these datasets
colnames(raccoon_wk)
colnames(landcover)

# we'll go ahead and rename 'sites' to 'Site' in the 'landcover' dataset
landcover <- rename(landcover, Site = sites) 

# Now we can join our datasets and drop columns where there are NA site covarites
raccoon_wk <- left_join(raccoon_wk, landcover, by = 'Site') %>% 
  na.omit(.)

library("unmarked")
?unmarkedFrameOccu()

y <- raccoon_wk %>% 
  select(Week_1:Week_5)

siteCovs <- raccoon_wk %>% 
  select(c(water, forest))

# We should also examine our covariates of interest to see how they distribute
png("siteCovs_water.png", height = 700, width = 700)
hist(siteCovs$water)
dev.off()

png("siteCovs_forest.png", height = 700, width = 700)
hist(siteCovs$forest)
dev.off()

# We probably want to scale these covariates 
siteCovs <- siteCovs %>% 
  mutate(water_scale = scale(water)) %>% 
  mutate(forest_scale = scale(forest)) %>% 
  select(-c(water, forest))

# Make sure this is a data.frame object
siteCovs_df <- data.frame(siteCovs)
  
raccoon_occ <- unmarkedFrameOccu(y = y, siteCovs = siteCovs_df)
summary(raccoon_occ)

# Be mindful that it is OK to have missing or NA observation data. BUT for each observation
# there must be affiliated covariate data, otherwise this data will not be considered in the model.
# We only have landcover data for 119/170 sites so we will see these sites dropped in our model

# Fitting models
# Let's fit two models, one for a null hypothesis:
# null: raccoon occupancy is constant across sites
# habitat hypothesis: raccoon occupancy is explained habitat metrics, water and forest,
# where occupancy increased with increasing proportions of water and forests
?occu()

null_model <- occu(~1 # detection
                        ~1, # occupancy
                        data = raccoon_occ)
null_model

habitat_model <- occu(~1 # detection
                      ~ forest_scale + water_scale, # occupancy
                        data = raccoon_occ)
habitat_model


# Now we want to compare our models. Thankfully `unmarked` has a function for that
fitlist <- fitList(m1 = null_model, m2 = habitat_model)
modSel(fitlist)

# it looks like our null model best explains our data. Let's look at our model parameters 
# for detection and occupancy probabilities
plogis(coef(null_model, type = "state")) # for occupancy
plogis(coef(null_model, type = "det")) # for detection

# Do above but also include 95% confidence intervals
occ_error <- cbind(coef(null_model, type = "state"),
                         confint(null_model, type = "state"))
# do same for detection
det_error <- cbind(coef(null_model, type = "det"),
                         confint(null_model, type = "det"))
# convert back to probability
plogis(occ_error)
plogis(det_error)


# We can also compare these outputs to a naive occupancy estimate, meaning if we 
# did not account for imperfect detection. We calculate this by taking the  
# number of sites where the species was observed divided by the total number of sites.

siteValue <- apply(X = y,
                   MARGIN = 1, # 1 = across rows
                   FUN = "max", na.rm = TRUE) # This function finds the max value

mean(siteValue)

# This is very close but smaller than our null model
# ASK MASON ON THIS. SHOULDN'T IS BE LARGER?

# If were to have stuck with our habitat hypothesis, we could use model outputs to predict
# occupancy across percent forest or water. Let's try this for forest.

# We know that our percent forest ranges from 0 to 1. So we will predict across these
# proportions in intervals of .05 and hold water equal to the mean scaled value

new_dat <- data.frame(forest = seq(from = 0, to = 1, by = 0.05),
                     water_scale = mean(siteCovs$water_scale))
new_dat <- new_dat %>% 
  mutate(forest_scale = scale(forest)) 

# Make predictions with this data
pred_forest <- predict(habitat_model, type = "state", newdata = new_dat)
head(pred_forest)

# Now we can plot our predictions!

# plot 
png("occ_forest_basic.png", height = 700, width = 700)
plot(pred_forest$Predicted ~ new_dat$forest_scale, # y-axis ~ x-axis
     type = "l",  # plot out a line
     bty = "l", # box type is an L around plot
     xlab = "Scaled proportion forest", # x label
     ylab = "Occupancy", # y label
     ylim = c(0, 1), # range to y axis
     lwd = 2, # width of the line
     las = 1 # have numbers on y axis be vertical
)

# add 95% confidence intervals
lines(pred_forest$lower ~ new_dat$forest_scale, # y-axis ~ x-axis
      lty = 2 # make a checked line
) 
lines(pred_forest$upper ~ new_dat$forest_scale, # y-axis ~ x-axis
      lty = 2 # make a checked line
)
dev.off()
# Now with ggplot

# first merge our datasets
all_dat <- bind_cols(pred_forest, new_dat)


ggsave("occ_forest_ggplot.tiff", width = 6, height = 6)
ggplot(all_dat, aes(x = forest_scale, y = Predicted)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "orange", alpha = 0.5) +
  geom_path(size = 1) + # adds line
  labs(x = "Proportion forest (scaled)", y = "Occupancy probability") +
  ggtitle("Raccoon Occupancy")+
  scale_x_continuous(limits = c(0,1)) +
  ylim(0,1)+
  theme_classic()+ # drops gray background and grid
  theme(plot.title=element_text(hjust=0.5)) # centers titles


# Challenge---------------------------------------------------------------------
# Challenge, do this for this hypothesis: raccoon occupancy is explained urban intensity,
# where raccoon occupancy decreased with urban intensity
siteCovs_urban <- raccoon_wk %>% 
  select(c(urban))

# We probably want to scale these covariates 
siteCovs_urban <- siteCovs_urban %>% 
  mutate(urban_scale = scale(urban)) %>% 
  select(-c(urban))

siteCovs_urban_df <- data.frame(siteCovs_urban)

raccoon_occ_urban <- unmarkedFrameOccu(y = y, siteCovs = siteCovs_urban_df)
summary(raccoon_occ_urban)

urban_model <- occu(~1 # detection
                    ~ urban_scale, # occupancy
                    data = raccoon_occ_urban)
urban_model


## Testing online .md tutorial
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

setwd("D:/GitHub/UWIN_tutorials/tutorials/static occupancy") # update to your local folder containing project files or create an R project which will navigate you to this folder
raccoon <- read.csv("chicago_raccoon.csv", head = TRUE, skip = 3) 

# Check out what data we're working with.
head(raccoon)

# Let's confirm that there are no repeated sites
length(unique(raccoon$Site))

# Great, no repeats! Now let's collapse our data into 6-day sampling occasions. 
# Let's grab all the columns that start with day...
day_cols <- raccoon[,grep("^Day_",colnames(raccoon))]

# split them into six day groups...
n_weeks <- ceiling(ncol(day_cols)/6)
week_groups <- rep(1:n_weeks, each = 6)[1:ncol(day_cols)]

# and write a function that keeps each occasion with all NA's as such and those 
# with all 0's as 0, and those with at least 1 detection, as 1
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

# drop visits from data.frame
raccoon_wk <- raccoon[,-grep("^Day_", colnames(raccoon))]

# and add occasions
raccoon_wk <- cbind(raccoon_wk, week_summary)

raccoon_wk <- raccoon_wk %>% 
  select(-Week_6)

landcover <- read.csv("Chicago_NLCD_landcover.csv", head = TRUE)
head(landcover)

colnames(raccoon_wk)
colnames(landcover)

landcover <- rename(landcover, Site = sites)

raccoon_wk <- left_join(raccoon_wk, landcover, by = 'Site') %>% 
  na.omit(.)

y <- raccoon_wk %>% 
  select(Week_1:Week_5)

siteCovs <- raccoon_wk %>% 
  select(c(water, forest))

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

# scale covariates
siteCovs <- siteCovs %>% 
  mutate(water_scale = scale(water)) %>% 
  mutate(forest_scale = scale(forest))

siteCovs_df <- data.frame(siteCovs)

# Now we can make our unmarkedFrameOccu() dataframe
raccoon_occ <- unmarkedFrameOccu(y = y, siteCovs = siteCovs_df)

# examine covariate details and site summary
summary(raccoon_occ)

null_model <- occu(~1 # detection
                   ~1, # occupancy
                   data = raccoon_occ)

habitat_model <- occu(~1 # detection
                      ~ forest_scale + water_scale, # occupancy
                      data = raccoon_occ)

# examine model estimates and standard errors
null_model
habitat_model

fitlist <- fitList(m1 = null_model, m2 = habitat_model)
modSel(fitlist)

# We can also use `confit` to calculate the associated error for each estimate
# 95% confidence intervals for occupancy
occ_error <- cbind(coef(null_model, type = "state"),
                   confint(null_model, type = "state"))
# 95% confidence intervals for detection
det_error <- cbind(coef(null_model, type = "det"),
                   confint(null_model, type = "det"))

plogis(occ_error)
plogis(det_error)

siteValue <- apply(X = y,
                   MARGIN = 1, # 1 = across rows
                   FUN = "max", na.rm = TRUE) # This function finds the max value

mean(siteValue)

# recreate 'clean' data for plotting later
forest_real <- c(0, 0.5)

# Create a prediction data.frame and make sure to use the same covariate names as included in the occupancy model
dat_plot <- data.frame(
  forest_scale = seq(forest_real[1], forest_real[2], length.out = 400),
  water_scale = 0 # zero because water has been scaled/centered
)

# rescale 'clean' forest data exactly how we did in our model
dat_pred <- dat_plot
dat_pred$forest_scale <- (dat_pred$forest_scale - mean(siteCovs_df$forest)) / sd(siteCovs_df$forest)

# Make predictions with these data
pred_forest <- predict(habitat_model, type = "state", newdata = dat_pred)
head(pred_forest)

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
