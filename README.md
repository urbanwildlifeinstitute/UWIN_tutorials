# UWIN_tutorial guide

Thanks for your interest in the Urban Wildlife Information Network R workshops! Below is a guide on contributing new tutorials. For more details on each tutorial, examine the tutoral folder's `.md` file. Feel free to contact krivera@lpzoo.org if you have any questions.

# Guide to contributing tutorials

## Publishing a tutorial

1. Register on Github and ask UWIN Coordinator (Kim Rivera | krivera@lpzoo.org) to add you to the UWIN account.

2. Create a new branch of the 'https://github.com/urbanwildlifeinstitute/UWIN_tutorials.git' repository with a title related to your tutorial/post. Creating new branches, files etc. can done either using the Github web interface or by cloning the repository to your own computer and doing it locally. 

3. Switch to the new branch, and create a `.md` file for your tutorial in the `tutorials/` folder. You can create a `.md` file through the Github web interface (remember you need to specify the file extension, e.g. `filename.md`), or by opening a text editor (see suggestions below) and going to `File/New file`.
	-  Name the file like this: `krivera-datavis.md`, where: 
		-  `krivera` is the lead authors first initial and last name
		-  `datavis` is a word relating to the content of your tutorial.

4. Edit the new file using your faviourite plain text editor (_e.g._ Atom, TextEdit, Notepad, Vim, Sublime). Use the <a href="#style">style guide below</a> based on the [coding club guidelines](Tutorial_publishing_guide.md) and existing tutorials as a guide. Are there any pre-requisites to completing your tutorial? You can add links to previous tutorials, so that people can complete them first, and then come back to your tutorial. It's nice to have in text references to previous tutorials with links to them, as that way more people can find out about them.

6. Upload any images to a `plots` folder within your tutorial.

9. Create a pull-request for your branch to be merged with the master branch. 

<a name="style"></a>

## Style Guide

### Header Material

This material should appear at the top of every tutorial `.md` file. The `title:` is the full name of your tutorial and `subtitle:` should be the short hand that appears on the github repository

Here is an example header:

```
---
title: "Title to appear on website"
subtitle: "Subtitle to appear on website"
author: "First name of Author"
date: "2017-04-25 08:00:00"
---
<div class="block">
	<center>
		<img src="{{ site.baseurl }}/img/tutheader_tutname.png" alt="Img">
	</center>
</div>
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

Please format all tables using html, not markdown, using the following style info. Each `<tr>` block represents one row, with each `<th>` block representing one column. <a href="http://www.tablesgenerator.com/html_tables" target="_blank">http://www.tablesgenerator.com/html_tables</a> is a decent html table generator if you can't be bothered typing this out manually:

```
<style type="text/css">
.tg  {border-collapse:collapse;border-spacing:0;}
.tg th{font-family:Arial;font-weight:normal;padding:10px 5px;border-style:solid;border-width:1px;word-break:normal;}
</style>
<table class="tg">
  <tr>
    <th>Name</th>
    <th>Code</th>
    <th>Example</th>
  </tr>
  <tr>
    <th>1</th>
    <th>2</th>
    <th>3</th>
  </tr>
</table>
```

### Lists

Bullet point lists should be formatted as headers. This is because our jekyll template doesn't deal well with markdown formatted lists. Lists should look like this:

```
##### - List item 1
##### - List item 2
##### - List item 3
```

### Shiny apps and other embedded material
Shiny apps and other similar embeddable material can be placed in an `iframe`, adjusting the height and width as needed to make it look sensible. Avoid making the user scroll through the app if possible by adjusting the height and width:

```
<iframe src="EMBEDDABLE_URL" style="border:none; width:1000px; height:550px;"></iframe>
```

### Web Links

Please format all hyperlinks using html, not markdown, in the following format. `target="_blank"` forces web browsers to open the link in a new tab:

```
<a href="FULL_LINK" target="_blank">DESCRIPTION OF LINK TO APPEAR AS TEXT</a>

```

### Image Links

Please format all image links using html, not markdown, in the following format. Adjust the `width:` argument so the image is sensibly sized. Normally nothing over 1000 pixels:

```
<center> <img src="{{ site.baseurl }}/img/IMAGE_NAME.png" alt="Img" style="width: 800px;"/> </center>
```

### Footer Material

This material should be added to the end of every tutorial. Replace `INSERT_SURVEY_LINK` with the actual URL to a Survey Monkey survey created using the Coding Club account (you can get in touch with Gergana for the password). The top lines of this section can be used to list acknowledgements and important links.


```
<hr>
<hr>

<h3><a href="SURVEY_MONKEY_LINK" target="_blank">&nbsp; We would love to hear your feedback, please fill out our survey!</a></h3>
<br>
<h3>&nbsp; You can contact us with any questions on <a href="mailto:ourcodingclub@gmail.com?Subject=Tutorial%20question" target = "_top">ourcodingclub@gmail.com</a></h3>
<br>
<h3>&nbsp; Related tutorials:</h3>
{% for post in site.posts %}
	{% if post.url != page.url %}
  		{% for tag in post.tags %}
    			{% if page.tags contains tag %}
<h4><a style="margin:0 padding:0" href="{{ post.url }}">&nbsp; - {{ post.title }}</a></h4>
  			{% endif %}
		{% endfor %}
	{% endif %}
{% endfor %}
<br>
<h3>&nbsp; Subscribe to our mailing list:</h3>
<div class="container">
	<div class="block">
        <!-- subscribe form start -->
		<div class="form-group">
			<form action="https://getsimpleform.com/messages?form_api_token=de1ba2f2f947822946fb6e835437ec78" method="post">
			<div class="form-group">
				<input type='text' class="form-control" name='Email' placeholder="Email" required/>
			</div>
			<div>
                        	<button class="btn btn-default" type='submit'>Subscribe</button>
                    	</div>
                	</form>
		</div>
	</div>
</div>

<ul class="social-icons">
	<li>
		<h3>
			<a href="https://twitter.com/our_codingclub" target="_blank">&nbsp;Follow our coding adventures on Twitter! <i class="fa fa-twitter"></i></a>
		</h3>
	</li>
</ul>
```

### General stylistic points

Bold text can be used to draw attention to an important action point using `__`, but don't overdo it:

```
__Copy and paste the code below into your script:__
```

<a name="work_html"></a>

## Adding a tutorial to `work.html`

In `work.html` you should find a series of repeated blocks of code, each denoting a tutorial listed on the website. Add your own tutorial by first looking for this sequence of html tags:

```html
			</div>
		</div>
	</a>
</li>
```

then add the code below after that set of html tags: 

```html
<li class="mix Rbasics Markdown">  
     <a href="https://ourcodingclub.github.io/2017/01/16/piping.html">
           <img src="{{ site.baseurl }}/img/portfolio/work1.jpg" alt="">
                 <div class="overly">
                      <div class="position-center">
                            <h2>Your tutorial title</h2>
                            <p>Your tutorial subtitle</p>
                       </div>
                  </div>
       </a>
</li>
```

Change `<li class="mix Rbasics Markdown">` to reflect the categories you want the tutorial to be featured in. Categories include `Rbasics`, `Github`, `Dataform` (Data formatting), `Datavis` (Data visualisation), `Modelling`, `Markdown`, and Shiny. Remember not to add any commas between categories and keep `mix` in the code.

Change `<a href="https://ourcodingclub.github.io/2017/01/16/piping.html">` to reflect the name of your own tutorial, changing the date and tutorial name to match that of your `.md` file.

Change the thumbnail image for your tutorial (`<img src="{{ site.baseurl }}/img/portfolio/work1.jpg" alt="">`). You can choose one of the already uploaded ones (navigate to the img/portfolio folder to view them and change the file name according to the one you want), or you can also upload your own in the portfolio folder.

Change `<h2>Your tutorial title</h2>` to mirror the title of your tutorial.
 
Change `<p>Your tutorial subtitle</p>` to mirror the subtitle of your tutorial.

<a name="readme"></a>

## Creating a `README.md` for your tutorial resources repository on github

Below is an example `README.md` that you can use to make your own.

```
Using R to produce map figures and display spatial data

This repository contains the files necessary to complete the Coding Club Maps tutorial - you can check it out at:
https://ourcodingclub.github.io/2016/11/25/maps_tutorial.html

The bird data (`Gyps_rueppellii_GBIF.csv`) were downloaded from the Global Biodiversity Information Facility (GBIF) https://gbif.org

`ggmap_Cheatsheet.pdf` was downloaded from the National Centre for Ecological Analysis and Synthesis (NCEAS)
https://www.nceas.ucsb.edu/~frazier/RSpatialGuides/

For more Coding Club tutorials and resources, please see 
https://ourcodingclub.github.io/
