# UWIN Challenge: Basic Data Manipulation
## Coding Club Reference tutorial [__here.__](https://ourcodingclub.github.io/tutorials/data-manip-intro/)

### Cleaning and classifying data using basic functions
Now that we have a few basic tool we can use to manipulate and clean data, we can test our skills with some data we may see while conducting urban wildlife research with UWIN. We will also apply the same skills to managing and manipulating time data.

```R
# Load in libraries
library(dplyr)
library(ggplot2)

# Set your local working directory
setwd()
field_data <- read.csv("field_data.csv", header = TRUE) 
cap_hist <- read.csv("capture_history.csv", header = TRUE) 

# Check out what data we're working with
head(field_data)
head(cap_hist)

str(field_data)
str(cap_hist)
```

## Challenge 1. 
### Classifying time data
By examining our data with 'str()' above, we can see that *Date* and *Time* are classified as characters. 

```R
class(field_data$Date)
class(field_data$Time)
```
However, we will need to classify these as an appropriate date/time format if we want to extract and manipulate data with helpful R functions

As in the coding club tutorial, where we converted 'zone' from a character to a factor, we need to convert *Date* and *Time* to a usebale time format, specifically to a format called 'POSIXct' which can store date and time together with their affiliated time zone in one column (or two). For more information on this time class and other formats review [NEON's Time Series Tutorial](https://www.neonscience.org/resources/learning-hub/tutorials/dc-convert-date-time-posix-r).

An easy way to manipulate time series data is using the `lubridate` package. 
```R
library(lubridate)
?lubridate
OlsonNames()
```
Review the lubridate help file and convert *Date* and *Time* fields into a POSIXct format. 

<details closed><summary>Solution</a></summary>

```R
# reclass 'Date'
field_data$Date <- mdy(field_data$Date, tz = "US/Central")
# confirm this worked
class(field_data$Date)

# reclass 'Time'
field_data$Time <- hm(field_data$Time)
# confirm this worked
class(field_data$Time)
```
             
</details>

Nice work. This package is very handy and can be used to easily extract specific time components, for example:
```R
minute(field_data$Time)
day(field_data$Date)
```

## Challenge 2. 
### Cleaning data
When examening our data, we notice there is an issue with our *Date* field. R warned us of this above with 'Warning message: 1 failed to parse' meaning, one value was converted to an 'NA'. If we reload the data, we can see that there was an error when someone entered the data. Let's fix it to the correct date--6/30/2022.

We can do this two different ways, with a row/column location or with a logicial condition (column name). Try this both ways.

<details closed><summary>Solution</a></summary>
  
```R
# do this first with the row and column location of the incorrect date
field_data[10,9] <- mdy("6/30/2022", tz = "US/Central") 

# If we wanted to do this using logical conditions (by column names), 
# we can reload data and convert again. 
field_data <- read.csv("field_data.csv", header = TRUE) 
field_data[field_data$Date == "6/39/2022",]$Date <- "6/30/2022" 

# Now we need to update Date and Time variables with corrected data
field_data$Date <- mdy(field_data$Date, tz = "US/Central")
field_data$Time <- hm(field_data$Time)
```         
</details>

We also notice another entry mistake when examining our data. One year was entered incorrectly, 2003 rather then 2023. We can correct this using a logical condition as done above.

<details closed><summary>Solution</a></summary>
  
```R
unique(field_data$Year)
# let's use logical conditions to look at the whole row including this data point
field_data[field_data$Year == "2003",] 
# based on the 'Date' column, we can correct the 'Year' to 2023. Try this now.
field_data[field_data$Year == "2003",]$Year <- "2023" 
```
          
</details>

Let's correct two more mistakes. We will fix an entry in *Camera.sensitivity* from 'Nrmal' to 'normal' and in *Lure*, an entry from 'None' to 'none'. We do this because all other entries are wrtitten as 'none' and we need to keep all columns consistent for later analysis. Remember R is case sensitive, meaning 'None' and 'none' will be read as two different values. 
  
<details closed><summary>Solution</a></summary>
  
```R
unique(field_data$Camera.sensitivity)
field_data[field_data$Camera.sensitivity == "Nrmal",]$Camera.sensitivity <- "normal"

unique(field_data$Lure)
field_data[field_data$Lure == "None",]$Lure <- "none"
```

</details>

  
## Challenge 3. 
### Joining data
Now that our 'field_data' appears to be cleaned up, we can use begin using this data or link it to other datasets like 'cap_hist'. 

When collecting or managing data, it is often helpful to break-up data into multiple data sheets (in the field) or data tables (multiple .csv's). However, to link these data later, it is important to have a column, or 'key', that is shared across datasets.

For our purposes, we may want to know if there were lures present during camera deployments to account for variation in species' detection. However, lure is not a column in our 'cap_hist' data.frame. We can add this to the 'cap_hist' data.frame with the join() function. It's important to note that the best way to link data is through a unique identifier. In our case, one table, 'field_data' contains data specific to camera deployments or visits while the other table 'cap_hist' is specific to a camera station. Here, there is no one unique identifier which links both datasets.

It is still possible to link these tables however, but certain elements will be repeated. Therefor it is important to consider how variables are linked and what variables are necessary to your analyses. If we assume that the presence of a lure has an equal impact on detections across a sampling periods (e.g. the lure's scent does not vary across visits--set, check, and pulls), we can link the column *Lure* to each camera station for each year (to account for lure presence which may vary year to year). 
    
<details closed><summary>Solution</a></summary>

To determine which species occur in both cities of your choosing, start by filtering down to these cities AND filter to detections `det_days` greater than zero. 
```R
# filter to cities of interest
UWIN_subset <- filter(UWIN_data, City %in% c("atga", "wide")) 

# Filter out zero detections to find species present in your cities of interest
UWIN_subset <- filter(UWIN_subset, det_days > 0)

# Now let's see which species occur in both cities
UWIN_atga <- filter(UWIN_subset, City == "atga")
UWIN_wide <- filter(UWIN_subset, City == "wide")

int <- intersect(UWIN_atga$Species, UWIN_wide$Species)
int
```
       
Filter down to 3 species of interest which occur in both cities
```R
UWIN_subset <- filter(UWIN_subset, Species %in% c("virginia_opossum", "red_fox",
                                                   "weasel_sp"))
```
  
Now, plot detections for each species
```R
ggplot(data = UWIN_subset, aes(x = Species, y = det_days, fill = City)) +
  geom_bar(stat = "identity") +
  labs(title = "Species Detections", x = "Species", y = "Detections") +
  theme_minimal() 
```

<p float="left">
  <img src="./plots/sp_det.png" alt="A plot of species detections in two cities." width="500" height="auto" />
</p>
             
</details>


  
