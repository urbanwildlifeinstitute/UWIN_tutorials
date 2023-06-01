# UWIN Tutorial: Auto-Logistic Occupancy
*Created by Kimberly Rivera - last updated May 2023 by Kimberly Rivera*

This tutorial is aimed at folks interested and new to occuapncy modeling, or as refesher for those already familiar. This tutorial was designed with the support of outside resources listed below and via workshops developed by Mason Fidino.

### Some helpful references:
1. [An introduction to auto-logistic occupancy models](https://masonfidino.com/autologistic_occupancy_model/) - Mason Fidino
2. [Occupancy models for citizen-science data](https://besjournals.onlinelibrary.wiley.com/doi/10.1111/2041-210X.13090) - Res Altwegg & James D. Nichols

### Tutorial Aims:

#### <a href="#occupancy"> 1. What is Auto-logistic occupancy?</a>

#### <a href="#formatting"> 2. Formatting data</a>

#### <a href="#models"> 3. Fitting models</a>

#### <a href="#plots"> 4. Predicting & plotting model outputs</a>


<a name="occupancy"></a>

## 1. What is Auto-logistic occupancy?
Though static occupancy models can be a useful tool when studying species ecology, they are limited to a 'static' system, meaning we cannot account for changes in the environment or species occupancy. By considering a dynamic system, we can account for a lot of things like changing environmental conditions (such as climate or fire), impacts of management interventions, variations in sampling methodologies, or life stages of species. Often, scientists are interested in modeling temporal dynamics or how species ecology or habitat use changes across time (diel, seasonally, or yearly). There are [a variety of ways we can model](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.12100) such a dyanmic system. Some common ways to account for temporal changes include dynamic occupancy models, multi-state occupancy models, or the incorpertion of random site effects. However, all these methods require large amounts of data to estimate all affiliated parameters. An alternative to these methods is using a temporal auto-logistic parameter where occupancy for *t = 2...5* (where t is time) is dependent on the previous *t*'s occupancy. This method only introduces one new parameter, unlike the models listed above. To get into the nitty gritty of the equations, please review [this blog post](https://masonfidino.com/autologistic_occupancy_model/) (also listed in references above). Rather, let's get into an example and see how this approach can be applied. 

<a name="formatting"></a>

## 2. Formatting data for an Auto-logistic model
For this example, we will use data collected by the UWIN Chicago. We will specifically look at changes in Virginia opossum occupancy across four seasons using the package `autoOcc`. Like a static occupancy model, we will need a column for 'sites' and 'visits' (or 'occasions' if data is collapsed). We will also need a new column which describes the temporal sampling period, in this case 'season'. 

| season  | site | occ_1 | occ... | occ_J |
|---------|------|-------|--------|-------|
| Season1 | A    | NA    | 0      | 1     |
| Season1 | B    | NA    | 0      | 0     |
| Season1 | C    | 0     | 1      | 1     |
| Season2 | A    | 1     | 0      | 0     |
| Season2 | B    | NA    | NA     | NA    |
| Season2 | C    | 0     | 0      | 1     |

Let's load in and examine our data...
```R
# Load in libraries
library(dplyr)
library(ggplot2)
library(devtools)

devtools::install_github(
  "mfidino/autoOcc",
  build_vignettes = TRUE
)
library(autoOcc)

# Set your local working directory and load in data
setwd()
load(file='opossum_det_hist.rda') 
load(file='opossum_covariates.rda') 

# examine data
head(opossum_det_hist) 
```
The package `autoOcc` is built similarly to `unmarked` in which we feed our sampling data into a function `format_y()` (similar to `unmarkedFrameOccu` in `unmarked`). Unlike covariate data, site data can be missing within seasons. For example, Season1 may include sites a,b,c but Season2 may only include sites a,c. The function `format_y()` will account for these missing data and fill the array with NA's. To use this function we need: `x`, `site_column`, `time_column`, and `history_columns`. 
