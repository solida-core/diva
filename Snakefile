import pandas as pd
from snakemake.utils import validate, min_version
##### set minimum snakemake version #####
min_version("5.10.0")


##### load config and sample sheets #####
#configfile: "config.yaml"

## USER FILES ##
samples = pd.read_csv(config["samples"], index_col="sample", sep="\t")
units = pd.read_csv(config["units"], index_col=["unit"], dtype=str, sep="\t")
sets = pd.read_csv(config["sets"], index_col=["set"], dtype=str, sep="\t")
reheader = pd.read_csv(config["reheader"],index_col="Client", dtype=str, sep="\t")
reheader = reheader[reheader["LIMS"].isin(samples.index.values)]

## ---------- ##

##### local rules #####
include:
    "rules/functions.py"

localrules: all, pre_rename_fastq_pe, post_rename_fastq_pe, vcf_to_tabular

rule all:
    input:
#        expand("reads/recalibrated/{sample.sample}.dedup.recal.bam", sample=samples.reset_index().itertuples()),
#        expand("reads/recalibrated/{sample.sample}.dedup.recal.hs.txt",sample=samples.reset_index().itertuples()),
#        expand("reads/recalibrated/{sample.sample}.ccds.dedup.recal.hs.txt",sample=samples.reset_index().itertuples()),
        "qc/multiqc.html",
        "qc/kinship/multiqc_heatmap.html",
#        "qc/bedtools/heatmap_enriched_regions.png",
#        expand("variant_calling/{sample.sample}.g.vcf.gz",sample=samples.reset_index().itertuples()),
#        "db/imports/check",
#        "variant_calling/all.vcf.gz",
#        "variant_calling/all.snp_recalibrated.indel_recalibrated.vcf.gz",
        expand("annotation/{set.set}/bcftools/selected.annot.lightened.reheaded.xlsx", set=sets.reset_index().itertuples()),
        expand("annotation/{set.set}/kggseq/doubleHits.doublehit.gene.trios.flt.gty.xlsx", set=sets.reset_index().itertuples()),
         "delivery.completed"




include_prefix="rules"
dima_path="dima/"

include:
    dima_path + include_prefix + "/trimming.smk"
include:
    dima_path + include_prefix + "/alignment.smk"
include:
    dima_path + include_prefix + "/samtools.smk"
include:
    dima_path + include_prefix + "/picard.smk"
include:
    dima_path + include_prefix + "/bsqr.smk"
include:
    include_prefix + "/picard_stats.smk"
include:
    include_prefix + "/call_variants.smk"
include:
    include_prefix + "/joint_call.smk"
include:
    include_prefix + "/qc.smk"
include:
    include_prefix + "/vsqr.smk"
include:
    include_prefix + "/annotation.smk"
include:
    include_prefix + "/format_output.smk"
include:
    include_prefix + "/identity_check.smk"
include:
    include_prefix + "/coverage.smk"
include:
    include_prefix + "/delivery.smk"