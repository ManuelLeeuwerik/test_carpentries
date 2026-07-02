---
title: 'Reproducible workflows with Snakemake'
teaching: 20
exercises: 0
---


:::::::::::::::::::::::::::::::::::::: questions

- What is Snakemake?
- What are the advantages of Snakemake?
- What does a Snakemake workflow do that a series of individual commands does not?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Explain the purpose of a reproducible workflow. 
- Identify the role of a configuration file, rules, inputs, outputs, and logs. 
- Run or inspect a prepared Snakemake workflow without needing to understand every rule. 

::::::::::::::::::::::::::::::::::::::::::::::::

## Introduction
A "workflow"/"pipeline" is just individual steps (QC → trim → assemble) wired together so they always run in the same order on any new sample.
Explain what a "workflow" is

# Could use/implement parts of the bioinformatics Snakemake presentation!

## Practical
Learners inspect the prepared workflow folder:
config/
data/
resources/
results/
workflow/
logs/

They then identify:
- Where samples are listed
- Where reference files are defined
- Where outputs appear
- Where logs are stored


::::::::::::::::::::::::::::::::::::: keypoints

- A workflow formalises an analysis so the same steps are applied consistently. 
- Configuration files and sample sheets separate user choices from workflow code. 

::::::::::::::::::::::::::::::::::::::::::::::::


