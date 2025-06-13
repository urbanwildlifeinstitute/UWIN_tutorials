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
    -   `group_by()` groups variables for you to perform operations on the grouped data. Always remember to `ungroup()` once you are finished
    -   `if_else()` vectors to use for TRUE and FALSE values of condition
    -   `case_when()` a sequence of two-sided formulas. The left hand side determines which values match this case. The right hand side provides the replacement value
    -   `_join()` joins add columns from y to x, matching observations based on the keys. There are muliple types of joins. 
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
CSV, or Comma-Separate Values, are a simple and adaptable data format used widley in the coding community. Is allows data to be stored in a tabular format and is compatible with many data tools while still being easy to read by humans. Therefore, when possible, it is best to save and read data into R as a .csv file. This can be done by simply saving an excel file, or .xlsx file as a .csv. Depending on how your data is formated, R may read your data in a less legible way and may require some extra cleaning to *tidy* the data. More on this at the end of the tutorial!

### Note!
R does not like spaces in file or column names and will likley cause strange formatting later. Some of our column names start with a capital letter and others are separated by a space. Lets upate these names to a more R-friendly format. 

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

If you wanted to edit a specific column name, we can also use the function `rename()`.

```R
KameleonData <- KameleonData %>% 
  rename("Date" = "CollectionDate")

# distinct keeps only unique rows from a data frame 
# .keep_all = TRUE let's us keep all the columns in the data frame 
# .keep_all = FALSE to only keep the column we specified in distinct and deletes the rest. 
KameleonData %>% dplyr::distinct(SpeciesName)
```

We will cover a few common mistakes we find in data entry that have the potential to influence and cause errors in our data analyses. These include:
1. Duplicate naming (for example: Male and male) - Even though as humans, we see 'Male' and 'male' as the same, R treats captials and lowercase letters as distinct. Therefore, 'Male' and 'male' will be treated as two different names in R.
2. Adding spaces before or after data - Similar to capitizliations and spelling mistakes, R recognizes spaces like a unique character. Therefore 'Male' and ' Male' will appear to be two different names.
3. Spelling errors (for example: Female and femal) - Again, though we might recognize this spelling mistake, and know the data recorder meant to mark the animal as 'female', we need to correct this in our data to conduct our analyses.

Let's check out some useful tools in R to correct for these mistakes.

```R
# see unique sexes found by R
unique(KameleonData$Sex)
```
In this example, we had five different kinds of sexes recorded, *female*, *male*, *unknown*, *Male*, and *Female*. However, we only want to analyze three types, *female*, *male*, and *unknown*. We can use the function `tolower()` which will turn all uppercase letters into lowercase letters.

```R
# lowercase all letters
KameleonData <- KameleonData %>% 
  mutate(Sex = tolower(Sex))
```
In this code, we use the `mutate()` function to modify our Sex column using `tolower()`. However, we have to tell R if we want this mutatation, or modification, to create a new column or to write over an existing column. Since we want to correct our exisiting column, we can tell R that Sex is the column we want it to write our corrected values into. 

`Mutate()` is a very useful function. It can also help us apply functions not just on one column, like we just did, but multiple. Let's use mutate to apply a function called `trimws()` across all of our columns containing characters (as we glimpsed in our data earlier). We can use `trimws()` to get rid of any trailing spaces before or after our data, for example ' male'. 

```R
# get rid of spaces before and after character data
KameleonData <- KameleonData %>% 
  mutate(across(SpecimenCode:Site, ~ trimws(.))) 
```
Here, our code is saying, mutate columns that fall between SpecimenCode and Site AND apply the function `trimws()` across all of them. 

When glimpsing our data, we also noticed that the Alive column was a bit confusing. Some data entries have an X, others xx, and others are empty! We want to make sure to be consistent with our data entry but when we find mistakes, we can use R to help us find and correct them. Let's look at all the different entry types for this column. 

```R
unique(KameleonData$Alive)
```
Using `mutate()` again, we can apply a new function called `case_when()`. This function allows us to target specific columns and instances of data entry we want to change. We can use different opertors to tell R how we want to change our columns. 

| Operator     | Description                       |
|--------------|-----------------------------------|
| `>`          | greater than                      |
| `>=`         | greater than or equal to          |
| `<`          | less than                         |
| `<=`         | less than or equal to             |
| `==`         | exactly equal to                  |
| `!=`         | not equal to                      |
| `a | b`      | logical OR (either `a` or `b`)    |
| `xor(a, b)`  | exclusive OR (only `a` or only `b`) |
| `a & b`      | logical AND (both `a` and `b`)    |
| `is.na()`    | detects missing (`NA`) values     |
| `!is.na()`   | filters out missing values        |
| `%in%`       | checks if a value is in a set     |

In our case, we want to change the Alive column to be yes, no, or NA. It's important to know that NA may mean a few different things, for example, not applicable, not available, not assessed, or no answer. This is different than zero data. 

For our data, we talk to our field team and determine that empty columns under 'Alive' mean that the field recorder observed the animal to be dead. So in this case, we want to change NA's to 'no'. Note that R will always read in empty data cells as NA so it is important to complete the cells with numbers, characters, or NA's as appropriate. 

```R
# Note '==' is for single values and '%in%' is for multiple values
KameleonData <- KameleonData %>% 
  mutate(Alive = case_when(
    Alive %in% c("x", "xx", "X") ~ "yes",
    is.na(Alive) ~ "no", # Note R will usually populate empty cells with NA's
    TRUE ~ Alive))

unique(KameleonData$Alive)
```


## END
