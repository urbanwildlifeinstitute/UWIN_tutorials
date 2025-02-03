# Load the necessary libraries
library(autoOcc)
library(dplyr)
library(ggplot2)

# Step one: Read in and format the detection data

# read in the coyote detection data
coyote <- read.csv(
  "./data/chicago_coyote.csv"
)



# check out the structure of the data
dplyr::glimpse(coyote)



# convert the coyote data into a three dimensional array
#  using the function autoOcc::format_y(). The dimensions
#  of this array are site x primary sampling period x
#  secondary sampling period (within each primary). 

coyote <- autoOcc::format_y(
  x = coyote,
  site_column = "Site",
  time_column = "Season",
  history_columns = "Week"
)


# Check out all the detection data for one site
coyote[15,,]


# and just as a safety measure, ensure that all sites
#  have at least SOME data. Since this is an
#  array the easiest way to do this is with the apply()
#  function. Since we just want to sum across all the
#  data for each site, the dimension (i.e., MARGIN)
#  we want to apply our function to is the first one.
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

# Step two: read in and format the covariates

#  site-level covariates that do not vary through time

covs <- read.csv(
  "./data/coyote_covariates.csv"
)

dplyr::glimpse(covs)



# info on the stuff in this data.frame

# make an urbanization metric with tree cover (tree), impervious
#  cover (imperv), and housing density (housing_density)

urb_pca <- covs %>% 
  dplyr::select(tree, imperv, housing_density) %>% 
  prcomp(., center = TRUE, scale = TRUE)

# The first thing we want to see is how much variance each
#  component explains.
summary(urb_pca)


# The first one explains about 70% of the variation, so we will just
#  use that one. How we do interpret this? We look at the loadings:

round(
  urb_pca$rotation,
  2
)

# For PC1 we see that imperv and housing_density are both positive, while
#  tree is negative. This means that negative values of the urb_pca are
#  locations high in tree cover whereas positive values of the urb_pca
#  are locations high in impervious cover and housing density. So negative
#  is more forested and positive is more urban.

# The second covariate we have is the distance of each site to a stream
#  or river. We included this one as riparian areas are often
#  used a corridors for mammals. However, before we just include it
#  into our covariate data.frame for analysis we need to scale it.

occ_covs <- data.frame(
  urb = urb_pca$x[,1], # the PC1 term.
  dist_stream = as.numeric(
    scale(
      covs$dist_stream
    )
  )
)


# In addition to these covariate data, we also have weekly temperature
#  data to include as a detection covariate. Since Chicago experiences
#  four distinct seasons, coyote may alter their behavior when it's either
#  hot (the summer) or when its cold (the winter). This is also 
#  to show how to include survey-specific covariates on detection, which
#  is something autoOcc can handle.
week_temp <- read.csv(
  "./data/weekly_temp_data.csv"
)

# right now the data are set up so it varies by week, season, and then site. 
nweek <- dplyr::n_distinct(week_temp$Week)
nseason <- dplyr::n_distinct(week_temp$Season)
nsite <- dplyr::n_distinct(week_temp$Site)

# To set up this covariate we are going to need to create a matrix with a 
#  number of rows equal to nsite and a number of columns equal to nweek * nseason
#  the first nweek columns will be for the first season, then the next nweek
#  are for season 2, etc., etc. So each row is going to hold all the temperature
#  data for one site. Because of the way the ordering in week_temp (week,
#  season, then site) we can just input the covariate and fill the matrix
#  in the correct way by setting the byrow argument to TRUE.
temp_matrix <- matrix(
  week_temp$temp,
  ncol = nweek * nseason,
  nrow = nsite,
  byrow = TRUE
)

# Now, all columns of this matrix are associated to the same covariate, and so
#  to scale this covariate we need to divide each column by the global mean
#  and divide by the global standard devation (i.e., use the scale function).
#  since this is a matrix this is a bit easier to just do by hand.
temp_matrix <- (
  temp_matrix - mean(temp_matrix)
) / sd(temp_matrix)

# Now to the rest of the detection covariates. We are also going to include
#  urbanization here as coyote abundance likely covaries with this. As areas
#  with more coyote may increase how detectable they are, it makes sense
#  to try to control for this variation. Because we have this temp matrix,
#  the detection covariates MUST be in a named list.

det_covs <- list(
  temp = temp_matrix,
  urb = occ_covs$urb
)

# step three: fit some models

null <- autoOcc::auto_occ(
  ~1~1, # detection linear predictor first, then occupancy
  y = coyote,
  occ_covs = occ_covs,
  det_covs = det_covs,
  level = 0.85 # Using 85% CI because it aligns more with the use of AIC
)

# check out first model result, just so we get an idea about what the format
#  looks like
summary(null)



# fit the remaining models. For detection, we are going to fit
#  close to the most complex model we can with the given covariates
#  Specifically, we are going to add both linear and quadratic terms
#  urbanization


# try this but with non-linear terms added


urb <- autoOcc::auto_occ(
  ~temp + I(temp^2) + urb + I(urb^2)
  ~ urb,
  y = coyote,
  occ_covs = occ_covs,
  det_covs = det_covs,
  level = 0.85
)

stream <- autoOcc::auto_occ(
  ~temp + I(temp^2) + urb + I(urb^2)
  ~ dist_stream,
  y = coyote,
  occ_covs = occ_covs,
  det_covs = det_covs,
  level = 0.85
)

urb_stream <- autoOcc::auto_occ(
  ~temp + I(temp^2) + urb + I(urb^2)
  ~ urb + dist_stream,
  y = coyote,
  occ_covs = occ_covs,
  det_covs = det_covs,
  level = 0.85
)

urb_stream_inxs <- autoOcc::auto_occ(
  ~temp + I(temp^2) + urb + I(urb^2)
  ~ urb*dist_stream,
  y = coyote,
  occ_covs = occ_covs,
  det_covs = det_covs,
  level = 0.85
)



# step four: compare the models
model_list <- list(
  null = null,
  urb = urb,
  stream = stream,
  urb_stream = urb_stream,
  urb_stream_inxs = urb_stream_inxs
)

model_aic <- autoOcc::compare_models(
  model_list,
  digits = 2
)

# step 5: make some model predictions with the best-fit model

# to do this, we need to generate a new data.frame with all the
#  associated covariates tied to a given level of the model (i.e.,
#  occuapncy or detection). However, we scaled our covariates,
#  and to generate our predictions they need to be scaled
#  EXACTLY as the data we supplied to the model. In our
#  case, this is pretty easy. The urbanization covariate
#  is already kind of abstract, so we just need to generate
#  a sequence of values from around the same extent as the
#  data we supplied.

range(occ_covs$urb)

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

# Now do the same thing with the two detection covariates. This is a bit
#  trickier as you need to do them individually. Also, the temperature
#  covariate should reflect realistic values, so we need to figure
#  out what an appropriate range is for the predictions from the raw data.

range(week_temp$temp)

nice_temps <- seq(-15, 25, length.out = 300)
temp_pred_df <- data.frame(
  temp = nice_temps,
  urb = 0
)

# scale the temperature data like we did for our model
temp_pred_df$temp <- (temp_pred_df$temp - mean(week_temp$temp)) / sd(week_temp$temp)



det_temp_preds <- predict(
  object = urb,
  type = "rho",
  newdata = temp_pred_df,
  level = 0.85,
  seed = 154
)

det_temp_plot <- data.frame(
  temp = nice_temps,
  det_temp_preds
)

# An expression to get the degrees symbol
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




nice_temps <- seq(-15, 25, length.out = 300)
temp_pred_df <- data.frame(
  temp = nice_temps,
  urb = 0
)

# scale the temperature data like we did for our model
temp_pred_df$temp <- (temp_pred_df$temp - mean(week_temp$temp)) / sd(week_temp$temp)


# And then the relationship between urbanization and detection probability



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
