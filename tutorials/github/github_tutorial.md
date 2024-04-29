## GitHub tutorial

By: Nathan Byer and Mason Fidino

In this tutorial, we will go over some basics of how to use GitHub. Throughout, we will focus on the use of GitHub Desktop Graphical User Interface (GUI) for repository management, but just remember - **this is just one of a few approaches you can use!** Here are a few notes on this before we proceed:

1. RStudio has native GitHub integration. It can be a bit limited in functionality, but can be useful for R-based repository management. 
2. Git has robust command-line utilities, some of which may be needed for more advanced repository management. It is also exhaustively documented elsewhere.

With these caveats in mind, let's get started with GitHub!

### Creating a GitHub account

Before using GitHub, there's a pretty important initial step: **you need to sign up for a GitHub account!** If you have already done this, feel free to proceed to the next section.

First, navigate to github.com. You should see the following:

<div align="center">
<img src="./images/github-signup.png" width=90%/>
</div>

Go ahead and enter your email in the box we have outlined in red, and proceed with any instructions necessary. You will be prompted to create a username and password, so make sure you remember what those are!

Now that you have an account, when you navigate to github.com, you should see the following:

<div align="center">
<img src="./images/github-dashboard.png" width=90%/>
</div>


This is your *dashboard*. We won't go into a ton of detail about this, but your recently used repositories should be displayed on the left (outlined in a green box), whereas a feed of repository-related activity for your collaborators will be displayed in the center (outlined in a blue box). 

### Creating a GitHub Repository

In the previous image, you likely noticed the little green button that says"New". Go ahead and click on that - to create your first github repository!

You should see something that looks like this:

<div align="center">
<img src="./images/github-new-repo-1.png" width=90%/>
</div>


As you can see in this image, fill in a name (I suggested one related to this tutorial, but it doesn't really matter!). Then, go ahead and click "add read me" - we will describe that a bit further below.

Towards the bottom of this page, you should see a few other options:

<div align="center">
<img src="./images/github-new-repo-2.png" width=90%/>
</div>


The .gitignore allows you to tell github *not* to track certain files in local repository folders, which can be useful. 

Note that you can also set a license for your repository! These outline usage rights, limitations, and terms for your repository.

You can safely ignore those for now, but just be aware of these for future repositories. For now, go ahead and click the green "create repository" button at the bottom to proceed.

#### Don't forget the Read Me!



### Cloning a repository

### Your first commit!

### Tracking file edits

### Managing repositories

Managing a repository can range from simple to complex, and typically depends on two things. First, the number of users contributing to a project can increase complexity. In the simplest case, a single user may be pushing commits to the main branch of a private repository. When this happens, you may not need to put many rules in place to avoid issues using GitHub. With multiple users, however, it is helpful to put some rules in place so that everyone is aware of how to contribute. This could include using branches to develop parts of the code base, conducting code reviews for pull requests, and taking some time to provide documentation on how to contribute. Second, the 'product' you are working on can influence how you manage your repository. If your repository is meant to house some data and code for an analysis, then you may not worry as much about best practices so long as the code runs. If your repository is meant to house a website, a shiny app, or something else people may use without running code, then you may want to ensure you have protections in place to decrease the chances of breaking your 'product.'

In our experience, GitHub management for ecologists is often quite simple as most
research projects typically revolve around either one or a small number of people doing the data analysis. Regardless, even when working on our own projects we often still use a lot of GitHub's features as it is easier. In the section below we'll cover how to use a number of GitHub's features via the GitHub Desktop GUI.


#### Creating and using branches

As a reminder, branches are contained copies of your repository where you can 
safely create new features, fix bugs, or even try out new ideas for a project.
There are no limits to how many branches you can make, and branches can be made
off of any other branch (e.g., a branch off a branch off a branch). For a small
team of collaborators, branches will be by far the easiest way to collaborate on a project. You can add people as collaborators to a repository on it's settings page, which can be accessed via an Internet browser. 

To view your branches on the GitHub GUI you simply need
to select the correct repository and then click the current branch dropdown. For
example, while working on this tutorial Nate and I generated a `github-workshop`
branch off of the main branch of the `UWIN_tutorials` repository.

<div align="center">
<img src="./images/branch-selection.png" width=90%/>
</div>

Creating a new branch with the GitHub GUI is easy. After clicking on the dropdown, type the name of the new branch in the associated text field and click on the "Create new branch" button. Let's do that now. Create a new branch titled `my first branch`. After clicking this button a pop-up will appear and you may notice two things:

1. That the created branch is hyphen-separated. GitHub branches cannot have spaces
and so the GitHub GUI will replace all spaces with hyphens. 
2. You need to decide what to branch off of if you already have multiple branches. In the event that you have no other branches, then you will branch from the `main` branch. If you have more than one branch, you will need to select which branch you are branching from. 

Confirm the creation of your branch by clicking on the `Create branch` pop-up.

Creating branches is easiest when you have already pushed all your commits to your
repository and your local copy is caught up with your repository. However, when working on a project you may have some non-committed changes to the code and you realize you are either not on the correct
branch or you should make a new branch to store these edits. You will notice if you have edits that are not committed in the GitHub GUI as it shows changes
you have made to a script by highlighting them in either green or red. Green highlights are new code and red highlights are code that has been removed. So, what do you do in these situations?

Fortunately, if you either try to switch branches or create a new branch with uncommitted code the GitHub GUI will ask you whether you want to either:

1. Leave those changes on the current branch.
2. Bring those changes over to either the new branch you may be creating.
3. Bring those changes over to the another branch that already exists.


If needed, branches can be renamed. Likewise, branches can be deleted. Typically,
we delete branches after merging them into the main branch. For example, if your branch was made to create a new R function for your analysis, then you won't need
that branch anymore after the function is available in the main branch. There are
times when you may not want to delete a branch. For example, lots of repositories will have a `dev` branch that must be merged into first. After testing, changes made to the `dev` branch can then be pushed into the `main` branch with a pull request. You will not likely encounter this often when using GitHub for your analysis, but we bring it up here for completeness.

#### Forking repositories



#### Pull requests

#### What are conflicts?

Conflicts occur when Git cannot resolve code differences between multiple commits. You are typically alerted to this issue 
