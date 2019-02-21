import pandas as pd
from snakemake.utils import validate, min_version
##### set minimum snakemake version #####
min_version("5.1.2")


##### load config and sample sheets #####

#configfile: "config.yaml"

samples = pd.read_csv(config["samples"], index_col="sample", sep="\t")
units = pd.read_csv(config["units"], index_col=["unit"], dtype=str, sep="\t")

##### local rules #####

localrules: all, pre_rename_fastq_pe, post_rename_fastq_pe

##### target rules #####
rule repos:
    input:
        "logs/dima/dima_clone.done",
        "logs/multiqc/gatkdoc_plugin_activation.done"

rule all:
    input:
        expand("reads/recalibrated/{sample.sample}.dedup.recal.bam", sample=samples.reset_index().itertuples()),
        expand("reads/recalibrated/{sample.sample}.dedup.recal.hs.txt",sample=samples.reset_index().itertuples()),
#        expand("reads/recalibrated/{sample.sample}.ccds.dedup.recal.hs.txt",sample=samples.reset_index().itertuples()),
        "qc/multiqc.html",
        expand("variant_calling/{sample.sample}.g.vcf.gz",sample=samples.reset_index().itertuples()),
        "db/imports/check",
        "variant_calling/all.vcf.gz",
#        "variant_calling/all.snp_recalibrated.indel_recalibrated.vcf.gz"





include_prefix="rules"
dima_path="dima/"

include:
    include_prefix + "/functions.py"
include:
    include_prefix + "/clone_repository.smk"
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
if config.get("analysis")=="exome":
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
