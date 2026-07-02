# snakemake-demo

A small, self-contained workflow used to teach the basics of Snakemake:

    fastp -> FastQC -> SPAdes -> QUAST

It exists purely as a teaching example, showcased alongside the naive bash
equivalent in `scripts/run_pipeline_bash_demo.sh`. It is a complete, working
workflow: given real paired-end reads in `resources/reads/` and Conda/Mamba
installed, it can be run end to end with:

```bash
snakemake --snakefile workflow/Snakefile --cores 10 --use-conda -n   # dry run
snakemake --snakefile workflow/Snakefile --cores 10 --use-conda      # real run
```

## Layout

```text
├── .gitignore
├── README.md
├── LICENSE.md
├── workflow
│   ├── rules          # one .smk module per pipeline stage
│   ├── envs            # one Conda environment per rule/tool
│   ├── scripts          # helper scripts invoked via the script: directive
│   └── Snakefile
├── config
│   └── config.yaml      # samples + tool parameters, no code
├── results               # created on first run
└── resources
    └── reads             # input FASTQ files go here
```

## Configuration

Samples and tool parameters are defined in `config/config.yaml`. Add or
remove samples there; nothing in `workflow/` needs to change.
