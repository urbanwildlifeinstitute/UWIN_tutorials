# UWIN Tutorial: Auto-Logistic Occupancy
*Created by Kimberly Rivera - last updated May 2023 by Kimberly Rivera*

This tutorial is aimed at folks interested and new to occuapncy modeling, or as refesher for those already familiar. This tutorial was designed with the support of outside resources listed below and via workshops developed by Mason Fidino.

### Some helpful references:
1. [An introduction to auto-logistic occupancy models](https://masonfidino.com/autologistic_occupancy_model/) - Mason Fidino
2. [Occupancy models for citizen-science data](https://besjournals.onlinelibrary.wiley.com/doi/10.1111/2041-210X.13090) - Res Altwegg & James D. Nichols

### Tutorial Aims:

#### <a href="#occupancy"> 1. What is Auto-logistic occupancy?</a>

#### <a href="#assumptions"> 2. Occupancy model assumptions</a>

#### <a href="#formatting"> 3. Formatting data</a>

#### <a href="#models"> 4. Fitting models</a>

#### <a href="#plots"> 5. Predicting & plotting model outputs</a>


<a name="occupancy"></a>

## 1. What is Auto-logistic occupancy?
Though static occupancy models can be a useful tool when studying species ecology, they are limited to a 'static' system, meaning we cannot account for changes in the environment or species occupancy. By considering a dynamic system, we can account for a lot of things like changing environmental conditions (such as climate or fire), impacts of management interventions, variations in sampling methodologies, or life stages of species. Often, scientists are interested in modeling temporal dynamics or how species ecology or habitat use changes across time (diel, seasonally, or yearly). There are [a variety of ways we can model](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.12100) such a dyanmic system. Some common ways to account for temporal changes include dynamic occupancy models, multi-state occupancy models, or the incorpertion of random site effects. However, all these methods require large amounts of data to estimate all affiliated parameters. An alternative to these methods is using a temporal auto-logistic parameter where occupancy for *t = 2...5* (where t is time) is dependent on the previous *t*'s occupancy.


