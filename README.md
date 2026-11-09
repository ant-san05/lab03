# Lab 3: Mixed Integer Programming and Facility Siting in JuMP

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This is the repository for Lab 3 for [BEE 4750](https://viveks.me/environmental-systems-analysis), taught at [Cornell University](https://cornell.edu) in Fall 2026 by [Vivek Srikrishnan](https://viveks.me).

If enrolled in the class, your completed Activity Sheet should be submitted to Gradescope as a PDF by 9:00pm on Wednesday, November 11 (see `lab03.qmd`/`lab03.ipynb`); you don't need to submit your code. 10% will be deducted for each day the submission is late.

**Before the lab**, clone this repository and run the two Setup cells at the top of the notebook (or the first lines of `lab03.jl`). The first time, installing and loading `JuMP` and `HiGHS` can take a few minutes, which is better spent before class than during it.

## Learning Objectives

After completing this lab, students will be able to:

- implement a facility-siting model with indicator variables, fixed costs, and linking constraints in `JuMP`, from a given formulation;
- explain the solution of a mixed integer linear program as a trade-off between the fixed costs it saves and the transport costs it adds;
- add a logical constraint on indicator variables and measure what it costs;
- find the shadow prices of a mixed integer linear program with its indicator variables fixed, and explain why they do not measure the cost of building or closing a site.

## Repository Overview

The repository consists of the following files:

- `lab03.ipynb`: Jupyter Notebook version of the assignment. Students who prefer notebooks should create code or Markdown blocks as necessary to answer questions.
- `lab03.jl`: plain Julia script version of the same coding steps, for students who prefer working in a script instead of a notebook, with the same steps and structure as the notebook.
- `lab03.pdf`: the lab as a PDF, for reading.
- `Project.toml`, `Manifest.toml`: Julia environment files. These should just work, but feel free to add other packages as needed using the `Pkg` package manager.
- `lab03.qmd`: Source file for notebook generation. You shouldn't need to touch this.
- `activity-sheet.qmd`: Source file for the Activity Sheet PDF. You shouldn't need to touch this. The Activity Sheet is handed out in class.
- `LICENSE`: This material is licensed using the MIT license. You can ignore this for working on the problem set.
- `README.md`: This file. You shouldn't need to touch this.
- `.gitignore`: This tells `git` what files to ignore. You shouldn't need to touch this.

## Dependencies

This lab uses the following packages:

- `JuMP.jl` (optimization modeling syntax)
- `HiGHS.jl` (the solver, for linear programs and mixed integer linear programs)
- `IJulia.jl` (the Julia kernel for Jupyter notebooks; no code loads it, but the notebook needs it)

## Prerequisites

1. [Install Julia](https://julialang.org/downloads/) before beginning this lab. This notebook was developed with version 1.11.5, but any 1.11.x should work (there could be some issues with other versions, depending on what's changed).
2. If necessary, [install git](https://happygitwithr.com/install-git.html) and [create a GitHub account](https://github.com).
