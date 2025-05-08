# Introduction to Data Manipulation and Cleaning in R using the Tidyverse

*Authors: Gabriela Palomo, Hannah Griebling, & Kimberly Rivera*

## Learning objectives

-   After today's lecture, you'll be able to:

    -   Understand the structure of tidy data
    -   Understand the main tidy verbs in dplyr to help tidy data
    -   Organize and clean commonly seen ecological data 

## Packages

These are the packages that we are going to be working with for this tutorial.

```{r}
install.packages("tidyr")
install.packages("dplyr")
install.packages("readxl")
install.packages("janitor")

library(dplyr) # grammar of data manipulation using set of verbs; tidyverse 
library(tidyr) # tidy data; tidyverse
library(readxl)
library(janitor)
```

## Organize the project and directory

Perhaps you are used to starting by setting your directory using `setwd()`. However, we highly recommend you use RStudio Projects. RStudio projects make it straightforward to divide your work into multiple contexts, each with their own working directory, workspace, history, and source documents.

We are going to start by creating a Project in RStudio. A Project is essentially a directory which will contain all the files you need for a specific project. It will have a `*.RProj` file associated with it to begin with.

Go to RStudio and click on File \> New Project.

<p float="center">
  <img src="./images/new_project.png" width="500" height="auto" />

</p>

Now you see three options:

-   **New directory**: choose this option if you want to create a folder that will contain all the subdirectories and files of this particular project.
-   **Existing directory**: use this option if you already created a folder which will contain all the subdirectories and files for this particular project. Choose that folder here.
-   **Version Control**: choose this option if you are going to work with a repository already stored in GitHub.

For our own project, let's go ahead and choose 'New Directory' and let's name our project, for example: '2025_data_cleaning'

### Other files inside the main directory

You will have a series of directories inside your project, depending on the type of work that you'll be working on. Some people recommend following the same structure that you would use if creating an r package. However, we think that at a minimum, you could have the following structure:

<p float="center">
  <img src="./images/dir_str.png" width="500" height="auto" />

</p>


-   **Data** is a directory that has all your original .csv files with the data that you will use in your analysis.
-   **Functions** is a directory that houses all the functions you create and that you will be using throughout your analysis. Some people include this directory as a subdirectory of R.
-   **Plots** is a directory in which you will put all the graphs you create as part of your analysis.
-   **R** is a directory that will have all the scripts needed for your analysis.
-   **Results** is a directory that you may or may not need. The idea is to include all the resulting .csv or .rds files in here and keep them separate from your original files.
-   You may need other directories, especially if you are working with spatial data, for example, shapefiles, rasters, maps, etc.

## Naming files

Now we should discuss a very important topic which is **naming files**.
1. File names should be **machine readable**: avoid spaces, symbols, and special characters. Don't rely on case sensitivity to distinguish files.
2. File names should be **human readable**: use file names to describe what's in the file.
3. File names should play well with default ordering: start file names with numbers so that alphabetical sorting puts them in the order they get used.

Here are a few examples of **bad names**:

-   `Document 1.docx`
-   `manuscript_final.docx`
-   `final_document_final.qmd`
-   `data.csv`

Here are a few examples of **good names**:

-   `2024_05_03_manuscript_name.R`
-   `01_data_cleaning.R`
-   `02_model.R`
-   `fig-01.png`
-   `exercise-uwin-workshop.qmd`

Why are these **good names**? Well because if you have several of those, you can arrange them by date (descending or ascending), or by order of fig-01, fig-02.

### Warning!

It's important to note that `fig-01.png` is not the same as `fig-1.png` because your computer will read the following files in this order: `fig1.png`, `fig10.png`, `fig11.png`, `fig2.png`.

## Let's talk about pipes

-   At the beginning there was only one [pipe operator](https://magrittr.tidyverse.org/reference/pipe.html), `%>%`, which is from the `magrittr` package.

-   The idea is to have a way to pipe an object forward into a function or call expression.

-   It should be read as 'then'. For example: The following code is read as follows: start with object df THEN select col1.

```{r, echo=TRUE, eval = FALSE}
df %>% select(col1)
```
<p float="center">
  <img src="./images/magrittr_pipe.png" width="500" height="auto" />

</p>

## Native pipe in base R

-   Now, base R has it's own pipe called native pipe, `|>`, which is also read as 'then'.

-   You can activate this native pipe by going to Tools \> Global options \> Code and selecting that option.

<p float="center">
  <img src="./images/pipe.png" width="500" height="auto" />

</p>

-   You can read more about the differences between both pipes [here](https://www.tidyverse.org/blog/2023/04/base-vs-magrittr-pipe/).

## `dplyr` verbs: data transformation

-   `dplyr` is a package based on a grammar of data manipulation, providing a consistent set of verbs that help you solve the most common data manipulation challenges:

    -   `mutate()` adds new variables that are functions of existing variables
    -   `select()` picks variables based on their names
    -   `filter()` picks cases based on their values
    -   `summarise()` reduces multiple values down to a single summary
    -   `arrange()` changes the ordering of the rows
    -   `group_by()` groups variables for you to perform operations on the grouped data. Always remember to `ungroup()` once you are finished

-   These can be linked together by pipes `|>` or `%>%`

-   Cool [cheatsheet for dplyr](https://github.com/rstudio/cheatsheets/blob/main/data-transformation.pdf)

## `tidyr` for tidying data

-   The `tidyr` package has a series of functions that are named after verbs that will help you tidy and clean data.

-   The goal of `tidyr` is to help you create **tidy data**. Tidy data is data where:

    -   Each variable is a column; each column is a variable

    -   Each observation is a row; each row is an observation

    -   Each value is a cell; each cell is a single value

-   Cool [cheatsheet for tidyr](https://github.com/rstudio/cheatsheets/blob/main/tidyr.pdf)

## Data organization for analyses!

First things first, let's see the data that we are going to be working with. To do so, let's use a super handy package called `readr` which is part of the `tidyverse`, specifically a function called `read_csv()`. The data we want is a `.csv` document and is conveniently stored in a folder called `data`.

```{r}
KameleonData <- read_csv("KameleonData.csv")

# With glimpse we can see the name of each column, type, and the first rows 
dplyr::glimpse(KameleonData)
```
### What is CSV and why do we use it?
CSV, or Comma-Separate Values, is a simple and adaptable data format used widley in the coding community. Is allows data to be stored in a tabular format and is compatible with many data tools while still being easy to read by humans. Therefore, when possible, it is best to save and read data into R as a .csv file. This can be done by simply saving an excel file, or .xlsx file to .csv. Depending on how your data is formated, R may read your data in a less useful way and may require some extra cleaning. More on this at the end of the tutorial!

### Note!

Let's look at the column names. They start with a capital letter and some are separated by a space. R does not like spaces in file or column names and will likley cause strange formatting later. Lets upate these names to a more readable format. 

Frist let's review some common naming conventions:

<p float="center">
  <img src="./images/case_con.png" width="500" height="auto" />

</p>

This is important to remember so that you (and your team) can always stick to a name convention to make things easier for everyone. Whichever you use, DO NOT USE A SPACE TO SEPARATE WORDS.

-   These are ok for the name of a column: 'day01', 'Day_1', 'day1', 'day-01', 'day-1'
-   This is not ok: 'day 1'

You can leave the column names as is, but we want to show you a super handy function in package `janitor` that can help us rename all the columns to fit one naming convention. The options for `case` are 'snake', 'lower_camel', 'title', 'upper_camel'.

```{r}
# clean_names has the following cases: 
# "snake"
# "lower_camel"
# "upper_camel"
# "title" 
# detect abbreviations with abbreviations = c()
KameleonData <- janitor::clean_names(dat = KameleonData, 
                                     case = 'upper_camel')

# view data
glimpse(occ.KameleonData)
```

If you wanted to edit a specif column name, we can also use the function `rename()`.

```R
KameleonData <- KameleonData %>% 
  rename("Date" = "CollectionDate")

# distinct keeps only unique rows from a data frame 
# .keep_all = TRUE let's us keep all the columns in the data frame 
# .keep_all = FALSE to only keep the column we specified in distinct. Deletes the rest. 
KameleonData %>% dplyr::distinct(SpeciesName)
```

We will cover a few common mistakes we frequently see in data entry that have the potential to influence and negativley impact our data. These include:
1. Duplicate naming (for example: Male and male)
2. Spelling errors (for example: Female and femal)
3. Adding spaces before or after data

Even though as humans, we believe 'Male' and 'male' to be the same, R treats captials and lowercase letters as distinct differences. Therefore, 'Male' and 'male' will be treated as two different names in R. Check out this example:

``
## END
