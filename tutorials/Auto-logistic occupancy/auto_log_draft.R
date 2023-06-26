# Load in libraries
library(dplyr)
library(ggplot2)
library(devtools)

devtools::install_github(
  "mfidino/autoOcc",
  build_vignettes = TRUE
)

library(autoOcc)

# Helpful references
# https://masonfidino.com/autologistic_occupancy_model/
# https://github.com/mfidino/autoOcc

# Tutorial guide
# https://github.com/ourcodingclub/tutorials-in-progress/blob/master/Tutorial_publishing_guide.md

# Set your local working directory
setwd("E:/GitHub/UWIN_tutorials/tutorials/Auto-logistic occupancy")

load(file='opossum_det_hist.rda') 
load(file='opossum_covariates.rda') 

# examine data
head(opossum_det_hist)

?format_y()

opossum_y <- format_y(
  x = opossum_det_hist,
  site_column = "Site",
  time_column = "Season",
  history_columns = "Week"
)

opossum_y <- format_y(
  x = opossum_det_hist,
  site_column = 1,
  time_column = 2,
  history_columns = 3:6,
  report = FALSE  # to output without ordering and history report
)

# first week or occasion
head(opossum_y[,,1])

# first sampling period
head(opossum_y[,1,])

# check that covariate data is ordered identically to the detection data
opossum_covariates$Site
dimnames(opossum_y)[[1]]
all(opossum_covariates$Site == dimnames(opossum_y)[[1]])

# list example
x <- list(m = matrix(1:6, nrow = 2),
          l = letters[1:8],
          n = c(1:10))

png("hist_building.png", height = 700, width = 700)
hist(opossum_covariates$Building_age)
dev.off()

png("hist_imperv.png", height = 700, width = 700)
hist(opossum_covariates$Impervious)
dev.off()

png("hist_income.png", height = 700, width = 700)
hist(opossum_covariates$Income)
dev.off()

png("hist_pop_den.png", height = 700, width = 700)
hist(opossum_covariates$Population_density)
dev.off()

png("hist_vacancy.png", height = 700, width = 700)
hist(opossum_covariates$Vacancy)
dev.off()

# we can do this one-by-one...
cov_scaled <- opossum_covariates %>% 
  mutate(Building_age = scale(Building_age)) %>% 
  mutate(Impervious = scale(Impervious)) %>%
  mutate(Income = scale(Income)) %>% 
  mutate(Vacancy = scale(Vacancy)) %>%
  mutate(Population_density = scale(Population_density)) 

# or by writing a function
cov_scaled <- as.data.frame(
  lapply(
    opossum_covariates,
    function(x){
      if(is.numeric(x)){
        scale(x)
      }else{
        x
      }
    }
  )
)

# we can drop the sites before inputting data into auto_occ()
cov_scaled = cov_scaled %>% select(-Site)

m1 <- auto_occ(
  formula = ~1  # detection
  ~1, # occupancy
  y = opossum_y
)

summary(m1)

# now let's fit a model with spatial covariates
# fit a model with occupancy covarites for Impervious cover and Income 
m2 <- auto_occ(
  ~1 # detection
  ~Impervious + Income, # occupancy
  y = opossum_y,
  occ_covs = cov_scaled
)

summary(m2)

# We can also add complexity with a categorical temporal covariate 'Season'
##  Temporally varying covariates need to be a named list.
##  For this example, the seasonal information is in the
##  opossum detection history (opossum_det_hist).

# make named list 
season_frame <- list(
   Season = matrix(
     opossum_det_hist$Season,
     ncol = dim(opossum_y)[2],
     nrow = dim(opossum_y)[1]
   ),
   Impervious = cov_scaled$Impervious,
   Income = cov_scaled$Income
 )


# HAVING PROBLEMS HERE??
m3 <- auto_occ(
   ~1
   ~Season + Impervious + Income,
   y = opossum_y,
   occ_covs = season_frame
 )

 
summary(m3)


# Predicting and Plotting
# get expected occupancy for m1, which is around 0.59.
(intercept_preds_psi <- predict(
  m1,
  type = "psi"))

# get average weekly detection probability for m1, which is about 0.53.
(intercept_preds_rho <- predict(
  m1, 
  type = "rho"))

# get expected occupancy for m2, which is around 0.59.
(intercept_preds_psi <- predict(
  m2,
  type = "psi"))

# get average weekly detection probability for m1, which is about 0.53.
(intercept_preds_rho <- predict(
  m2, 
  type = "rho"))






