setwd("D:/GitHub/UWIN_tutorials/tutorials/occupancy2")

# Sys.setenv(
#   PATH = paste(
#     Sys.getenv("PATH"),
#     "C:/Program Files/R/R-4.3.2/bin/x64", # CHANGE THIS LINE
#     sep = ":"
#   )
# )

Sys.setenv(PATH = paste("C:/rtools43/bin", Sys.getenv("PATH"), sep=";"))
Sys.setenv(BINPREF = "C:/rtools43/mingw_$(WIN)/bin/")

# Load in libraries
library(dplyr)
library(ggplot2)
library(devtools)

# Install autoOcc incase you have not yet
devtools::install_github(
  "mfidino/autoOcc",
  build_vignettes = TRUE
)

library(autoOcc)

# Create a plots sub-folder as well to store figures
#  from analysis
dir.create("plots")

# Set your local working directory and load in data that is stored
#  in autoOcc package.
data("opossum_det_hist")
data("opossum_covariates") 

# examine data
head(opossum_det_hist) 