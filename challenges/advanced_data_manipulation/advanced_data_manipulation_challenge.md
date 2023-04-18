# UWIN Challenge: Advanced Data Manipulation
## Coding Club Reference tutorial [__here.__](https://ourcodingclub.github.io/tutorials/data-manip-creative-dplyr/)

Let's take a peek at some real data derived from the Urban Wildlife Information Network. Start by loading in neccessary libraries and UWIN data. Today we are going to use `ggplot2` and `dplyr`.

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

### Breaking down our data
These are summary statistics of wildlife found at unquie sites sampled by camera traps in 19 cities across the US and Canada. Below is a table of City acronyms...

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

and descriptions of each column header... 

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
We decide that `Y` and `J` are confusing column names because we keep forgetting what they stand for. Let's update these to be more descriptive names. We will change `Y` to `det_days` and `J` to `cam_days` using `dplyr` functions.

<details closed><summary><a href="https://hello.ca">Solution</a></summary>

```R
UWIN_data <- rename(UWIN_data, det_days = Y, cam_days = J)
head(UWIN_data)
```
             
</details>





