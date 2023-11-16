# Load in libraries
library(dplyr)
library(ggplot2)

# Set your local working directory
setwd("E:/GitHub/UWIN_tutorials/tutorials/static occupancy")
raccoon <- read.csv("chicago_raccoon.csv", head = TRUE, skip = 3) 

# Check out what data we're working with.
head(raccoon)

### Make a comment that 170 sites comes from environment NOT head() function
### also check out skim package
install.packages("skimr")
library(skimr)
skim(raccoon)

# Let's confirm that there are no repeated sites
length(unique(raccoon$Site))

# Great, no repeats! Now let's collapse our data into 6-day sampling occasions. Let's grab all the columns that start with day...
day_cols <- raccoon[,grep("^Day_",colnames(raccoon))]

# split them into six day groups...
n_weeks <- ceiling(ncol(day_cols)/6)
week_groups <- rep(1:n_weeks, each = 6)[1:ncol(day_cols)]

# and write a function that keeps each occasion with all NA's as such and those > 0 as 1

### and write a function that keeps each occasion with all NA's as such and those with all 0's as 0,
# and those with at least 1 detection, as 1
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
raccoon_wk <- raccoon[,-grep("^Day_", colnames(raccoon))]
raccoon_wk <- cbind(raccoon_wk, week_summary)

raccoon_wk <- raccoon_wk %>% 
  select(-Week_6)

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

install.packages("unmarked")
library("unmarked")
?unmarked()
?unmarkedFrameOccu()

y <- raccoon_wk %>% 
  select(Week_1:Week_5)

siteCovs <- raccoon_wk %>% 
  select(c(water, forest))

# We should also examine our covariates of interest to see if they should be scaled
hist(raccoon_wk$water)
ggsave("water_hist.png", width = 4)
ggplot(raccoon_wk, aes(x = water)) +
  geom_histogram() +
  theme_minimal() +
  theme(text = element_text(size = 18)) +
  labs(x = "Proportion water", y = "Site count") 
  
hist(raccoon_wk$forest)
ggsave("forest_hist.png", width = 4)
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
summary(raccoon_occ)

?occu()

null_model <- occu(~1 # detection
                   ~1, # occupancy
                   data = raccoon_occ)

habitat_model <- occu(~1 # detection
                      ~ forest_scale + water_scale, # occupancy
                      data = raccoon_occ)
null_model
habitat_model

fitlist <- fitList(m1 = null_model, m2 = habitat_model)
modSel(fitlist)


# We can also use `confit` to calculate the associated error
# 95% confidence intervals for occupancy
occ_error <- cbind(coef(null_model, type = "state"),
                   confint(null_model, type = "state"))
# 95% confidence intervals for detection
det_error <- cbind(coef(null_model, type = "det"),
                   confint(null_model, type = "det"))

### REDEFINE PSI AND DIFF BTW PROBABAILITY * MAKE SURE IN PPWT 
## What if a coef vs. probability-----------------------------------------------

# Convert confidence errors back to probability

# plogis(coef(null_model, type = "state")) # for occupancy
# plogis(coef(null_model, type = "det")) # for detection

# backTransform(null_model, type = "state")
# backTransform(null_model, type = "det")

plogis(occ_error)
plogis(det_error)

# We can also use `confit` to calculate the associated error on the probability scale
# # 95% confidence intervals for occupancy
# occ_error_prob <- cbind(plogis(coef(null_model, type = "state")),
#                           plogis(confint(null_model, type = "state")))
# # 95% confidence intervals for detection
# det_error_prob <- cbind(coef(null_model, type = "det"),
#                    confint(null_model, type = "det"))

# Our naive occupancy
siteValue <- apply(X = y,
                   MARGIN = 1, # 1 = across rows
                   FUN = "max", na.rm = TRUE) # This function finds the max value

mean(siteValue)

# get range of data, look at it, and decide on a pretty range
#  of values. Here, forest real is basically between 0 and 0.5, so we
#  will use that for our range.

# examine the ranges of both data types
range(siteCovs_df$forest)
range(siteCovs_df$forest_scale)

# recreate 'clean' data to simplify plotting later
forest_real <- c(0, 0.5)

# Create a prediction dataframe and make sure to use the same covariate names
# as included in the occupancy model
dat_plot <- data.frame(
  forest_scale = seq(forest_real[1], forest_real[2], length.out = 400),
  water_scale = 0 # zero because water has been centered
)

# rescale 'clean' forest data exactly how we did in our model
dat_pred <- dat_plot
dat_pred$forest_scale <- (dat_pred$forest_scale - mean(siteCovs_df$forest)) / sd(siteCovs_df$forest)


# Make predictions with these data
pred_forest <- predict(habitat_model, type = "state", newdata = dat_pred)
head(pred_forest)

png("plots/occ_forest_basic_corrected.png", height = 800, width = 800)
par(mar=c(5,7,4,2))
plot(pred_forest$Predicted ~ dat_plot$forest_scale, # y-axis ~ x-axis
     cex.lab=2, cex.axis=2,
     type = "l",  # plot out a line
     bty = "l", # box type is an L around plot
     xlab = "Proportion forest", # x label
     ylab = "Occupancy\n", # y label
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
dev.off()

# first merge the two datasets (predicted occupancy and forest data)
all_dat <- bind_cols(pred_forest, dat_plot)

ggsave("plots/occ_forest_ggplot_corrected.tiff", width = 6, height = 6)
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
