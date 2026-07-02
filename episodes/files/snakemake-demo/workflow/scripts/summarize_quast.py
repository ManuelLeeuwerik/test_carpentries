"""Combine per-sample QUAST report.tsv files into a single summary table.

Called from rules/quast.smk via the `script:` directive. Snakemake injects a
`snakemake` object into this script's namespace with `.input`, `.output` and
`.log` already resolved to the paths declared in the rule, so no argument
parsing is needed here -- this is the main advantage of `script:` over
`shell:` for anything more involved than a one-liner.
"""
import sys

import pandas as pd

sys.stderr = open(snakemake.log[0], "w")

tables = []
for report_path in snakemake.input:
    sample = report_path.split("/")[-2]
    df = pd.read_csv(report_path, sep="\t", index_col=0)
    df = df.rename(columns={df.columns[0]: sample})
    tables.append(df)

summary = pd.concat(tables, axis=1)
summary.to_csv(snakemake.output[0], sep="\t")
