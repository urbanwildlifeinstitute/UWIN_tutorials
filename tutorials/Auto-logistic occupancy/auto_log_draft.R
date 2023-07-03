# Load in libraries
library(dplyr)
library(ggplot2)
library(devtools)

# devtools::install_github(
#   "mfidino/autoOcc",
#   build_vignettes = TRUE
# )

library(autoOcc)

# Helpful references
# https://masonfidino.com/autologistic_occupancy_model/
# https://github.com/mfidino/autoOcc

# Tutorial guide
# https://github.com/ourcodingclub/tutorials-in-progress/blob/master/Tutorial_publishing_guide.md

# Set your local working directory
setwd("E:/GitHub/UWIN_tutorials/tutorials/Auto-logistic occupancy")

# load autoOcc example data
data("opossum_det_hist")
data("opossum_covariates")


# examine data
head(opossum_det_hist)
head(opossum_covariates)
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


# We can see that our $\Psi$ - $\theta$ term here is a positive 1.878.
# This indicates that if opossum were present at a site at *t-1* (for example JA19),
# they are much more likely to be present at the same site at time *t* (e.g. AP19).
# We can now use this model to make predictions about the expected occupancy and
# average weekly detection probability.



# now let's fit a model with spatial covariates
# fit a model with occupancy covariates for Impervious cover and Income 
m2 <- auto_occ(
  ~1 # detection
  ~Impervious + Income, # occupancy
  y = opossum_y,
  occ_covs = cov_scaled
)

summary(m2)

# We can also add complexity with a categorical temporal covariate 'Season'
# #  Temporally varying covariates need to be a named list.
# #  For this example, the seasonal information is in the
# #  opossum detection history (opossum_det_hist).

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


# Will provide a warning
m3 <- auto_occ(
   ~1
   ~Season + Impervious + Income,
   y = opossum_y,
   occ_covs = season_frame
 )

 
summary(m3)

# Comparing models--------------------------------------------------------------
aic_results <- compare_models(
  list(m1, m2,m3),
  digits = 2
)

aic_results

# Model averaging
# get parameters in each model, and
#  set up a binary matrix to denote
#  if they were present or not in that
#  model.

model_list <- list(
  null = m1,
  spatial = m2,
  temp = m3
)

# get only the model parameters 
parms <- lapply(
  model_list,
  function(x){
    x@estimates$parameter
  }
)

# select only unique parameters
all_parms <- unique(
  unlist(
    parms
  )
)

# make an empty matrix
parm_matrix <- matrix(
  0,
  ncol = length(
    all_parms
  ),
  nrow = length(
    model_list
  )
)
colnames(parm_matrix) <- all_parms

# Add '1's to models which have parameter present
for(i in 1:nrow(parm_matrix)){
  parm_matrix[i, parms[[i]]] <- 1
}

# calculate overall weight for each parameter. The easiest
#  way to do this is to make a weight matrix.
weight_matrix <- matrix(
  aic_results$AICwt,
  nrow = length(model_list),
  ncol = length(all_parms)
)

parm_weight <- colSums(
  parm_matrix * weight_matrix
)

#  We are going to take samples from the parameters (which
#  is the same thing we do to make predictions
#  via autoOcc::predict). To do that, we need
#  to get the variance covariance matrix
#  for each model.


# QUESTIONS ON THIS FOR MASON
cov_mat <- lapply(
  model_list,
  vcov
)

# and now the estimates (assuming you are not
#  using any offsets in the model for this).

ests <- lapply(
  model_list,
  function(x) x@estimates$Est
)

# do 5000 samples for each parameter.
mvn_samps <- vector(
  "list",
  length = length(model_list)
)
nsim = 5000
set.seed(465)
for(i in 1:length(mvn_samps)){
  mvn_samps[[i]] <- mvtnorm::rmvnorm(
    nsim,
    mean = ests[[i]],
    sigma = cov_mat[[i]],
    method = "svd"
  )
  colnames(mvn_samps[[i]]) <- parms[[i]]
}

# do model averaging for each parameter
avg_parm <- data.frame(
  parameter = all_parms,
  est = NA,
  lower = NA,
  upper = NA
)

for(i in 1:nrow(avg_parm)){
  my_parm <- avg_parm$parameter[i]
  which_models <- which(
    parm_matrix[,i] == 1
  )
  
  weights <- weight_matrix[
    which_models,i
  ] * parm_matrix[
    which_models,i
  ]

  # get beta terms

  beta_mat <- matrix(
    NA,
    ncol = length(which_models),
    nrow = nsim
  )
  # multiply weight across columns while we do this
  for(j in 1:ncol(beta_mat)){
    beta_mat[,j] <- mvn_samps[[which_models[j]]][,my_parm] *
      weights[j]
  }
  # sum each row
  beta_mat <- rowSums(beta_mat)
  
  # divide by overall weight
  beta_mat <- beta_mat / parm_weight[i]
  
  # summarise
  avg_parm$est[i] <- median(beta_mat)
  avg_parm$lower[i] <- quantile(
    beta_mat,
    0.025
  )
  avg_parm$upper[i] <- quantile(
    beta_mat,
    0.975
  )
  
}

avg_parm

# Predicting and Plotting-------------------------------------------------------
## null model
# get expected occupancy for m1, which is around 0.59.
(intercept_preds_psi <- predict(
  m1,
  type = "psi"))

# get average weekly detection probability for m1, which is about 0.53.
(intercept_preds_rho <- predict(
  m1, 
  type = "rho"))


## spatial model (impervious cover & income)
# To make predictions for this model we will generate realistic data for impervious cover and income

summary(opossum_covariates$Impervious)
summary(opossum_covariates$Income)

# Make a data.frame based on actual data
imperv <- data.frame(
  Impervious = seq(20, 80, 0.5),
  Income = 0 # we use '0' because the data is scaled, thus the mean is zero.
)

income <- data.frame(
  Impervious = 0,
  Income = seq(28000, 80000, 100)
)

# scale data
imperv_scale <- imperv %>% 
  mutate(Impervious = scale(Impervious))

income_scale <- income %>% 
  mutate(Income = scale(Income))

# now we can model our predictions across gradients of Impervious cover and Income
opo_imperv <- predict(
  object = m2,
  type = "psi",
  newdata = imperv_scale
)

opo_income <- predict(
  object = m2,
  type = "psi",
  newdata = income_scale
)

# Now we are ready to plot!
png("plots/opo_imperv_basic.png", height = 700, width = 700)
plot(
  opo_imperv$estimate ~ imperv$Impervious,
  bty = "l",
  type = "l",
  las = 1,
  ylab = "Occupancy",
  xlab= "Impervious Cover (%)",
  ylim = c(0,1),
  lwd = 3
)
lines(opo_imperv$lower ~ imperv$Impervious, lwd = 2, lty = 2)
lines(opo_imperv$upper ~ imperv$Impervious, lwd = 2, lty = 2)
dev.off()

# We can also use ggplot to pretty up the plot
# first merge the two datasets (predicted occupancy and impervious cover)
imperv_plot <- bind_cols(opo_imperv, imperv) %>% 
  select(-c(Income))
  

ggplot(imperv_plot, aes(x = Impervious, y = estimate)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "orange", alpha = 0.5) +
  geom_path(size = 1) + # adds line
  labs(x = "Impervious cover", y = "Occupancy probability") +
  ggtitle("Opossum Occupancy")+
  scale_x_continuous(limits = c(20,80)) +
  ylim(0,1)+
  theme_classic()+ # drops gray background and grid
  theme(plot.title=element_text(hjust=0.5)) # centers titles

# we can get more creative with our colors using the package `colourpicker`
library(colourpicker)

# go to your 'Addins' tab and select `colourpicker`. 
ggsave("plots/opo_imperv_ggplot.jpg", width = 6, height = 6)
ggplot(imperv_plot, aes(x = Impervious, y = estimate)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "#72AD8F", alpha = 0.5) +
  geom_path(size = 1) + # adds line
  labs(x = "Impervious cover", y = "Occupancy probability") +
  ggtitle("Opossum Occupancy with Impervious Cover")+
  scale_x_continuous(limits = c(20,80)) +
  ylim(0,1)+
  theme_classic()+ # drops gray background and grid
  theme(plot.title=element_text(size = 16, hjust=0.5), # centers titles
        axis.text.x = element_text(size = 12),    
        axis.text.y = element_text(size = 12),
        axis.title = element_text(size = 18)) 

# Let's do this whole process again with Income---------------------------------

income_plot <- bind_cols(opo_income, income) %>% 
  select(-c(Impervious))

ggsave("plots/opo_income_ggplot.jpg", width = 6, height = 6)
ggplot(income_plot, aes(x = Income, y = estimate)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = c("#D4B282"), alpha = 0.5) +
  geom_path(size = 1) + # adds line
  labs(x = "Per Captia Income (US Dollar)", y = "Occupancy probability") +
  ggtitle("Opossum Occupancy with Income")+
  scale_x_continuous(limits = c(28000,80000)) +
  ylim(0,1)+
  theme_classic()+ # drops gray background and grid
  theme(plot.title=element_text(size = 16, hjust=0.5), # centers titles
        axis.text.x = element_text(size = 12),    
        axis.text.y = element_text(size = 12),
        axis.title = element_text(size = 18)) 

