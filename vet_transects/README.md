# Vetting New UWIN Partner Sites

This script supports the evaluation of prospective Urban Wildlife Information Network (UWIN) partners that are applying to join a UWIN camera-trap study. It helps assess whether proposed study sites meet basic spatial design expectations by mapping site locations, summarizing surrounding land cover, and flagging sites that are too close together.

## Purpose

The main goal of this workflow is to provide a fast and reproducible way to review candidate camera-trap sites before they are approved for participation in a UWIN study. The script combines spatial point data from partner-submitted site files with land-cover rasters and distance checks to support site vetting and study design validation.

## Main sections of the code

### 1. Load libraries
The script loads required spatial and plotting packages, including `sf`, `terra`, `FedData`, `uwinspatialtools`, `ggplot2`, and `tmap`.

### 2. Read and clean site data
Site coordinates are imported from either a `.csv` or `.kml` file. If the KML contains multiple layers, all layers are read and combined into a single spatial object. The data are then cleaned by:
- renaming the site-name column
- removing missing values
- checking coordinate values
- correcting longitude sign issues when needed

### 3. Convert sites to spatial features
The cleaned site table is converted to an `sf` object using geographic coordinates (`WGS84`, EPSG:4326), allowing the sites to be mapped and analyzed spatially.

### 4. Visualize candidate sites
A quick static and interactive map is created to verify that site locations were imported correctly and fall in the expected study area.

### 5. Download and map land-cover data
The workflow downloads 2019 NLCD land-cover data for the area surrounding the candidate sites using `FedData`. A buffered study extent is created, and the land-cover raster is projected and plotted with site locations overlaid.

### 6. Summarize land cover around each site
Using `extract_raster_prop()`, the script calculates the proportion of major land-cover classes within a 1000 m buffer around each site. These classes include:
- water
- lawn/grass
- low, medium, and high urban development
- forest
- shrub
- herbaceous cover
- wetlands
- agriculture

These summaries help evaluate whether the proposed site network captures appropriate habitat variation.

### 7. Plot land-cover distributions
Histograms and summary plots are generated to visualize how much urbanization, green space, forest, and agriculture are represented across the proposed sites.

### 8. Evaluate site spacing
Pairwise distances are calculated between all unique sites. The script flags any site pairs that are closer than 800 meters, which is the recommended minimum spacing for UWIN camera-trap studies.

### 9. Export outputs
The script saves:
- a site map
- urbanization summary plots
- a CSV of NLCD land-cover proportions by site
- a CSV listing site pairs that are too close together

## Outputs

Expected outputs include:

- `./plots/Chicago_landcover.png`
- `./plots/Chicago_urban.png`
- `./data_outputs/Chicago_NLCD_landcover.csv`
- `./data_outputs/site_flags.csv`

## Notes

- This workflow is especially useful for reviewing new partner submissions before site deployment.
- NLCD is used here for North American study areas. For global partners, ESA WorldCover or another land-cover source may be more appropriate.
- Users should confirm that coordinate columns and CRS settings match their input data before running the script.

## Dependencies

Key packages used in this workflow:

- `sf`
- `terra`
- `FedData`
- `uwinspatialtools`
- `dplyr`
- `ggplot2`
- `tmap`
- `ggspatial`
- `purrr`
- `ggpubr`

## Suggested use

This script can be adapted as a standard vetting tool for incoming UWIN partner applications to help ensure that:
1. site coordinates are valid,
2. proposed sites span relevant habitat types, and
3. camera locations are not spaced too closely for study design guidelines.
