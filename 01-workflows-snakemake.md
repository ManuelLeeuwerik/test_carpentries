---
title: 'Reproducible workflows with Snakemake'
teaching: 20
exercises: 10
---

:::::::::::::::::::::::::::::::::::::: questions

- What is Snakemake, and what problem does it solve?
- What does a Snakemake workflow do that a series of individual commands does not?
- What are the roles of a configuration file, rules, inputs, outputs, and logs?
- How do you read a Snakemake workflow without needing to run it?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Explain the purpose of a reproducible workflow.
- Compare a naive bash pipeline with the same pipeline written in Snakemake.
- Identify the role of a configuration file, rules, inputs, outputs, and logs.
- Recognise the standard folder structure of a Snakemake workflow.
- Read a prepared Snakemake workflow and predict what it will do, without running it.

::::::::::::::::::::::::::::::::::::::::::::::::

## Introduction

A workflow, or pipeline, is a set of individual steps like: QC, trimming, assembly,
and plotting, wired together so that they always run in the same order, on any
new sample, with the same parameters. You have already run each of these
steps by hand, one command at a time, in earlier sessions with FastQC, fastp,
SPAdes, and QUAST. This episode looks at what changes when those same four
tools are wired together as a [**Snakemake workflow**](https://snakemake.readthedocs.io/) instead.

We will not run anything in this episode. The goal is to become comfortable
reading a Snakemake workflow: recognising its folder structure, following how
one rule's output becomes another rule's input, and knowing where to look for
samples, parameters, results, and logs. The next episode uses a real,
production workflow built the same way.

![snakemake_logo](fig/snakemake_logo.png)

## The same pipeline, twice

Here is a naive bash version of the pipeline you already know, running
FastQC, fastp, SPAdes, and QUAST for two samples:

```bash
for sample in sample1 sample2; do

    fastp \
        -i resources/reads/${sample}_R1.fastq.gz \
        -I resources/reads/${sample}_R2.fastq.gz \
        -o results/trimmed/${sample}_R1.fastq.gz \
        -O results/trimmed/${sample}_R2.fastq.gz \
        --adapter_sequence AGATCGGAAGAGC

    fastqc \
        results/trimmed/${sample}_R1.fastq.gz \
        results/trimmed/${sample}_R2.fastq.gz \
        -o results/qc_reports/

    spades.py \
        -1 results/trimmed/${sample}_R1.fastq.gz \
        -2 results/trimmed/${sample}_R2.fastq.gz \
        -t 8 -k 21,33,55,77,99,121 \
        -o results/assembly/${sample}

    quast.py \
        results/assembly/${sample}/contigs.fasta \
        -o results/quast/${sample} \
        --fungus --min-contig 500 --min-identity 95.0 \
        --threads 4

done
```

This works, but it has a few problems that get worse as a project grows:

- Every path is spelled out again for every tool, for every sample.
- If `sample1` already finished and only `sample2` changed, the script has no
  way of knowing that, it reruns everything, every time.
- Adding a third sample means editing the loop, or the whole file.
- There is no record of which exact command and parameters produced a given
  output file, beyond scrolling back through the terminal.
- Does not run jobs in parallel.

Here is the same pipeline as a Snakemake rule, taken from this episode's demo
workflow:

```python
rule fastp_trim:
    input:
        forward=lambda wildcards: config["samples"][wildcards.sample][0],
        rev=lambda wildcards: config["samples"][wildcards.sample][1],
    output:
        forward_trimmed=temp("results/trimmed/{sample}_R1.fastq.gz"),
        rev_trimmed=temp("results/trimmed/{sample}_R2.fastq.gz"),
    params:
        adapter=config["adapter_sequence"],
    log:
        "logs/fastp/{sample}.log",
    conda:
        "envs/trimming.yaml"
    threads: 4
    shell:
        """
        fastp -i {input.forward} -I {input.rev} \
            -o {output.forward_trimmed} -O {output.rev_trimmed} \
            --adapter_sequence {params.adapter} \
            --thread {threads} \
            2> {log}
        """
```

The `{sample}` in the input and output paths is a **wildcard**. Snakemake
fills it in for every sample it needs to produce, so this one rule replaces
one iteration of the bash loop above, for as many samples as the
configuration lists, without editing the rule itself.

::::::::::::::::::::::::::::::::::::: callout

## What Snakemake adds

- **Dependency tracking**: Snakemake only reruns a step if its inputs, its
  parameters, or the rule itself have changed since the last run.
- **One place per concern**: sample names and parameters live in a
  configuration file, not scattered through shell commands.
- **Isolated software environments**: each rule can declare exactly which
  Conda environment it needs. Snakemake tracks changes to environments and downloads it automatically if not already installed.
- **A log per job**: every rule writes to its own log file, instead of
  everything landing in one terminal scrollback.
- **A single command to describe or run the whole pipeline**, for one sample
  or for a hundred.

::::::::::::::::::::::::::::::::::::::::::::::::

## Anatomy of a Snakemake workflow

Snakemake workflows tend to follow a standard folder structure:

```text
├── .gitignore
├── README.md
├── LICENSE.md
├── workflow
│   ├── rules
│   │   ├── trimming.smk
│   │   ├── qc.smk
│   │   ├── assembly.smk
│   │   └── quast.smk
│   ├── envs
│   │   ├── trimming.yaml
│   │   ├── fastqc.yaml
│   │   ├── genomics.yaml
│   │   └── quast.yaml
│   ├── scripts
│   │   └── summarize_quast.py
│   └── Snakefile
├── config
│   └── config.yaml
├── results
└── resources
```

- **`workflow/Snakefile`** is the entry point. It loads the configuration
  file, works out the sample names, includes the rule modules, and defines
  the final targets in a rule usually called `all`.
- **`workflow/rules/*.smk`** each hold one or a few related rules, so a large
  workflow does not become one very long file. The snakefile imports the rule file with `include: "rules/quast.smk"`.
- **`workflow/envs/*.yaml`** are Conda environment files, one per rule (or
  per tool). Snakemake creates and activates the right one automatically when
  a rule runs with `--use-conda`.
- **`workflow/scripts/`** holds helper scripts, called from a rule with a
  `script:` directive instead of `shell:`, for logic that is easier to write
  in Python or R than in a shell command.
- **`config/config.yaml`** lists the samples and the tool parameters. This is
  the only file you usually need to edit to run the workflow on new data.
- **`results/`** and **`logs/`** are created by the workflow itself and are
  not committed to version control.

This is the basic structure. Larger workflows add more execution profiles,
notebooks and report templates but everything you need to read a workflow is
already here.

## Reading a rule

Every rule follows the same pattern: **input -> process -> output**, plus a
few optional (but recommended) pieces to help with logging, environments, and resources.

```python
rule fastqc:
    input:
        forward="results/trimmed/{sample}_R1.fastq.gz",
        rev="results/trimmed/{sample}_R2.fastq.gz",
    output:
        "results/qc_reports/{sample}_R1_fastqc.html",
        "results/qc_reports/{sample}_R2_fastqc.html",
    log:
        "logs/fastqc/{sample}.log",
    conda:
        "envs/fastqc.yaml"
    threads: 2
    shell:
        """
        fastqc {input.forward} {input.rev} -o results/qc_reports/ -t {threads} 2> {log}
        """
```

A few things worth noticing:

- **`input`** names the files the rule needs. Snakemake automatically works
  out that these files are produced by `rule fastp_trim`, and runs that rule
  first if its outputs do not exist yet.
- **`output`** names the files the rule creates. If they already exist and
  are newer than the inputs, Snakemake skips the rule.
- **`log`** is a dedicated file for that job's messages, separate from every
  other sample and every other rule.
- **`conda`** points to an environment file, so `fastqc` does not need to be
  installed system-wide only listed in `envs/fastqc.yaml`.
- **`threads`** tells Snakemake how many CPU threads this job may use, which
  it uses together with `--cores` to decide how many jobs can run at once.

::::::::::::::::::::::::::::::::::::: callout

## Temporary files

The trimmed FASTQ files produced by `fastp_trim` are wrapped in `temp(...)`:

```python
output:
    forward_trimmed=temp("results/trimmed/{sample}_R1.fastq.gz"),
```

This tells Snakemake that once every rule that needs a file has used it, the
file can be deleted automatically. It keeps large intermediate files, like
trimmed reads, from filling up disk space once the assembly step that needs
them has finished.

::::::::::::::::::::::::::::::::::::::::::::::::

## From per-sample rules to one target

The `rule all` at the top of the Snakefile lists every final file the
workflow should produce, generated for every sample with `expand`:

```python
rule all:
    input:
        expand("results/qc_reports/{sample}_R1_fastqc.html", sample=SAMPLES),
        expand("results/qc_reports/{sample}_R2_fastqc.html", sample=SAMPLES),
        expand("results/quast/{sample}/report.pdf", sample=SAMPLES),
        "results/quast/summary.tsv",
```

`expand(...)` fills the `{sample}` wildcard with every entry in `SAMPLES`, so
this one line stands in for one filename per sample. `SAMPLES` itself is read
from the configuration file:

```python
configfile: "config/config.yaml"

SAMPLES = list(config["samples"].keys())
```

Add a third sample to `config/config.yaml` and every rule, and `rule all`,
apply to it automatically, nothing in `workflow/` needs to change.

## From rules to a script

Not every step fits comfortably in a single shell command. The final rule in
this workflow collects every sample's QUAST report into one summary table,
using a Python script instead of `shell:`:

```python
rule summarize_quast:
    input:
        expand("results/quast/{sample}/report.tsv", sample=SAMPLES),
    output:
        "results/quast/summary.tsv",
    log:
        "logs/quast/summarize.log",
    conda:
        "envs/quast.yaml"
    script:
        "../scripts/summarize_quast.py"
```

Snakemake makes a `snakemake` object available inside `summarize_quast.py`,
with `.input`, `.output`, and `.log` already filled in from the rule, so
the script does not need any argument parsing of its own.

## Inspecting the workflow without running it

It is common to start with a **dry run**: asking Snakemake what it would do,
without executing anything.

```bash
snakemake --snakefile workflow/Snakefile --cores 10 --use-conda -n
```

A dry run prints the full list of jobs Snakemake would run, in dependency
order, along with the reason each job is needed, missing output, or an
input file that is newer than its output. This is exactly how we inspected
this episode's demo workflow while preparing it, and it is good practice
before running any workflow on new data, even once you trust it.

::::::::::::::::::::::::::::::::::::: challenge

## Challenge 1: Read the workflow

Without running anything, open `config/config.yaml` and the files under
`workflow/rules/`.

1. Where are the samples for this workflow listed?
2. Which rule produces the input files that `rule spades_assembly` needs?
3. Where would you look for the fastp log for `sample2`?
4. If you added a `sample3` entry to `config/config.yaml`, which files listed
   in `rule all` would Snakemake need to create for it?

:::::::::::::::::::::::: solution

## Expected reasoning

1. Samples are listed under `samples:` in `config/config.yaml`, as a sample
   name mapped to a pair of FASTQ paths.
2. `rule fastp_trim`, in `workflow/rules/trimming.smk`, produces the trimmed
   FASTQ files that `rule spades_assembly` takes as input.
3. At `logs/fastp/sample2.log`, matching the `log:` path declared in
   `rule fastp_trim` with `{sample}` filled in as `sample2`.
4. All of them, for `sample3`: `results/qc_reports/sample3_R1_fastqc.html`,
   `results/qc_reports/sample3_R2_fastqc.html`, and
   `results/quast/sample3/report.pdf`, plus an updated
   `results/quast/summary.tsv`. `rule all` uses `expand(..., sample=SAMPLES)`,
   and `SAMPLES` is read directly from the configuration file, so a new
   sample is picked up automatically.

:::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::


## Coming up next

The next episode moves from this small demonstration to a real, actively
used workflow: **snakemake-mlsa-ani**, for multilocus sequence analysis and
average nucleotide identity estimation from fungal genome assemblies. It
follows exactly the structure introduced here  a `Snakefile`, rule modules,
Conda environments, and a `config/config.yaml` and you will use what you
practised in this episode to read it, inspect its outputs, and interpret its
results.

::::::::::::::::::::::::::::::::::::: keypoints

- A workflow formalises an analysis so the same steps are applied
  consistently to every sample.
- Configuration files and sample sheets separate user choices from workflow
  code.
- Each rule declares its inputs, outputs, log file, software environment, and
  thread count; Snakemake works out execution order from how these connect.
- Wildcards and `expand()` let one rule apply to every sample, without
  repeating code.
- `temp()` marks intermediate files for automatic cleanup once they are no
  longer needed.
- A dry run (`-n`) shows what a workflow would do without running anything.

::::::::::::::::::::::::::::::::::::::::::::::::
