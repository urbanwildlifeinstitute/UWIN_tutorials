setwd("./tutorials/autologistic_enhanced")

## Questions 1---------------------------------------------------------------
# edit - cut tutorials, the project already directs you there
setwd("./autologistic_enhanced")

# To conduct the analysis
library(autoOcc)

# To summarise data
if("dplyr" %in% installed.packages()){
  library(dplyr)
} else {
  install.packages("dplyr")
  library(dplyr)
}

# To plot results
library(ggplot2)
if("ggplot2" %in% installed.packages()){
  library(ggplot2)
} else {
  install.packages("ggplot2")
  library(ggplot2)
}

# read in the coyote detection data
coyote <- read.csv(
  "./data/chicago_coyote.csv"
)


# check out the structure of the data
dplyr::glimpse(coyote)

## Rows: 900
## Columns: 18
## $ Species <chr> "coyote", "coyote", "coyote", "coyote", "coyote", "coyote", "c…
## $ Season  <chr> "JA18", "JA18", "JA18", "JA18", "JA18", "JA18", "JA18", "JA18"…
## $ Site    <chr> "C04-MBP1", "C05-BMP1", "C05-BMP2", "C06-HMP1", "D02-BMT1", "D…
## $ Start   <chr> "2017-12-18", "2017-12-18", "2017-12-18", "2017-12-18", "2017-…
## $ End     <chr> "2018-02-14", "2018-02-14", "2018-02-14", "2018-02-14", "2018-…
## $ City    <chr> "chil", "chil", "chil", "chil", "chil", "chil", "chil", "chil"…
## $ Long    <dbl> -87.57339, -87.57511, -87.56486, -87.56992, -87.66978, -87.699…
## $ Lat     <dbl> 41.71308, 41.69479, 41.68575, 41.65681, 41.91434, 41.90586, 41…
## $ Crs     <int> 4326, 4326, 4326, 4326, 4326, 4326, 4326, 4326, 4326, 4326, 43…
## $ Week_1  <int> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
## $ Week_2  <int> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
## $ Week_3  <int> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
## $ Week_4  <int> NA, NA, NA, NA, 0, 1, NA, 0, 0, 0, 0, 0, NA, 0, 0, 0, 0, 1, NA…
## $ Week_5  <int> NA, NA, NA, NA, 0, 0, NA, 0, 1, 0, 0, 0, NA, 0, 0, 0, 0, NA, N…
## $ Week_6  <int> NA, NA, NA, NA, 0, 1, NA, 0, 0, 0, 0, 0, NA, 0, 1, 1, 1, 1, NA…
## $ Week_7  <int> NA, NA, NA, NA, 0, 1, NA, 0, 0, 0, 0, 0, NA, 0, 1, 1, 0, 0, NA…
## $ Week_8  <int> NA, NA, NA, NA, 0, 1, NA, 0, 0, 0, 0, 0, NA, 0, 0, 0, 0, 0, NA…
## $ Week_9  <int> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…

coyote <- autoOcc::format_y(
  x = coyote, # coyote data.frame
  site_column = "Site", # Name of site column in coyote
  time_column = "Season", # Name of season column in coyote 
  history_columns = "Week" # what the detection history columns start with.
) 

nweeks_sampled <- apply(
  X = coyote,
  MARGIN = 1,
  function(x){
    sum(!is.na(x))
  }
)

# Check out a little histogram of this
hist(
  nweeks_sampled,
  main = "Number of weeks sampled per site",
  xlab = "Weeks sampled"
)

covs <- read.csv(
  "./data/coyote_covariates.csv"
)

dplyr::glimpse(covs)

## Rows: 100
## Columns: 5
## $ Site            <chr> "C04-MBP1", "C05-BMP1", "C05-BMP2", "C06-HMP1", "D02-B…
## $ tree            <dbl> 0.289, 0.123, 0.111, 0.130, 0.105, 0.213, 0.175, 0.166…
## $ imperv          <dbl> 0.365, 0.087, 0.149, 0.220, 0.723, 0.483, 0.543, 0.605…
## $ housing_density <dbl> 668.000, 0.295, 1.273, 0.942, 2459.586, 2968.107, 5425…
## $ dist_stream     <dbl> 2.783, 1.707, 2.730, 0.396, 4.219, 4.544, 4.565, 3.891…

# make an urbanization metric with tree cover (tree), impervious
#  cover (imperv), and housing density (housing_density)

urb_pca <- covs %>% 
  dplyr::select(tree, imperv, housing_density) %>% 
  prcomp(., center = TRUE, scale = TRUE)

# The first thing we want to see is how much variance each
#  component explains
summary(urb_pca)

## Importance of components:
##                           PC1    PC2     PC3
## Standard deviation     1.4514 0.8112 0.48508
## Proportion of Variance 0.7022 0.2194 0.07843
## Cumulative Proportion  0.7022 0.9216 1.00000

round(
  urb_pca$rotation,
  2
)

##                   PC1   PC2   PC3
## tree            -0.55 -0.70  0.46
## imperv           0.64  0.01  0.77
## housing_density  0.54 -0.71 -0.44

## Question 2-------------------------------------------------------------------
# Solution
# For `PC1` we see that `imperv` and `housing_density` are both positive, 
# while tree is negative. This means that negative values of the urb\_pca 
# are locations high in tree cover whereas positive values of the urb\_pca 
# are locations high in impervious cover and housing density. So negative 
# is more forested and positive is more urban.

# is urb\_ the right format, explain what we are looking at

occ_covs <- data.frame(
  urb = urb_pca$x[,1], # the PC1 term.
  dist_stream = as.numeric(
    scale(
      covs$dist_stream
    )
  )
)

week_temp <- read.csv(
  "./data/weekly_temp_data.csv"
)
dplyr::glimpse(week_temp)

## Rows: 8,100
## Columns: 4
## $ Site   <chr> "C04-MBP1", "C04-MBP1", "C04-MBP1", "C04-MBP1", "C04-MBP1", "C0…
## $ Season <chr> "JA18", "JA18", "JA18", "JA18", "JA18", "JA18", "JA18", "JA18",…
## $ Week   <chr> "Week_1", "Week_2", "Week_3", "Week_4", "Week_5", "Week_6", "We…
## $ temp   <dbl> 1.9714286, -13.1428571, -14.0285714, -1.1428571, -3.8571429, 3.…

# right now the data are set up so it varies by week, season, and then site. 
nweek <- dplyr::n_distinct(week_temp$Week)
nseason <- dplyr::n_distinct(week_temp$Season)
nsite <- dplyr::n_distinct(week_temp$Site)

temp_matrix <- matrix(
  week_temp$temp,
  ncol = nweek * nseason,
  nrow = nsite,
  byrow = TRUE
)

temp_matrix <- (
  temp_matrix - mean(temp_matrix)
) / sd(temp_matrix)

det_covs <- list(
  temp = temp_matrix,
  urb = occ_covs$urb
)

# the null model
null <- auto_occ(
  ~temp + I(temp^2) + urb + I(urb^2)
  ~1, # detection linear predictor first, then occupancy
  y = coyote,
  occ_covs = occ_covs,
  det_covs = det_covs,
  level = 0.85 # Using 85% CI because it aligns more with the use of AIC
)

my_summary <- summary(null)

# urban intensity model
urb <- auto_occ(
  ~temp + I(temp^2) + urb + I(urb^2)
  ~ urb,
  y = coyote,
  occ_covs = occ_covs,
  det_covs = det_covs,
  level = 0.85
)

# stream model
stream <- auto_occ(
  ~temp + I(temp^2) + urb + I(urb^2)
  ~ dist_stream,
  y = coyote,
  occ_covs = occ_covs,
  det_covs = det_covs,
  level = 0.85
)

# urban + stream
urb_stream <- auto_occ(
  ~temp + I(temp^2) + urb + I(urb^2)
  ~ urb + dist_stream,
  y = coyote,
  occ_covs = occ_covs,
  det_covs = det_covs,
  level = 0.85
)

# urban * stream (interaction model)
urb_stream_inxs <- auto_occ(
  ~temp + I(temp^2) + urb + I(urb^2)
  ~ urb*dist_stream,
  y = coyote,
  occ_covs = occ_covs,
  det_covs = det_covs,
  level = 0.85
)

coyote_models <- list(
  null = null,
  urb = urb,
  stream = stream,
  urb_stream = urb_stream,
  urb_stream_inxs = urb_stream_inxs
)

# digits = 2 to set number of significant digits
coyote_aic <- compare_models(
  model_list = coyote_models,
  digits = 2
)

# check out the results
coyote_aic

best_model <- summary(urb)

# Look up the range 
range(occ_covs$urb)

## [1] -3.417673  4.558160

# great data.frame for new predictions
occ_pred_df <- data.frame(
  urb = seq(-3, 4.5, length.out = 300)
)

# for help, see ?autoOcc::predict.auto_occ_fit
occ_preds <- predict(
  object = urb,
  type = "psi",
  newdata = occ_pred_df,
  level = 0.85,
  seed = 153
)

# add the urbanization covariate onto the predicions.
urb_plot <- data.frame(
  urb = occ_pred_df$urb,
  occ_preds
)

# and plot this out with ggplot
ggplot(urb_plot, aes(x = urb, y = estimate)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "#72AD8F", alpha = 0.5) +
  geom_path(linewidth = 1) + # adds line
  labs(x = "Urban Intensity", y = "Occupancy") +
  scale_x_continuous(limits = c(-3,4.5)) +
  ylim(0,1)+
  theme_classic()+ # drops gray background and grid
  theme(plot.title=element_text(size = 16, hjust=0.5), # centers titles
        axis.text.x = element_text(size = 12, color = "black"),    
        axis.text.y = element_text(size = 12, color = "black"),
        axis.title = element_text(size = 18)) 

# What is the range of temperatures?
range(week_temp$temp)

## [1] -16.42857  27.37143

# seems like somewhere between -15C and 25C is good for making
#  a 'pretty' x-axis
nice_temps <- seq(-15, 25, length.out = 300)
temp_pred_df <- data.frame(
  temp = nice_temps,
  urb = 0 # don't forget to include urb here!
)

# scale the temperature data like we did for our model
temp_pred_df$temp <- (temp_pred_df$temp - mean(week_temp$temp)) / sd(week_temp$temp)


# Generate predictions, this time switching type to 'rho' because it
#  is for detection probability.
det_temp_preds <- predict(
  object = urb,
  type = "rho",
  newdata = temp_pred_df,
  level = 0.85,
  seed = 154
)

# add temps into the data.frame for plotting purposes
det_temp_plot <- data.frame(
  temp = nice_temps,
  det_temp_preds
)

# An expression to get the degrees symbol for the x-axis
xlab_expression <- expression(
  Temperature~(degree*C)
)
# and plot this out with ggplot
ggplot(det_temp_plot, aes(x = temp, y = estimate)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "#72AD8F", alpha = 0.5) +
  geom_path(linewidth = 1) + # adds line
  labs(x = xlab_expression, y = "Detection probability") +
  scale_x_continuous(limits = range(nice_temps)) +
  ylim(0,1)+
  theme_classic()+ # drops gray background and grid
  theme(plot.title=element_text(size = 16, hjust=0.5), # centers titles
        axis.text.x = element_text(size = 12, color = "black"),    
        axis.text.y = element_text(size = 12, color = "black"),
        axis.title = element_text(size = 18)) 


urb_pred_df <- data.frame(
  temp = 0,
  urb = occ_pred_df$urb
)

det_urb_preds <- predict(
  object = urb,
  type = "rho",
  newdata = urb_pred_df,
  level = 0.85,
  seed = 154
)

det_urb_plot <- data.frame(
  urb = urb_pred_df$urb,
  det_urb_preds
)


# and plot this out with ggplot
ggplot(det_urb_plot, aes(x = urb, y = estimate)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "#72AD8F", alpha = 0.5) +
  geom_path(linewidth = 1) + # adds line
  labs(x = "Urban Intensity", y = "Detection probability") +
  scale_x_continuous(limits = range(det_urb_plot$urb)) +
  ylim(0,1)+
  theme_classic()+ # drops gray background and grid
  theme(plot.title=element_text(size = 16, hjust=0.5), # centers titles
        axis.text.x = element_text(size = 12, color = "black"),    
        axis.text.y = element_text(size = 12, color = "black"),
        axis.title = element_text(size = 18)) 
