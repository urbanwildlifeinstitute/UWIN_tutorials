# UWIN_tutorial guide

Thanks for your interest in the Urban Wildlife Information Network R workshops! Below is a guide on contributing new tutorials. For more details on each tutorial, examine the tutoral folder's `.md` file. Feel free to contact krivera@lpzoo.org if you have any questions.

# Guide to contributing tutorials

## Publishing a tutorial

1. Register on Github and ask UWIN Coordinator (Kim Rivera | krivera@lpzoo.org) to add you to the UWIN account.

2. Create a new branch of the 'https://github.com/urbanwildlifeinstitute/UWIN_tutorials.git' repository with a title related to your tutorial/post. Creating new branches, files etc. can done either using the Github web interface or by cloning the repository to your own computer and doing it locally. 

3. Switch to the new branch, and create a new folder with a tutorial shorthand name. Use the same name for the `.md` file for your tutorial in the `tutorials/` folder. You can create a `.md` file through the Github web interface (remember you need to specify the file extension, e.g. `filename.md`), or by opening a text editor (see suggestions below) and going to `File/New file`.
	-  Name the file like this: `krivera.data-vis.md`, where: 
		-  `krivera` is the lead authors first initial and last name
		-  `data-vis` is a word relating to the content of your tutorial.

4. Edit the new file using your faviourite plain text editor (_e.g._ Atom, TextEdit, Notepad, Vim, Sublime). Use the <a href="#style">style guide below</a> based on the [coding club guidelines](Tutorial_publishing_guide.md) and existing tutorials as a guide. Are there any pre-requisites to completing your tutorial? You can add links to previous tutorials, so that people can complete them first, and then come back to your tutorial. It's nice to have in text references to previous tutorials with links to them, as that way more people can find out about them.

6. Upload any images to a `plots` folder within your tutorial.

9. Create a pull-request for your branch to be merged with the master branch. 

<a name="style"></a>

## Style Guide

### Header Material

This material should appear at the top of every tutorial `.md` file. The `title` should be the full name of your tutorial which is related to the short hand folder and `.md` file.

1. Title
2. Author/s of tutorial and month & year of last update
3. Who the tutorial is aimed at and where your resources are from (if you used any specific datasets or tutorials)
4. List of resources use with hyperlinks

Here is an example header:

```
# UWIN Tutorial: Autologistic Occupancy
*Created by Kimberly Rivera - last updated May 2023 by Kimberly Rivera*

This tutorial is aimed at folks interested and new to occupancy modeling, or as refresher for those already familiar. This tutorial was designed with the support of outside resources listed below and via workshops developed by Mason Fidino.

### Some helpful references:
1. [An introduction to auto-logistic occupancy models](https://masonfidino.com/autologistic_occupancy_model/) - Mason Fidino
2. [Occupancy models for citizen-science data](https://besjournals.onlinelibrary.wiley.com/doi/10.1111/2041-210X.13090) - Res Altwegg & James D. Nichols
```

### Introduction Material

A tutorial should be broken down into tangible aims. Each aim should be in the form of an action where possible ('ing' words, learning, understanding, organising etc.). Each aim should be represented by a subheading in the tutorial with the same name where possible:

```
### Tutorial Aims:

#### <a href="#sections"> 1. Organising scripts into sections</a>

#### <a href="#syntax"> 2. Following a coding syntax etiquette</a>

```

### Subheadings

First level subheadings should be denoted by `##` and should contain the same text as the Tutorial Aim which links to it. All first level subheadings should be preceded by an internal link, linking it to a given Tutorial Aim. Second level subheadings should be denoted by `###`, third level by `####` and so on..

```
<a name="sections"></a>

## 1. Organising scripts into sections

### Subheadings like this

Some text

<a name="syntax"></a>

## 2. Following a coding syntax etiquette
```

### Referring to code and GUI elements:

When referring to an R package, file name, menu item, file type extension, object name or code snippet in text, always wrap in ````:

```
Today we are going to use `ggplot2` to make pretty graphs

The template can be found in `~/git_proj/template.R`

Click `New Script...` to make a new script

Go to `File/New file/R script` to get started

`width = 1.6` means give the image a width of 1.6 inches
```

When referring to an R function in text, always wrap in ```` and add `()` to the end:

```
Today we are going to use `ggplot()` to make a bar graph
```

When copying in a large chunk of code, add ```` ``` ```` above and below it. The language of the code can also be defined so the correct syntax highlighting is used:

````
This is normal text, look a code block written in python:

```python
name = raw_input('What is your name?\n')
print 'Hi, %s.' % name
```
````

### Tables

Feel free to use R markdown or add tables to `plots` folder as a .png or other image file type (.tiff). 

### Web Links

To add hyperliks to text enclose your text in brackets `[ ]` followed by parenthesis containing your link `( )`.


### Hidden Solutions
If you want to add challenges or require participants to work on a solution, you can add the following syntax to hide code chunks or text:

```
<details closed><summary>Solution</a></summary>

	HIDDEN CODE AND TEXT

</details>
```

### General stylistic points

Bold text can be used to draw attention to an important action point using `__`, but don't overdo it:

```
__Copy and paste the code below into your script:__
```

<a name="work_html"></a>


## Creating a `tutorial.md` for your tutorial resources repository on github

The .md file is where participants will follow the tutoial. This should have all code chunks to follow a tutorial completely (e.g. the code should run uninterrupted if copied and pasted locally).  

```
