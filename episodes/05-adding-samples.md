---
title: 'Adding a new sample to a workflow'
teaching: 15
exercises: 45
---


:::::::::::::::::::::::::::::::::::::: questions

- How is a new *A. fumigatus* isolate added to an existing genomic analysis?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Add a new sample to the workflow input table or configuration. 
- Run the prepared workflow target or inspect the prepared output. 
- Compare the “before” and “after” results. 
- Decide whether the new isolate changes the interpretation. 

::::::::::::::::::::::::::::::::::::::::::::::::

## Introduction

##  Practical

# inspect files
ls

# inspect the sample sheet
less config/samples.tsv

# run the prepared target
snakemake --use-conda --cores 2 [TARGET_NAME]
If the actual command is not final, leave it as [TARGET_NAME] in the lesson draft. Do not invent target names.

::::::::::::::::::::::::::::::::::::: keypoints

- Adding a sample should be a controlled change to the sample sheet or configuration. 
- A reproducible workflow should only rerun the steps affected by the new input. 
- Interpretation focuses on how the new sample changes the result, not on the command itself. 

::::::::::::::::::::::::::::::::::::::::::::::::



