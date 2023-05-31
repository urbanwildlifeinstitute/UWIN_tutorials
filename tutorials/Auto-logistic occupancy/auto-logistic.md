# UWIN Tutorial: Auto-Logistic Occupancy
*Created by Kimberly Rivera - last updated May 2023 by Kimberly Rivera*

This tutorial is aimed at folks interested and new to occuapncy modeling, or as refesher for those already familiar. This tutorial was designed with the support of outside resources listed below and via workshops developed by Mason Fidino.

### Some helpful references:
1. [An introduction to auto-logistic occupancy models](https://masonfidino.com/autologistic_occupancy_model/) - Mason Fidino
2. [Occupancy models for citizen-science data](https://besjournals.onlinelibrary.wiley.com/doi/10.1111/2041-210X.13090) - Res Altwegg & James D. Nichols

### Tutorial Aims:

#### <a href="#occupancy"> 1. What is Auto-logistic occuancy?</a>

#### <a href="#assumptions"> 2. Occupancy model assumptions</a>

#### <a href="#formatting"> 3. Formatting data</a>

#### <a href="#models"> 4. Fitting models</a>

#### <a href="#plots"> 5. Predicting & plotting model outputs</a>


<a name="occupancy"></a>

## 1. What is Auto-logistic occuancy?
Though static occupancy models can be a useful tool when studying species ecology, they are limited to a 'static' system, meaning we cannot account for changes in species occuancy across years or seasons. By considering a dynamic system, we can study how changing environmental conditions, such climate or fire, may impact species ecology or habitat use. We can also test the impacts of management interventions or account for variations in sampling methodologies. There are a variety of ways we can model a dyanmic system, such as using a dynamic occupancy model, or incorperting random site effects. However these methods require large datasets 
