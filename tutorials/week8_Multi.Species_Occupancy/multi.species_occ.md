# UWIN Tutorial: Multi-species Occupancy
*Created by Austin Green - last updated June 2024 by Austin Green*

This tutorial is aimed at folks interested in advancing their skills in occupancy modeling, or as refresher for those already familiar with multi-species occupancy. 

### Some helpful references:
1. [Occupancy models for citizen-science data](https://besjournals.onlinelibrary.wiley.com/doi/10.1111/2041-210X.13090) - Res Altwegg & James D. Nichols
2. [Multi-species occupancy models](https://cran.r-project.org/web/packages/camtrapR/vignettes/camtrapr5.html)
- Juergen Nieballa

### Tutorial Aims:

#### <a href="#occupancy"> 1. What are multi-species occupancy models?</a>

#### <a href="#formatting"> 2. Formatting data</a>

#### <a href="#models"> 3. Fitting models</a>

#### <a href="#plots"> 4. Plotting model outputs</a>


<a name="occupancy"></a>

## 1. What are multi-species occupancy models?

Single-species occupancy models are an effective tool for monitoring a single species' distribution. Furthermore, multiple advances in model development have extended the use of these models to dynamical systems, multiple seasons, and other useful extensions. However, when the ecological question at hand requires monitoring several species at once, or a community of species within a particular system, then a multi-species occupancy model can be used. Unlike single species models, multi-species models are a hierarchical extension of their single-species counterparts, which offers some unique advantages. For example, with a multi-species model, species that share similar ecological traits, evolutionary histories, or other life history characteristics can be modeled both as a whole as well as separately. The inclusion of hyperparameters allows for species with less data to 'borrow' precision from similar, more common species. Furthermore, when building these models using a Bayesian hierarchical framework, derived quantities such as estimated species richness can be calculated, and, while incorporating the error in site-specific estimates, be used in subsequent analyses.

<a name="formatting"></a>

## 2. Formatting data

### Creating Detection Histories

For this example, we will use data from five species collected from UWIN Salt Lake City during one season of the Snapshot USA project. These data can be found in the tutorial data folder. Specifically, we will look at how urban development and forest cover affect the occupancy of mule deer, moose, elk, coyote, and puma. Let's start with the raw detection data, which looks like this:

| Site  | Species | Date.Time           |
|-------|---------|---------------------|
| Site1 | Deer    | 2021-08-16 12:10:48 |
| Site1 | Deer    | 2021-08-16 07:48:58 |
| Site1 | Deer    | 2021-08-16 12:15:23 |

Let's load in our raw data

```R
# Load in the full detection dataset
detect <- read.csv(file.choose(), header = T) # Nifty if you don't like setting your working directory, but can also be a pain if you want to run code quickly

# examine data
head(detect)
```

These data are not in the typical format for an occupancy analysis. Using the 'camtrapR' package, along with both a 'detections' dataset and a 'site metadata' dataset, we can easily coerce our raw detections into detection histories using the bit of code below. I show how to do this with mule deer, and you can easily replace the species if you want to try the rest on your own. For simplicity, the detection histories are also provided for each species, so you can skip ahead if you'd like!

```R
# Load in the 'camtrapR' package
library(camtrapR)

# Load in site metadata dataset
camtraps <- read.csv(file.choose(), header = T) ; camtraps

# Create a survey matrix with each day the survey was active and whether or note each site was active during that particular day
camop <- cameraOperation(CTtable      = camtraps, # camera trap metadata
                         stationCol   = "Site", # site name column
                         setupCol     = "Begin", # site setup date
                         retrievalCol = "End", # site takedown date
                         hasProblems  = FALSE, # TRUE if camera malfunctioned
                         dateFormat   = "mdy" # date format for the cameras
)
```

Now, using your detections dataset, create a detection history for each species of interest. The code below is for mule deer, but you can repeat this for each species. Again, you may also skip ahead to further down if you'd rather just use the detections histories in the data folder of this tutorial.

```R
library(beepr) # Not necessary, but fun. It makes a noise when things are done

# Create detection history
deer.detect <- detectionHistory(recordTable      = detect, # detections dataset
                         camOp                = camop, # survey matrix from above
                         output               = "binary", # 0's & 1's as output
                         stationCol           = "Site", # site column
                         speciesCol           = "Species", # species column
                         recordDateTimeCol    = "Date.Time", # date and time column. There is a chance that you will get an error because of this argument. Your csv may revert your date and time to a format that this command does not agree with. However, you can fix this by opening your dataset in excel and formatting the Date.Time column so that it is in yyyy-mm-dd hh:mm:ss format.
                         species              = "Deer", # species of interest
                         occasionLength       = 7, # repeat sampling occasion duration
                         day1                 = "station", # when is the first day of sampling? 'station' means that the first day of sampling at a site is the begin date of that site.
                         datesAsOccasionNames = FALSE, # Not needed
                         includeEffort        = FALSE, # Can be TRUE if you would like to calculate survey days
                         scaleEffort          = FALSE, # Not needed
                         timeZone             = "US/Mountain" # Can be changed to local time zone
) ; beep(sound = 2) # Makes a MARIO sound when done!

# View the detection history
deer.detect$detection_history
```

You can export the detection history as a csv file and save it for future use.

### Formatting detection histories for multi-species occupancy model
Let's load in each species detection history, which can be found in the data folder. They're each labeled by species. There is probably a better way to do this all at once, but hey, I think it helps to see bad coding. It makes you feel better about your own coding . . . I hope!

```R
# Load in detection histories for each species and prepare them to be combined into our multi-species array
deer <- read.csv(file.choose(), header = T)
moose <- read.csv(file.choose(), header = T)
elk <- read.csv(file.choose(), header = T)
coyote <- read.csv(file.choose(), header = T)
puma <- read.csv(file.choose(), header = T)

# JAGS doesn't like detection histories as dataframes, nor does it like when columns have character values in the cells. Let's fix that!
deer <- as.matrix(deer[,2:8])
moose <- as.matrix(moose[,2:8])
elk <- as.matrix(elk[,2:8])
coyote <- as.matrix(coyote[,2:8])
puma <- as.matrix(puma[,2:8])
```

Now that we have all of our detection histories in order, let's combine them into a single array, which is basically a bunch of matrices sandwiched together.

```R
# specify the number of sites, species, and replicate surveys
nsite <- 21 # number of sites
nrep <- 7 # number of replicate surveys per site
nspec <- 5 # number of species

# Create multi-species detection history
y.det <- array(0, dim = c(nsite, nrep, nspec))

# Fill the array with species values. Remember the species order! You'll need it later.
y.det[,,1] <- deer
y.det[,,2] <- moose
y.det[,,3] <- elk
y.det[,,4] <- coyote
y.det[,,5] = puma

# Check out the structure of your array
str(y.det)

# Examine the array
head(y.det)
```

Looks good! We now have our data in a format that JAGS will like. Let's take a look at our covariate data. For this analysis, we will assess whether urban development and forest cover effect the occupancy of our wildlife community. But first, let's scale and take a look at these data.

```R
# let's change the name of our covariate dataset. We used it to create detection histories, and now we want to use it in our occupancy model.
covariates <- camtraps # easier to keep track of moving forward

# let's take a look at both urban development and forest cover
hist(covariates$Urban.Development)
hist(covariates$Forest.Cover)
```

<p float="left">
  <img src="./plots/hist_urban.png" alt="A plot of urban development site covariate." width="500" height="auto" />
  <img src="./plots/hist_forest.png" alt="A plot of forest cover site covariate." width="500" height="auto" />
</p>

Each predictor is zero-inflated, which can pose some issues. However, for the sake of this tutorial, let's include them and scale them. We'll make them their own objects.

```R
# Scale the covariates and make them an object
Urban <- (covariates$Urban.Development - mean(covariates$Urban.Development)) / sd(covariates$Urban.Development)
Forest <- (covariates$Forest.Cover - mean(covariates$Forest.Cover)) / sd(covariates$Forest.Cover)

# Let's put it all together! JAGS likes the data in a big list.
str(jags.data <- list(y = y.det, nsite = nsite, nrep = nrep, nspec = nspec, urban = Urban, forest = Forest))
```

<a name="models"></a>

## 3. Fitting models

Alright, we are ready to fit a multi-species occupancy model in JAGS! This is the tricky (and FUN!) part of the process. The great thing about JAGS, and any Bayesian analysis, is that you get full customization of your model. You get to learn the ins and outs of your model and what makes it work. It can be a little daunting at first, but once you've done it a number of times, things start to fall in place. You can also use this tutorial and model coded within as a scaffolding for your own, more complex models!

Just like all models, the below explanations are incorrect due to brevity, but they can still be informative!

NOTE: Skip ahead to 'Crafting Our Model' to get right into it!

### PRIORS
So, let's build our model. The first thing we will do is assign priors to each of our parameters of interest. A prior is simply a probability distribution that we assign to a parameter before we update that distribution with data. Usually, these priors are 'uninformative' (which isn't actually a thing), meaning that they do not supply a strong bias or they have probability density spread throughout the parameter space. Bascially, they're flat or nearly flat distributions that allow the data to 'speak for itself'. However, sometimes, it can be beneficial to supply a more informative prior, like when you know something about your population of interest before modelling. In this case, we're going to go super 'uninformative' and use diffuse normal or wide uniform priors for all of our parameters. This isn't super recommended, but will do for now. TIP: I've found that the best way to make sure that your prior is actually uninformative is to try a number of different ones (uniform, beta, gaussian, etc.) and see how they affect your parameter estimates. If the changes are nominal, then the priors are relatively uninformative.

After our priors, we will then create our Hyperpriors!

### HYPERPRIORS
Hyperpriors, and the parameters they estimate, besides being a pretty sweet name, are one of the biggest benefits of a multi-species model. There's a lot going on here, but basically, a hyperprior is used to help estimate a single parameter that, in this case, will specify the 'community effects' of urban development and forest cover on all five species. From there, the species specific effects will be drawn from said hyperparameter. So, for ease of interpretation, let's say that our hyperparameter was centered around 2 with a standard deviation of 0.5. Each species-specific effect would be considered a draw from this distribution, based on their data, but slightly skewed towards to center of the hyperparameter, meaning skewed towards a net positive effect, in this case. This is the idea of both Bayesian 'shrinkage' and Bayesian 'borrowing strength'. Each species-specific parameter 'borrows' precision from the community hyperparameter. However, they also 'shrink' towards to community mean. It's a tradeoff, but it can be invaluable when trying to include a number of rare species in your model.

After the priors and hyperpriors are set, we'll then build the process model, which is basically the nested logistic regressions of an occupancy model. It works much like a Maximum Likelihood estimator in a frequentist modeling approach.

### Our Model

Our model is going to include:

1. Priors for species-specific occupancy at an 'average' site (the intercept in our occurence model) that will be drawn from a community hyperparameter
2. Priors for species-specific effects of both urban development and forest cover, each of which will be drawn from a community hyperparameter
3. Priors for species-specific detection probability at an 'average' site (the intercept in our detection model) that will be drawn from a community hyperparameter
4. Hyperpriors for the effects of both urban development and forest cover
5. Linear predictors of both urban development and forest cover on species occupancy
6. Derived site-specific estimates of species richness

Our model does NOT include:

1. Any detection effects. Our model will only estimate species-specific detection probabilities. It wil NOT model the effects of any covariates. However, these could easily be added
2. Model checking assessment. We already have a lot going on in this model, so I exclude calculating a Bayesian p-value from here. However, this should ALWAYS be done before reporting the results of a model. If you want help with calculating this, let me know: austin.m.green@utah.edu
3. Any guild, trait, or taxonomy-related effects. Our hyperparameters are only looking at the community effect. However, we could have made two specific parameters looking at the difference between herbivores and carnivores, for example
4. Any analysis or subsequent use of our derived species richness estimates. I'm simply showing that this can be calculated with precision quite easily. However, we will not do any second-stage analyses with these values

Without further ado, here we go!

### Crafting Our Model

```R
sink("Multi_Species_Occupany_Model")
cat("
    model {
    
    # PRIORS #
    # Priors for species specific effects on occupancy #
    for (k in 1:nspec) { # for each of k species
    # Occupancy parameters
      psi[k] ~ dnorm(mu.psi,tau.psi) # prior for logit-transformed specific specific occupancy
      beta.urban[k] ~ dnorm(mu.beta.urban, tau.beta.urban) # species-specific effects will be drawn from a community hyperparameter with a normal distribution
      beta.forest[k] ~ dnorm(mu.beta.forest, tau.beta.forest) # same as above
    # Detection probability parameters
      det[k] ~ dnorm(mu.det, tau.det) # same as above
    } # end species loop for priors
    
    # Hyperpriors #
    mu.psi ~ dunif(-5,5)
    tau.psi = pow(sd.psi, -2)
    sd.psi ~ dunif(0,10)
    mu.det ~ dunif(-5,5)
    tau.det = pow(sd.det, -2)
    sd.det ~ dunif(0,10)
    mu.beta.urban ~ dunif(-5,5) # Community parameter on the effect of urban development
    tau.beta.urban = pow(sd.beta.urban, -2) # Transformation
    sd.beta.urban ~ dunif(0,10) # # Measure of how much variation there is in species-specific parameters
    mu.beta.forest ~ dunif(-5,5)
    tau.beta.forest = pow(sd.beta.forest, -2)
    sd.beta.forest ~ dunif(0,10)
    
    # Ecological model (LIKELIHOOD)
    for (k in 1:nspec) { # Loop through species
      for (i in 1:nsite) { # Loop through sites
        logit(occ[i,k]) = psi[k] # species-specific 'average' occupancy
        + beta.urban[k] * urban[i] # species-specific effect on site-specific urban development
        + beta.forest[k] * forest[i] # species-specific effect on site-specific forest cover
        z[i,k] ~ dbern(occ[i,k]) # distribution for true occupancy at a site

    # Observation model from replicated detection/non-detection data
        for (j in 1:nrep) { # Loop through replicate surveys
          logit(p[i,j,k]) = det[k] # species-specific detection probability
          y[i,j,k] ~ dbern(p[i,j,k] * z[i,k]) # hierarchical piece that ties detection and true occurence
      
        } # Close species loop
      } # Close sites loop
    } # Close replicate surveys loop
    
    # Derived quantities (species richness at a site)
    for (i in 1:nsite) {
      sp.rich[i] = sum(z[i,]) # Number of occuring species at each site
    } # Close sites loop
    for (k in 1:nspec){
      occupancy.probability[k] = exp(psi[k])/(1 + exp(psi[k]))
      detection.probability[k] = exp(det[k])/(1 + exp(det[k]))
    } # Close species loop
    
  } # Close model
      ", fill = TRUE)
sink()
```

There you have it! Our occupancy model coded in JAGS. However, before we can run this, we have to specify a few things, as well as provide some optional additional information. Let's start with the necessary stuff first: Parameters to monitor and Markov Chain Monte Carlo (MCMC) settings. We have to tell JAGS what parameters we want back, as well as how long to run the model for.

```R
# Parameters to monitor
params <- c("psi", # species-level occupancy
           "det", # species-level detection probability
           "mu.det", # community detection
           "mu.psi", # community occupancy
           "mu.beta.urban", # urban community effect
           "mu.beta.forest", # forest community effect
           "beta.urban", # species-specific urban effects
           "beta.forest", # species-specific forest effects
           "sd.beta.urban", # urban community effect variability
           "sd.beta.forest", # forest community effect variability
           "occupancy.probability", # back-transformed occupancy prob
           "detection.probability", # back-transformed detection prob
           "sp.rich") # site-specific species richness
           
# MCMC settings
ni <- 15000 # the number of iterations of each chain
nt <- 1 # the thinning rate of each chain
nb <- 7000 # the burn-in rate for each chain
nc <- 3 # the number of chains
na <- 7000 # the adaptation phase for each chain
```

We can also specify initial values for the parameters being monitored. This can help the MCMC chains converge on a specific parameter space. It's not necessary, but it usually helps with convergence, especially for the latent state variables like occupancy. Let's go ahead an specify initial values for occupancy based on the max value from the observed data. That will give our chains a good place to start!

```R
# Initial values for occupancy
z.inits <- matrix(NA, nsite, nspec)
for (k in 1:nspec) {
  z.inits[,k] = apply(y.det[,,k], 1, max, na.rm = T) 
}
z.inits[z.inits == - Inf] <- 0
inits = function() list(z = z.inits) # assign initial values. In this case, there is only one parameter we are providing them for.
inits()
```

Okay, we are ready to run the model!

```R
# Load package
library(jagsUI)

# Call JAGS and run the multi-species occupancy model
out <- jagsUI(jags.data, # supply the data
              inits, # initial values
              params, # parameters to monitor
              "Multi_Species_Occupany_Model", # model file
              n.chains = nc, # number of chains
              n.thin = nt, # thinning rate
              n.iter = ni, # number of iterations
              n.burnin = nb, # burn-in phase
              n.adapt = na) # adaptation phase ;  beep(sound = 2)
              
# View the output
print(out, digit = 2)

# Save the model! This is especially important when you have one that runs for a long time!
saveRDS(out, "multi_species_occupancy_results")
out <- readRDS("multi_species_occupancy_results")
```

We can see that our model ran long enough to achieve successful convergence (all Rhat values < 1.1). Estimates will vary slightly from run to run, but we can also see that detection probabilities were relatively high for each species (> 0.20), but occupancy probabilities were poorly estimated for 4-5 species (Bayesian Confidence Intervals ~ 0.05 - 0.99). We ran a model with two covariates and only 21 sites, so there was not much to work with. 

We also see that forest cover was a positive predictor for each species, with species-specific effects approaching the commonly adopted 95% posterior probability of effect threshold (the 'f' column). We can see that the community effect was also positive. The opposite effect was found for urban development for all species except mule deer. The community effect was also negative.

With the model output saved, we can use the posteriors to make some plots.

<a name="plots"></a>

## 4. Plotting model outputs
The 'out' object is filled with useful things to help us visualize these results, including every draw from the joint posteriors for each parameter. Let's use these values to craft some predictions


### Community Effects

```R
# Craft a range for the covariates. Normally, you'd want to probably backtransform all of these from their scaled values, but let's just use the scaled one for now.
urban.range <- range(Urban)
forest.range <- range(Forest)

# Sequence covariate data for plotting
urban.seq <- seq(min(urban.range), max(urban.range), length.out = 1000)
forest.seq <- seq(min(forest.range), max(forest.range), length.out = 1000)

# Create a matrix to house predictions from the model
pred.dat <- matrix(NA, nrow = 1000, ncol = 3) # match the rows with the number of values in your sequences from above

# Predictions. We'll start with urban development, holding forest cover at its mean (which is 0)
for(i in 1:1000) {
  community.occupancy <- out$sims.list$mu.psi + out$sims.list$mu.beta.urban * urban.seq[i]
  community.occupancy <- exp(community.occupancy)/(1 + exp(community.occupancy))
  pred.dat[i,1] <- mean(community.occupancy) # mean prediction
  pred.dat[i,2] <- quantile(community.occupancy, 0.025) # lower BCI
  pred.dat[i,3] <- quantile(community.occupancy, 0.975) # upper BCI
} ; pred.dat = as.data.frame(pred.dat) ; names(pred.dat) = c("mean", "lower", "upper") ; str(pred.dat)

# Plot
par(bty = "l")
par(mfrow = c(1,1)) ###
par(mar = c(5,7,5,1) + 0.1) ## default is c(5,4,4,2) + 0.1

library(viridis)
pal = viridis(10, option = "mako")

plot(seq(0,1,,21) ~ Urban, col = "white", xlab="", ylab="", main="Community Urban Development Effect
", xaxt = "n", yaxt = "n", cex = .5, ylim = c(0,1), cex.main = 2.5)
title(ylab = "Occupancy probability", line = 4, cex.lab = 2)
title(xlab = "Urban development (scaled)", cex.lab = 2, line = 3)
axis(2, las = 2, cex.axis = 2)
axis(1, cex.axis = 2, tick = T, at = c(round(min(urban.range),1), round(max(urban.range),1)), line = 0)

polygon(c(rev(urban.seq), urban.seq), c(rev(pred.dat[,2]), pred.dat[,3]), col = adjustcolor(pal[8], alpha.f = 0.1), border = NA)
lines(urban.seq, pred.dat[,1], col = pal[8], lwd = 5)
```

We see that the BCI (Bayesian Credible Intervals) span practically the entire parameter space, which is probably due to running a multi-species model with two covariates on only 21 sites.

<p float="center">
  <img src="./plots/community_urban.png" alt="Community occupancy plot across impervious cover using plot()" width="800" height="auto" />
</p>

Let's try forest cover now

```R
# Create a matrix to house predictions from the model
pred.dat <- matrix(NA, nrow = 1000, ncol = 3) # match the rows with the number of values in your sequences from above

# Predictions.
for(i in 1:1000) {
  community.occupancy <- out$sims.list$mu.psi + out$sims.list$mu.beta.forest * forest.seq[i]
  community.occupancy <- exp(community.occupancy)/(1 + exp(community.occupancy))
  pred.dat[i,1] <- mean(community.occupancy) # mean prediction
  pred.dat[i,2] <- quantile(community.occupancy, 0.025) # lower BCI
  pred.dat[i,3] <- quantile(community.occupancy, 0.975) # upper BCI
} ; pred.dat = as.data.frame(pred.dat) ; names(pred.dat) = c("mean", "lower", "upper") ; str(pred.dat)

# Plot
par(bty = "l")
par(mfrow = c(1,1)) ###
par(mar = c(5,7,5,1) + 0.1) ## default is c(5,4,4,2) + 0.1

library(viridis)
pal = viridis(10, option = "mako")

plot(seq(0,1,,21) ~ Forest, col = "white", xlab="", ylab="", main="Community Forest Cover Effect
", xaxt = "n", yaxt = "n", cex = .5, ylim = c(0,1), cex.main = 2.5)
title(ylab = "Occupancy probability", line = 4, cex.lab = 2)
title(xlab = "Forest cover (scaled)", cex.lab = 2, line = 3)
axis(2, las = 2, cex.axis = 2)
axis(1, cex.axis = 2, tick = T, at = c(round(min(forest.range),1), round(max(forest.range),1)), line = 0)

polygon(c(rev(forest.seq), forest.seq), c(rev(pred.dat[,2]), pred.dat[,3]), col = adjustcolor(pal[4], alpha.f = 0.1), border = NA)
lines(forest.seq, pred.dat[,1], col = pal[4], lwd = 5)
```

Similar issues with precision, but the effect direction changes.

<p float="center">
  <img src="./plots/community_forest.png" alt="Community occupancy plot across impervious cover using plot()" width="800" height="auto" />
</p>

And finally, let's check out some single species plots. This is a crazy way to do it, but it helps with clarity.

```R
# Create a matrix to house predictions from the model
pred.dat <- matrix(NA, nrow = 1000, ncol = 3) # match the rows with the number of values in your sequences from above

#############
# MULE DEER
#############

# Predictions.
for(i in 1:1000) {
  community.occupancy <- out$sims.list$psi[,1] + out$sims.list$beta.forest[,1] * forest.seq[i]
  community.occupancy <- exp(community.occupancy)/(1 + exp(community.occupancy))
  pred.dat[i,1] <- mean(community.occupancy) # mean prediction
  pred.dat[i,2] <- quantile(community.occupancy, 0.025) # lower BCI
  pred.dat[i,3] <- quantile(community.occupancy, 0.975) # upper BCI
} ; pred.dat = as.data.frame(pred.dat) ; names(pred.dat) = c("mean", "lower", "upper") ; str(pred.dat)

# Plot
par(bty = "l")
par(mfrow = c(1,1)) ###
par(mar = c(5,7,5,1) + 0.1) ## default is c(5,4,4,2) + 0.1

library(viridis)
pal = viridis(10, option = "A")

plot(seq(0,1,,21) ~ Forest, col = "white", xlab="", ylab="", main="Forest Cover Effect", xaxt = "n", yaxt = "n", cex = .5, ylim = c(0,1), cex.main = 2.5)
title(ylab = "Occupancy probability", line = 4, cex.lab = 2)
title(xlab = "Forest cover (scaled)", cex.lab = 2, line = 3)
axis(2, las = 2, cex.axis = 2)
axis(1, cex.axis = 2, tick = T, at = c(round(min(forest.range),1), round(max(forest.range),1)), line = 0)

lines(forest.seq, pred.dat[,1], col = pal[1], lwd = 5) # Mule Deer Average Response

########
# MOOSE
########

for(i in 1:1000) {
  community.occupancy <- out$sims.list$psi[,2] + out$sims.list$beta.forest[,2] * forest.seq[i]
  community.occupancy <- exp(community.occupancy)/(1 + exp(community.occupancy))
  pred.dat[i,1] <- mean(community.occupancy) # mean prediction
  pred.dat[i,2] <- quantile(community.occupancy, 0.025) # lower BCI
  pred.dat[i,3] <- quantile(community.occupancy, 0.975) # upper BCI
} ; pred.dat = as.data.frame(pred.dat) ; names(pred.dat) = c("mean", "lower", "upper") ; str(pred.dat)

lines(forest.seq, pred.dat[,1], col = pal[3], lwd = 5) # Moose average response

######
# ELK
######

for(i in 1:1000) {
  community.occupancy <- out$sims.list$psi[,3] + out$sims.list$beta.forest[,3] * forest.seq[i]
  community.occupancy <- exp(community.occupancy)/(1 + exp(community.occupancy))
  pred.dat[i,1] <- mean(community.occupancy) # mean prediction
  pred.dat[i,2] <- quantile(community.occupancy, 0.025) # lower BCI
  pred.dat[i,3] <- quantile(community.occupancy, 0.975) # upper BCI
} ; pred.dat = as.data.frame(pred.dat) ; names(pred.dat) = c("mean", "lower", "upper") ; str(pred.dat)

lines(forest.seq, pred.dat[,1], col = pal[5], lwd = 5) # Elk average response

#########
# COYOTE
#########

for(i in 1:1000) {
  community.occupancy <- out$sims.list$psi[,4] + out$sims.list$beta.forest[,4] * forest.seq[i]
  community.occupancy <- exp(community.occupancy)/(1 + exp(community.occupancy))
  pred.dat[i,1] <- mean(community.occupancy) # mean prediction
  pred.dat[i,2] <- quantile(community.occupancy, 0.025) # lower BCI
  pred.dat[i,3] <- quantile(community.occupancy, 0.975) # upper BCI
} ; pred.dat = as.data.frame(pred.dat) ; names(pred.dat) = c("mean", "lower", "upper") ; str(pred.dat)

lines(forest.seq, pred.dat[,1], col = pal[7], lwd = 5) # Coyote average response

#######
# PUMA
#######

for(i in 1:1000) {
  community.occupancy <- out$sims.list$psi[,5] + out$sims.list$beta.forest[,5] * forest.seq[i]
  community.occupancy <- exp(community.occupancy)/(1 + exp(community.occupancy))
  pred.dat[i,1] <- mean(community.occupancy) # mean prediction
  pred.dat[i,2] <- quantile(community.occupancy, 0.025) # lower BCI
  pred.dat[i,3] <- quantile(community.occupancy, 0.975) # upper BCI
} ; pred.dat = as.data.frame(pred.dat) ; names(pred.dat) = c("mean", "lower", "upper") ; str(pred.dat)

lines(forest.seq, pred.dat[,1], col = pal[9], lwd = 5) # Puma average response

legend('bottomright', bty = "n", cex = 2, col = c(pal[1], pal[3], pal[5], pal[7], pal[9]), lty = 1, lwd = 5, legend = c("Deer", "Moose", "Elk", "Coyote", "Puma"))
```

<p float="center">
  <img src="./plots/species_forest.png" alt="Community occupancy plot across impervious cover using plot()" width="800" height="auto" />
</p>

```R
# Create a matrix to house predictions from the model
pred.dat <- matrix(NA, nrow = 1000, ncol = 3) # match the rows with the number of values in your sequences from above

############
# MULE DEER
############

# Predictions.
for(i in 1:1000) {
  community.occupancy <- out$sims.list$psi[,1] + out$sims.list$beta.urban[,1] * urban.seq[i]
  community.occupancy <- exp(community.occupancy)/(1 + exp(community.occupancy))
  pred.dat[i,1] <- mean(community.occupancy) # mean prediction
  pred.dat[i,2] <- quantile(community.occupancy, 0.025) # lower BCI
  pred.dat[i,3] <- quantile(community.occupancy, 0.975) # upper BCI
} ; pred.dat = as.data.frame(pred.dat) ; names(pred.dat) = c("mean", "lower", "upper") ; str(pred.dat)

# Plot
par(bty = "l")
par(mfrow = c(1,1)) ###
par(mar = c(5,7,5,1) + 0.1) ## default is c(5,4,4,2) + 0.1

library(viridis)
pal = viridis(10, option = "A")

plot(seq(0,1,,21) ~ Urban, col = "white", xlab="", ylab="", main="Urban Development Effect", xaxt = "n", yaxt = "n", cex = .5, ylim = c(0,1), cex.main = 2.5)
title(ylab = "Occupancy probability", line = 4, cex.lab = 2)
title(xlab = "Urban development (scaled)", cex.lab = 2, line = 3)
axis(2, las = 2, cex.axis = 2)
axis(1, cex.axis = 2, tick = T, at = c(round(min(urban.range),1), round(max(urban.range),1)), line = 0)

lines(urban.seq, pred.dat[,1], col = pal[1], lwd = 5) # Mule deer average response

########
# MOOSE
########

for(i in 1:1000) {
  community.occupancy <- out$sims.list$psi[,2] + out$sims.list$beta.urban[,2] * urban.seq[i]
  community.occupancy <- exp(community.occupancy)/(1 + exp(community.occupancy))
  pred.dat[i,1] <- mean(community.occupancy) # mean prediction
  pred.dat[i,2] <- quantile(community.occupancy, 0.025) # lower BCI
  pred.dat[i,3] <- quantile(community.occupancy, 0.975) # upper BCI
} ; pred.dat = as.data.frame(pred.dat) ; names(pred.dat) = c("mean", "lower", "upper") ; str(pred.dat)

lines(forest.seq, pred.dat[,1], col = pal[3], lwd = 5) # Moose average response

######
# ELK
######

for(i in 1:1000) {
  community.occupancy <- out$sims.list$psi[,3] + out$sims.list$beta.urban[,3] * urban.seq[i]
  community.occupancy <- exp(community.occupancy)/(1 + exp(community.occupancy))
  pred.dat[i,1] <- mean(community.occupancy) # mean prediction
  pred.dat[i,2] <- quantile(community.occupancy, 0.025) # lower BCI
  pred.dat[i,3] <- quantile(community.occupancy, 0.975) # upper BCI
} ; pred.dat = as.data.frame(pred.dat) ; names(pred.dat) = c("mean", "lower", "upper") ; str(pred.dat)

lines(urban.seq, pred.dat[,1], col = pal[5], lwd = 5) # Elk average response

#########
# COYOTE
#########

for(i in 1:1000) {
  community.occupancy <- out$sims.list$psi[,4] + out$sims.list$beta.urban[,4] * urban.seq[i]
  community.occupancy <- exp(community.occupancy)/(1 + exp(community.occupancy))
  pred.dat[i,1] <- mean(community.occupancy) # mean prediction
  pred.dat[i,2] <- quantile(community.occupancy, 0.025) # lower BCI
  pred.dat[i,3] <- quantile(community.occupancy, 0.975) # upper BCI
} ; pred.dat = as.data.frame(pred.dat) ; names(pred.dat) = c("mean", "lower", "upper") ; str(pred.dat)

lines(urban.seq, pred.dat[,1], col = pal[7], lwd = 5) # Coyote average response

#######
# PUMA
#######

for(i in 1:1000) {
  community.occupancy <- out$sims.list$psi[,5] + out$sims.list$beta.urban[,5] * urban.seq[i]
  community.occupancy <- exp(community.occupancy)/(1 + exp(community.occupancy))
  pred.dat[i,1] <- mean(community.occupancy) # mean prediction
  pred.dat[i,2] <- quantile(community.occupancy, 0.025) # lower BCI
  pred.dat[i,3] <- quantile(community.occupancy, 0.975) # upper BCI
} ; pred.dat = as.data.frame(pred.dat) ; names(pred.dat) = c("mean", "lower", "upper") ; str(pred.dat)

lines(urban.seq, pred.dat[,1], col = pal[9], lwd = 5) # Puma average response

legend('bottomleft', bty = "n", cex = 2, col = c(pal[1], pal[3], pal[5], pal[7], pal[9]), lty = 1, lwd = 5, legend = c("Deer", "Moose", "Elk", "Coyote", "Puma"))
```

<p float="center">
  <img src="./plots/species_urban.png" alt="Community occupancy plot across impervious cover using plot()" width="800" height="auto" />
</p>

Four of our five species' parameters seem to follow the community effect pretty closely due to a lack of data, whereas the mule deer effect stands out in both cases
