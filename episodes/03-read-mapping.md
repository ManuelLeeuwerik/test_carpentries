---
title: 'Read mapping and variant calling'
teaching: 40
exercises: 0
---


:::::::::::::::::::::::::::::::::::::: questions

- How do sequencing reads become a list of genomic differences?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Explain read mapping as alignment of sequencing reads to a reference genome. 
- Define a SNP and an indel in relation to a reference. 
- Recognise the purpose of BAM, BAI, and VCF files. 
- Explain why quality filtering matters before interpreting variants. 

::::::::::::::::::::::::::::::::::::::::::::::::

## Introduction
Flow
1.	Reads are aligned to the reference genome. 
2.	The workflow records those alignments in a BAM file. 
3.	The variant caller identifies positions where the sample differs from the reference. 
4.	Variants are written to a VCF file. 
5.	The VCF becomes input for annotation, resistance screening, or SNP-tree construction. 


## Practical

Learners inspect, an example VCF. Keep this conceptual:
CHROM   POS     REF     ALT     QUAL    FILTER

Potential questions?
- What chromosome or contig is the variant on? 
- What is the reference base? 
- What is the alternate base? 
- Did the variant pass filtering? 
- Why might a low-quality variant be misleading? 



::::::::::::::::::::::::::::::::::::: keypoints

- Mapping is the step that places reads in genomic context. 
- Variant calling converts read evidence into candidate differences from the reference. 
- A VCF is not automatically a list of biologically meaningful mutations. 

::::::::::::::::::::::::::::::::::::::::::::::::



