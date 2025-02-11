NOTE: For this code to work as intended, your working directory should
be set to `"./tutorials/autologistic_enhanced"` where the `.` represents
the location of the `UWIN_tutorials.Rproj` file on your computer. If you
double-click on `UWIN_tutorials.Rproj` on your computer a new window of
Rstudio will open up and you can enter
`setwd("./tutorials/autologistic_enhanced")` into your R console.

### Tutorial Aims:

#### <a href="#occupancy"> 1. What are Autologistic occupancy models?</a>

#### <a href="#packages"> 2. Load necessary packages</a>

#### <a href="#formatting"> 3. Formatting data</a>

#### <a href="#models"> 4. Fitting models</a>

#### <a href="#plots"> 5. Predicting & plotting model outputs</a>

<a name="occupancy"></a>

## 1. What are Autologistic occupancy models?

Though static occupancy models can be a useful tool to study a species
distribution at a single point in time they are limited to a ‘static’
system, meaning we cannot account for temporal changes in the
environment or species occupancy. By considering a dynamic system (i.e.,
one that can change over time), we can account for things like changing
environmental conditions (such as climate or fire), impacts of
management interventions, or variations in sampling methodologies.
Often, scientists are interested in modeling temporal dynamics or how a
species’ habitat use changes across time. There are [a variety of ways
we can
model](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.12100)
such a dynamic system. Some common ways to account for temporal changes
include dynamic occupancy models, multi-state occupancy models, or with
random effects. However, all these methods require large amounts of data
to estimate all affiliated parameters. An alternative to these methods
is to add a temporal autologistic parameter to the model so that the
occupancy status of a species at one time point depends in part on the
occupancy status in the previous timestep. Unlike the other methods
listed above, autologistic occupancy models only introduce one new
parameter. To get into the nitty gritty of the equations, please review
[this blog post](https://masonfidino.com/autologistic_occupancy_model/)
(also listed in references above) or check out the help file for fitting
autologistic occupancy models ( i.e., `?autoOcc::auto_occ`).

<a name="packages"></a>

## 2. Load necessary packages

We are going to need three packages for this tutorial. You should
already have the `autoOcc` R package installed. If not, then install the
`devtools` package so that you can download the package from GitHub. The
readme file for `autoOcc` has those details [if you need to install that
package](https://github.com/mfidino/autoOcc). Aside from `autoOcc` we
are going to need two packages from the `tidyverse`: `dplyr` and
`ggplot2`. If you do not have `dplyr` or `ggplot2` then the code below
will download them for you.

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

<a name="formatting"></a>

## 3. Formatting data for an Autologistic model

For this example, we are going to be modeling coyote (*Canis latrans*)
occupancy from data we collected throughout Chicago, Illinois. The
`autoOcc` package contains the utility function `format_y()`, which can
be used to prepare the data for analsysis. However, to ensure that
`format_y()` works correctly, the data you supplied to it must be
properly formatted. Specifically, we need a `data.frame` that contains:

-   A column that provides the name of the site that data point is
    associated with
-   A column that provides the primary sampling period that data point
    is associated with
-   Columns that are named in a similar way that contain a species
    detection history.

As a small example, this would be an appropriately formatted
`data.frame`

<table>
<thead>
<tr class="header">
<th>season</th>
<th>site</th>
<th style="text-align: right;">occ_1</th>
<th style="text-align: right;">occ_2</th>
<th style="text-align: right;">occ_3</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>Season1</td>
<td>A</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">1</td>
</tr>
<tr class="even">
<td>Season1</td>
<td>B</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">0</td>
</tr>
<tr class="odd">
<td>Season1</td>
<td>C</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">1</td>
</tr>
<tr class="even">
<td>Season2</td>
<td>A</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">0</td>
</tr>
<tr class="odd">
<td>Season2</td>
<td>B</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="even">
<td>Season2</td>
<td>C</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">1</td>
</tr>
</tbody>
</table>

Some important aspects of this data.frame are:

-   It is sorted by season, then site, and seasons are sorted temporally
    from the first to the last.

-   The columns with the detection history all start the same. The
    `format_y()` function uses regular expressions to collect these
    columns. Thus, this is the easiest way to ensure you collect all of
    them.

-   Detection histories can either have a `1` (species detected), `0`
    (species not detected), or `NA` (sampling did not occur on that
    occasion).

-   It is okay if not every site is represented within each season.
    However, site names for a given sampling location cannot change
    across seasons. For example, if `HUP2` was the name of a sampling
    location then that site must be named `HUP2` across all seasons.
    `HUP3` would be treated as a new site.

Okay, now let’s load in the coyote detection / non-detection data and
take a quick look at it with `dplyr::glimpse()`. The coyote data is
within the data sub-folder and it is titled `chicago_coyote.csv.`

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

We can see here that we have columns for `Season`, `Site`, and the
detection / non-detection data (i.e., `Week_1` through `Week_9`).

### Challenge 1. Use `format_y()`

Check out the help file for `autoOcc::format_y()` to see what the
arguments are for this function. After reading through them, apply
`format_y()` to the `coyote` data.frame. It is okay to overwrite the
`coyote` object with the output from `format_y()`

    # Solution is below if you need it to compare to what you coded up!

<br>

<details closed>
<summary>
Solution</a>
</summary>

      coyote <- autoOcc::format_y(
        x = coyote, # coyote data.frame
        site_column = "Site", # Name of site column in coyote
        time_column = "Season", # Name of season column in coyote 
        history_columns = "Week" # what the detection history columns start with.
      ) 

    ## 
    ## 
    ## TEMPORAL ORDERING
    ## -----------------
    ## 
    ## Primary sampling period column is a character vector, using their order of appearance from top of x to order temporally.
    ## Ordering: JA18, AP18, JU18, OC18, JA19, AP19, JU19, OC19, JA20
    ## 
    ## DETECTION HISTORIES
    ## -------------------
    ## 
    ## 9 detection history columns found.
    ## Column names: Week_1, Week_2, Week_3, Week_4, Week_5, Week_6, Week_7, Week_8, Week_9

</details>

<br>

The output of `format_y` is a three-dimensional array. The dimensions
are site by primary sampling period by secondary sampling period (i.e.,
weeks of sampling within each season). If we wanted to see all the
detection data for site 15 we can use subset notation, but don’t forget
this has three dimensions!

    coyote[15,,]

    ##      Week_1 Week_2 Week_3 Week_4 Week_5 Week_6 Week_7 Week_8 Week_9
    ## JA18     NA     NA     NA      0      0      1      1      0     NA
    ## AP18     NA     NA      1      0      1      0      0     NA     NA
    ## JU18     NA      1      1      1      1      0     NA     NA     NA
    ## OC18     NA     NA     NA     NA     NA     NA     NA     NA     NA
    ## JA19     NA     NA     NA      1      1      1      0     NA     NA
    ## AP19     NA     NA     NA      0      1      1      1      0     NA
    ## JU19     NA     NA      1      1      0      0      0     NA     NA
    ## OC19     NA     NA      1      0      1      1      0     NA     NA
    ## JA20     NA     NA     NA      0     NA      0      1      0     NA

One last thing you may want to ensure is that all of your sites actually
have data. Sites with zero data across all seasons will be dropped from
the analysis in autoOcc, but it’s better to just ensure you remove them
first. Since this is an array the easiest way to do this is with the
`apply()` function. Since we just want to sum across all the data for
each site, the dimension (i.e., MARGIN) we want to apply our function to
is the first one.

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

![](autologistic_tutorial_files/figure-markdown_strict/check_sites-1.png)

<br>

Now that we have the detection data formatted. It is time to read in the
covariate data. The `autoOcc` package can handle covariates that vary
spatially, temporally, or spatiotemporally. For this tutorial we are
going to have two spatial covaraites and one spatiotemporal covariate.
Thes are:

-   An urban intensity metric we will generate with a principal
    components analysis
-   The distance of each site to a stream or river
-   The average weekly temperature of each week of sampling

One thing that is very important to remember is that unlike the
detection data, the covariates CANNOT have missing data (i.e., `NA`
values).

To read in the spatial covariates, copy this code here:

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

<br>

This dataset has 100 rows (we have 100 sites worth of data) and five
columns:

-   `Site`: The site the covariates are associated to. This is ordered
    exactly the same is the `coyote` data, and site names are identical
    among the two datasets.
-   `tree`: The proportion of tree cover within 1000m of a site. To be
    used for urban intensity PCA.
-   `imperv`: The proportion of impervious cover within 1000m of a site.
    To be used for urban intensity PCA.
-   `housing_density`: The number of houses per square km within 1000m
    of a site. To be used for urban intensity PCA.
-   `dist_stream`: The distance of each site to a stream or river in km.

To generate the urban intensity term, we are going to use `dplyr` to
select only the columns we need and then use the `prcomp()` function in
base `R`.

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

The first principal component (PC1) explains about 70% of the variation
in the data, so we will go ahead and use only that one. We can interpret
this term by looking at the loadings associated to `urb_pca`. We are
going to round them as well as we don’t need to see that many
significant digits.

    round(
      urb_pca$rotation,
      2
    )

    ##                   PC1   PC2   PC3
    ## tree            -0.55 -0.70  0.46
    ## imperv           0.64  0.01  0.77
    ## housing_density  0.54 -0.71 -0.44

### Challenge 2: Interpret PC1

The first principal component can be accessed via `urb_pca$x[,1]`.
However, we don’t need to look at those to be able to interpret this, we
only need the loadings above. What do you think they mean?

<br>

<details closed>
<summary>
Solution</a>
</summary>
For `PC1` we see that `imperv` and `housing_density` are both positive,
while tree is negative. This means that negative values of the urb\_pca
are locations high in tree cover whereas positive values of the urb\_pca
are locations high in impervious cover and housing density. So negative
is more forested and positive is more urban.
</details>

<br>

The second covariate we have is the distance of each site to a stream or
river. We included this one as riparian areas are often used a corridors
for mammals. However, before we include it into our covariate data.frame
for analysis we need to scale it (we set scale = `TRUE` when making the
principal component term). Why do you scale covariates for an analysis?
It makes it more likely for the statistical algorithms used in `autoOcc`
to converge. Scaling also makes it so you can compare the magnitude of
slope terms in your model. As our occupancy covariates do not have any
spatio-temporal data, we can assemble our covariates in a `data.frame`.

    occ_covs <- data.frame(
      urb = urb_pca$x[,1], # the PC1 term.
      dist_stream = as.numeric(
        scale(
          covs$dist_stream
        )
      )
    )

In addition to these covariate data, we also have weekly temperature
data to include as a detection covariate. Since Chicago experiences four
distinct seasons, coyote may alter their behavior when it’s either hot
(the summer) or when its cold (the winter). This is also to show how to
include survey-specific covariates on detection, which is something
`autoOcc` can easily handle.

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

You want to have the `data.frame` set up so all the data for each site
is grouped together, and each grouping is arranged temporally from the
beginning to the end of the study. Thus, this `data.frame` is set up to
vary by week, season, and then site.

Before we arrange the data, let’s query some of the dimensions we are
going to need to set it up.

    # right now the data are set up so it varies by week, season, and then site. 
    nweek <- dplyr::n_distinct(week_temp$Week)
    nseason <- dplyr::n_distinct(week_temp$Season)
    nsite <- dplyr::n_distinct(week_temp$Site)

To set up this covariate we are going to need to create a matrix with a
number of rows equal to `nsite` and a number of columns equal to
`nweek * nseason` the first `nweek` columns will be for the first
season, then the next `nweek` are for season 2, etc., etc. So each row
is going to hold all the temperature data for one site. Because of the
way the ordering in week\_temp (week, season, then site) we can just
input the covariate and fill the `matrix` in the correct way by setting
the `byrow` argument to `TRUE`.

## Challenge 3. Make the temperature matrix.

The paragraph right above challenge three has all the info you would
need to correctly generate the `matrix` in `R`. Give it a go!

    # Solution is below

<details closed>
<summary>
Solution</a>
</summary>

    temp_matrix <- matrix(
      week_temp$temp,
      ncol = nweek * nseason,
      nrow = nsite,
      byrow = TRUE
    )

</details>

<br>

Now, all columns of this matrix are associated to the same covariate,
and so to scale this covariate we need to divide each column by the
global mean and divide by the global standard devation. Since this is a
matrix this is a bit easier to just do by hand instead of using the
`scale` function.

    temp_matrix <- (
      temp_matrix - mean(temp_matrix)
    ) / sd(temp_matrix)

Finally, we are also going to include urban intensity as a detection
covariate. We are doing this because local abundance can influence
detection probability, and coyote abundance likely covaries with urban
intensity. Unlike the occupancy covariates, we will have one
spatio-temporal covariate and one spatial covariate. Thus, we need to
use a named `list` object for the detection covariates instead of a
`data.frame`. If your detection covariates are only spatial in future
analyses you can just use a `data.frame`.

    det_covs <- list(
      temp = temp_matrix,
      urb = occ_covs$urb
    )

<a name="models"></a>

## 4. Fitting models

The `autoOcc` package was based on `unmarked`, so if you have any
familiarity with `unmarked` you will find that the equation syntax is
identically. If you are unfamiliar, for this model you need to specify
two linear predictors to fit the model (detection then occupancy).
Spefically, the `auto_occ()` function uses a double-right hand side
formula, which means you do not need to specify what the response
variable in the formula itself. For example, the syntax for an intercept
only model would be `~1~1`.

For this workshop we are going to fit five models. There are certainly
others that could be fitted with the supplied covariates, but this is a
decent start. You will notice that all of our models include the same
linear predictors for detection, included both linear and quadratic
responses to urban intensity and weekly temperature. The main reason for
this is just because we are not too interested in trying to determine
the most parsimonious detection model and the AIC of these models can be
quite sensitive to changes in detection covariates.

These models we will fit include:

-   Occupancy does not covary with any covariates. The null. (`~1`)
-   Occupancy is associated with urban intensity (`~urb`)
-   Occupancy is associated with distance to a stream or river
    (`~dist_stream`)
-   Occupancy is associated with both spatial covariates
    (`urb + dist_stream`)
-   Occupancy is associated with both spatial covariates, and there is
    an interaction betwen the two (`urb * dist_stream`)

To fit an autologistic occupancy model you use the `autoOcc::auto_occ()`
function. Go ahead and copy / paste this code into your script and run
fit them all. Note that if you changed the names of any of the objects
above you will also need to modify them here. Finally, note that I am
using 85% confidence intervals here instead of the standard 95% most
people use. Why? [It aligns more closely with the use of
AIC](https://royalsocietypublishing.org/doi/full/10.1098/rspb.2023.1261).

But before we fit all the models, let’s fit the simplest and look at a
summary of the output.

    # the null model
    null <- auto_occ(
      ~temp + I(temp^2) + urb + I(urb^2)
      ~1, # detection linear predictor first, then occupancy
      y = coyote,
      occ_covs = occ_covs,
      det_covs = det_covs,
      level = 0.85 # Using 85% CI because it aligns more with the use of AIC
    )

    summary(null)

    ## 
    ## Call:
    ## auto_occ(formula = ~temp + I(temp^2) + urb + I(urb^2) ~ 1, y = coyote, 
    ##     det_covs = det_covs, occ_covs = occ_covs, level = 0.85)
    ## 
    ## 
    ## optim convergence code: 0
    ## optim iterations: 48 
    ## 
    ## Occupancy estimates:
    ## 
    ##           parameter    Est    SE lower  upper        p
    ## 1 psi - (Intercept) -0.839 0.151 -1.06 -0.622 2.54e-08
    ## 2       psi - theta  2.244 0.309  1.80  2.689 3.83e-13
    ## 
    ## Note: psi - theta is the autologistic term
    ## 
    ## Detection estimates:
    ## 
    ##           parameter     Est     SE   lower   upper        p
    ## 3 rho - (Intercept) -0.7927 0.0953 -0.9299 -0.6556 8.82e-17
    ## 4        rho - temp -0.1181 0.0533 -0.1948 -0.0414 2.67e-02
    ## 5   rho - I(temp^2)  0.0862 0.0464  0.0195  0.1529 6.29e-02
    ## 6         rho - urb -0.2476 0.0560 -0.3282 -0.1671 9.63e-06
    ## 7    rho - I(urb^2) -0.0750 0.0265 -0.1131 -0.0368 4.65e-03
    ## 
    ## AIC: 2827.861

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
