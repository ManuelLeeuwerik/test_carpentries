rule quast:
    """Evaluate each assembly with QUAST."""
    input:
        fasta="results/assembly/{sample}/contigs.fasta",
    output:
        report_pdf="results/quast/{sample}/report.pdf",
        report_tsv="results/quast/{sample}/report.tsv",
    params:
        outdir="results/quast/{sample}",
        min_contig=config["quast_min_contig"],
        min_identity=config["quast_min_identity"],
    log:
        "logs/quast/{sample}.log",
    conda:
        "../envs/quast.yaml"
    threads: 4
    shell:
        """
        quast.py {input.fasta} \
            -o {params.outdir} \
            --fungus \
            --min-contig {params.min_contig} \
            --min-identity {params.min_identity} \
            --threads {threads} \
            > {log} 2>&1
        """


rule summarize_quast:
    """Collect every per-sample QUAST report into one summary table."""
    input:
        expand("results/quast/{sample}/report.tsv", sample=SAMPLES),
    output:
        "results/quast/summary.tsv",
    log:
        "logs/quast/summarize.log",
    conda:
        "../envs/quast.yaml"
    script:
        "../scripts/summarize_quast.py"
