# UWIN Tutorial: Enhancing maps with OpenStreetMap Data
*Created by Kim Rivera and Tiziana Gelmi-Candusso - last updated December 2024*

This tutorial is aimed at those interested in (1) advancing their spatial mapping skills and (2) integrating OpenStreetMap data to enhance exisiting spatial datasets. 
This tutorial builds on work described in the manuscript, 
['Leveraging Open-Source Geographic Databases to Enhance the Representation of Landscape Heterogeneity in Ecological Models' (2024)](https://onlinelibrary.wiley.com/doi/full/10.1002/ece3.70402) by Gelmi-Candusso T., Rodriguez P., Fidino, M., Rivera, K., Lehrer, E.W., Magle, S., & Fortin M. 

### Some helpful references:
1. [Manuscript GitHub Repository](https://github.com/tgelmi-candusso/OSM_for_Ecology.git) - Tiziana Gelmi-Candusso 
2. [OpenStreetMap](https://www.openstreetmap.org/export#map=15/-41.15840/-71.31170)

### Tutorial Aims:

#### <a href="#OpenStreetMaps"> 1. What is OpenStreetMap and why should we use these data?</a>

#### <a href="#pullingandformatting"> 2. Pulling and filtering data</a>

#### <a href="#building"> 3. Building landcover classes</a>

#### <a href="#integrating"> 4. Intgrating Maps</a>


<a name="occupancy"></a>

## 1. What is OpenStreetMap and why should we use these data?
Wildlife ecology and behavior are strongly driven by landscape characteristics, especially in urban regions. Cities are among the world's most heterogeneous landscapes however, global land cover maps often represent urban areas as a single, homogeneous, class therefore limiting our ability to build useful spatial ecological models over large scales. 

However, we can use community-based geographic databases, such as OpenStreetMap (OSM), to improve the quality and spatial resolution of urban land cover data. Take the below example of Chicago, Illinois (USA). On the left we see a reletivley homogenous ladnscape of 'urban' land cover (in red) from the Commission for Environmental Cooperation Land Use Land Cover data. On the right we have the same dataset overlaid by spatial data collected from OSM. 

<p float="center">
  <img src="./figures/visual_comparison.png" alt="Visual comparison of the global land cover used in this study (Commission for Environmental Cooperation (CEC) LULC map, 30 m resolution, left), and the final output of our workflow, the OSM-enhanced land cover map (30 m resolution, right) at the same location, in Chicago, Illinois, USA. Vegetation areas are represented in green shades, barren soil in brown, built environment or land use areas are represented in red shades, different road types are represented in yellow shades, and building footprints are represented in black." width="1000" height="auto" />

</p>

We can see OSM greatly improves our ability to asses heterogeneity in the urban landscape. 
