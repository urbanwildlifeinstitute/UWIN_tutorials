# UWIN Challenge: Advanced Data Manipulation
## Coding Club Reference tutorial: https://ourcodingclub.github.io/tutorials/data-manip-creative-dplyr/

Let's take a peek at some real data derived from the Urban Wildlife Information Network. Start by loading in neccessary libraries and UWIN data

```R
library(dplyr)
library(ggplot2)

setwd()
UWIN_data <- read.csv("full_capture_history.csv", header = TRUE) 

```


## 1. Working with .tif files

Today we are going to use `ggplot2` to make pretty graphs

This is normal text, look a code block written in python:

```R
name = raw_input('What is your name?\n')
print 'Hi, %s.' % name
```

<a name="syntax"></a>

