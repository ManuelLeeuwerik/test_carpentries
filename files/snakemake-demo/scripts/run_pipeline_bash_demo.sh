#!/usr/bin/env bash
# Naive bash version of: fastp -> FastQC -> SPAdes -> QUAST
#
# This is the "before" picture for the Snakemake showcase episode. Every
# sample is handled by hand, every path is spelled out again for every tool,
# and the script has no way of knowing which steps are already done.
set -euo pipefail

mkdir -p results/trimmed results/qc_reports results/assembly results/quast logs

for sample in sample1 sample2; do

    echo ">>> Trimming ${sample}"
    fastp \
        -i resources/reads/${sample}_R1.fastq.gz \
        -I resources/reads/${sample}_R2.fastq.gz \
        -o results/trimmed/${sample}_R1.fastq.gz \
        -O results/trimmed/${sample}_R2.fastq.gz \
        --adapter_sequence AGATCGGAAGAGC \
        2> logs/${sample}_fastp.log

    echo ">>> QC on ${sample}"
    fastqc \
        results/trimmed/${sample}_R1.fastq.gz \
        results/trimmed/${sample}_R2.fastq.gz \
        -o results/qc_reports/ \
        2> logs/${sample}_fastqc.log

    echo ">>> Assembling ${sample}"
    spades.py \
        -1 results/trimmed/${sample}_R1.fastq.gz \
        -2 results/trimmed/${sample}_R2.fastq.gz \
        -t 8 -k 21,33,55,77,99,121 \
        -o results/assembly/${sample} \
        2> logs/${sample}_spades.log

    echo ">>> Evaluating assembly for ${sample}"
    quast.py \
        results/assembly/${sample}/contigs.fasta \
        -o results/quast/${sample} \
        --fungus --min-contig 500 --min-identity 95.0 \
        --threads 4 \
        > logs/${sample}_quast.log 2>&1

done

# If we now add sample3, or fastp already finished for sample1 and only
# sample2 changed, this script has no way of knowing that. It reruns every
# tool, for every sample, every single time -- that gap is exactly what the
# Snakemake version in workflow/Snakefile is built to close.
