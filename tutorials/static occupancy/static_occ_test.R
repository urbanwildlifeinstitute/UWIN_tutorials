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
ggsave("water_hist.tiff", width = 6, height = 6)
ggplot(raccoon_wk, aes(x = water)) +
  geom_histogram() +
  theme_minimal() +
  theme(text = element_text(size = 18)) +
  labs(x = "Proportion water", y = "Site count") 
  
hist(raccoon_wk$forest)
ggsave("forest_hist.tiff", width = 6, height = 6)
ggplot(raccoon_wk, aes(x = forest)) +
  geom_histogram() +
  theme_minimal() +
  theme(text = element_text(size = 18)) +
  labs(x = "Proportion forest", y = "Site count") 


# scale covariates
siteCovs <- siteCovs %>% 
  mutate(water_scale = scale(water)) %>% 
  mutate(forest_scale = scale(forest)) %>% 
  select(-c(water, forest)) # drop unscaled covariates

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

plogis(coef(null_model, type = "state")) # for occupancy
plogis(coef(null_model, type = "det")) # for detection

backTransform(null_model, type = "state")
backTransform(null_model, type = "det")

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
plogis(occ_error)
plogis(det_error)

# Our naive occupancy
siteValue <- apply(X = y,
                   MARGIN = 1, # 1 = across rows
                   FUN = "max", na.rm = TRUE) # This function finds the max value

mean(siteValue)

# Create a new dataframe 
new_dat <- data.frame(forest = seq(from = 0, to = 1, by = 0.05),
                      water_scale = mean(siteCovs$water_scale))
# Scale the data
new_dat <- new_dat %>% 
  mutate(forest_scale = scale(forest))

# Make predictions with these data
pred_forest <- predict(habitat_model, type = "state", newdata = new_dat)
head(pred_forest)

png("occ_forest_basic.png", height = 700, width = 700)
plot(pred_forest$Predicted ~ new_dat$forest_scale, # y-axis ~ x-axis
     type = "l",  # plot out a line
     bty = "l", # box type is an L around plot
     xlab = "Scaled proportion forest", # x label
     ylab = "Occupancy", # y label
     ylim = c(0, 1), # range to y axis
     xlim = c(0,1),
     lwd = 2, # width of the line
     las = 1 # have numbers on y axis be vertical
)
dev.off()
#### Update graph above add RACCONN IN PARTY HAT AT END


# add 95% confidence intervals
lines(pred_forest$lower ~ new_dat$forest_scale, # y-axis ~ x-axis
      lty = 2 # make a checked line
) 
lines(pred_forest$upper ~ new_dat$forest_scale, # y-axis ~ x-axis
      lty = 2 # make a checked line
)

# first merge the two datasets (predicted occupancy and forest data)
all_dat <- bind_cols(pred_forest, new_dat)

ggplot(all_dat, aes(x = forest_scale, y = Predicted)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "orange", alpha = 0.5) +
  geom_path(size = 1) + # adds line
  labs(x = "Proportion forest (scaled)", y = "Occupancy probability") +
  ggtitle("Raccoon Occupancy")+
  scale_x_continuous(limits = c(0,1)) +
  ylim(0,1)+
  theme_classic()+ # drops gray background and grid
  theme(plot.title=element_text(hjust=0.5)) # centers titles
