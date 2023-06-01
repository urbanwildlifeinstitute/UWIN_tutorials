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

m1 <- auto_occ(
  formula = ~1  # detection
            ~1, # occupancy
  y = opossum_y
)

summary(m1)

# get expected occupancy, which is around 0.59.
(intercept_preds_psi <- predict(
    m1,
    type = "psi"))

# get average weekly detection probability, which is about 0.53.
(intercept_preds_rho <- predict(
    m1, 
    type = "rho"))

# list example
x <- list(m = matrix(1:6, nrow = 2),
          l = letters[1:8],
          n = c(1:10))

# check that covariate data is ordered identically to the detection data
opossum_covariates$Site
dimnames(opossum_y)[[1]]
all(opossum_covariates$Site == dimnames(opossum_y)[[1]])

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

