# Load in libraries
library(dplyr)
library(ggplot2)

# Helpful references
# https://masonfidino.com/autologistic_occupancy_model/
# https://github.com/mfidino/autoOcc

# Tutorial guide
# https://github.com/ourcodingclub/tutorials-in-progress/blob/master/Tutorial_publishing_guide.md

# Set your local working directory
setwd("E:/GitHub/UWIN_tutorials/tutorials/Auto-logistic occupancy")

raccoon <- read.csv("chicago_raccoon.csv", head = TRUE, skip = 3) # we use skip to deal with first 3 lines of 
head(raccoon)      