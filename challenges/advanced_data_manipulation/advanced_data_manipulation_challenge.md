# UWIN Challenge: Advanced Data Manipulation
## Coding Club Reference tutorial [__here.__](https://ourcodingclub.github.io/tutorials/data-manip-creative-dplyr/)

Let's take a peek at some real data derived from the Urban Wildlife Information Network. Start by loading in neccessary libraries and UWIN data

```R
# Load in libraries
library(dplyr)
library(ggplot2)

# Set your local working directory
setwd()
UWIN_data <- read.csv("full_capture_history.csv", header = TRUE) 

# Check out what data we're working with.
head(UWIN_data)
```

### Understanding our data
These are summary statistics of wildlife found at unquie sites sampled by camera traps in 19 cities across the US and Canada. Below is a table of City acronyms and descriptions of each column header. 

| City                      | Code   |
|---------------------------|--------|
| Atlanta, Georgia          | `atga` |
| Austin, Texas             | `autx` |
| Chicago, Illinois         | `chil` |
| Denver, Colorado          | `deco` |
| Edmonton, Alberta         | `edal` |
| Fort Collins, Colorado    | `foco` |
| Iowa City, Iowa           | `icia` |
| Indianapolis, Indiana     | `inin` |
| Jackson, Mississippi      | `jams` |
| Manhattan, Kansas         | `maks` |
| Madison, Wisconsin        | `mawi` |
| Orange County, California | `occa` |
| Phoenix, Arizona          | `phaz` |
| Rochester, New York       | `rony` |
| Sanford, Florida          | `safl` |
| Salt Lake City, Utah      | `scut` |
| Seattle, Washington       | `sewa` |
| Tacoma, Washington        | `tawa` |
| Wilmington, Delaware      | `wide` |


| Column  | Type      | Description                                                                                                                                       |
|---------|-----------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| Site    | Character | The code for the site name.                                                                                                                       |
| Long    | Longitude | Longitude of site (crs = 4326).                                                                                                                   |
| Lat     | Latitude  | Latitude of site (crs = 4326).                                                                                                                    |
| Crs     | Integer   | Coordinate reference system for the site coordinates.                                                                                             |
| Species | Character | The common-name of a given species.                                                                                                               |
| Season  | Character | The four letter sampling period abbreviation. JA = January, AP = April, JU = July, OC = October. The numbers designate the year (e.g., 19 = 2019) |
| City    | Character | The city code for a given city.                                                                                                                   |
| Y       | Integer   | The number of days the species was detected, Y <= J.                                                                                              |
| J       | Integer   | The number of days a camera was operational on a given deployment at a site.                                                                      |

## Challenge 1. 
### Changing column names

<details open><summary><a href="https://hello.ca">link text</a></summary>

Works!

</details>

Today we are going to use `ggplot2` to make pretty graphs

This is normal text, look a code block written in python:

```R
name = raw_input('What is your name?\n')
print 'Hi, %s.' % name
```

<a name="syntax"></a>

