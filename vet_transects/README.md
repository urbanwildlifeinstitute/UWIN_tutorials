# Vetting New UWIN Partner Sites

This repository contains workflows used by the **Urban Wildlife Information Network (UWIN)** to evaluate prospective partner cities applying to participate in a UWIN camera-trap and acoustic studies.

The scripts help verify that proposed study sites meet basic spatial design expectations by:

- mapping site locations
- summarizing surrounding land cover
- identifying sites that are too close together

## NLCD Workflow (`vet_transect_NLCD.R`)

### Dataset
**National Land Cover Database (NLCD)**  
Coverage: United States / North America  
Resolution: 30 m  

### Key Steps

1. **Import site coordinates**
   - Read candidate camera locations from `.csv` or `.kml`.
   - Clean and standardize site names and coordinate columns.

2. **Convert to spatial features**
   - Transform coordinates into an `sf` object using WGS84 (`EPSG:4326`).

3. **Visualize proposed sites**
   - Generate quick maps to confirm site placement and spatial accuracy.

4. **Download land-cover data**
   - Use the `FedData` package to automatically download NLCD land cover for the study region.

5. **Summarize land cover around sites**
   - Extract land-cover proportions within a **1000 m buffer** around each site using `extract_raster_prop()`.

6. **Visualize habitat composition**
   - Generate plots summarizing urbanization and habitat composition across sites.

7. **Evaluate spacing between sites**
   - Calculate pairwise distances using `sf::st_distance()`.
   - Flag site pairs closer than **800 meters**, the recommended minimum spacing for UWIN camera deployments.

### Outputs

- Site map with NLCD land cover  
- Urbanization and habitat distribution plots  
- `Chicago_NLCD_landcover.csv` – land-cover proportions around each site  
- `site_flags.csv` – list of site pairs closer than 800 m  

---

## ESA Workflow (`vet_transect_ESA.R`)

### Dataset
**ESA WorldCover**  
Coverage: Global  
Resolution: 10 m  

### Key Steps

1. **Import site coordinates**
   - Read site locations from `.csv` or `.kml`.

2. **Convert to spatial features**
   - Create an `sf` object for mapping and analysis.

3. **Load ESA land-cover raster**
   - Import downloaded WorldCover raster tiles.
   - Merge tiles if the study area spans multiple files.

4. **Crop raster to study area**
   - Reduce raster extent to the bounding box around candidate sites.

5. **Extract land-cover proportions**
   - Summarize ESA land-cover classes within **1000 m buffers** around each site.

6. **Visualize habitat distribution**
   - Generate plots summarizing built area, forest cover, grassland, cropland, and other habitat types.

7. **Evaluate site spacing**
   - Calculate pairwise distances and flag sites closer than **800 meters**.

### Outputs

- Land-cover map with site locations  
- Habitat composition plots for candidate sites  
- `site_flags.csv` – flagged site pairs closer than 800 m  

---

## Key Difference Between Scripts

| Feature | NLCD Workflow | ESA Workflow |
|-------|------|------|
| Geographic coverage | North America | Global |
| Raster resolution | 30 m | 10 m |
| Data download | Automated via `FedData` | Manual download from ESA WorldCover |
| Primary use | U.S. partner sites | International partner sites |

---

These scripts provide a standardized spatial workflow for evaluating proposed UWIN camera-trap sites before study deployment.
