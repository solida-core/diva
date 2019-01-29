import pandas as pd
from snakemake.utils import validate, min_version
##### set minimum snakemake version #####
min_version("5.1.2")


##### load config and sample sheets #####

configfile: "config.yaml"

samples = pd.read_csv(config["samples"], index_col="sample", sep="\t")
units = pd.read_csv(config["units"], index_col=["unit"], dtype=str, sep="\t")

##### local rules #####

#localrules: all, pre_rename_fastq_pe, post_rename_fastq_pe


##### target rules #####

rule all:
    input:
        expand("reads/recalibrated/{sample.sample}.dedup.recal.bam",
            sample=samples.reset_index().itertuples()),
        expand("reads/recalibrated/{sample.sample}.dedup.recal.is.pdf",sample=samples.reset_index().itertuples()),
        expand("reads/recalibrated/{sample.sample}.dedup.recal.hs.txt",sample=samples.reset_index().itertuples()),
        expand("variant_calling/{sample.sample}.g.vcf.gz",sample=samples.reset_index().itertuples()),
        "db/imports/pippo",
        "variant_calling/all.vcf.gz"

#rule all:
#    input:
#           expand("mapped_reads/merged_samples/{sample}.dedup.realn.recal.hs.txt", \
##                  sample=config["samples"]),
#           expand("mapped_reads/merged_samples/{sample}.dedup.realn.recal.is.txt", \
#                  sample=config["samples"]),
#           expand("mapped_reads/merged_samples/{sample}.recalibration_plots.pdf", \
#                  sample=config["samples"]),
#           "variant_calling/all.snp_recalibrated.indel_recalibrated.vcf",


#include:
#    "Snakefile.single_samples_only"

include_prefix="rules"
#include:
#    include_prefix + "/gatk_variant_recalibrator.rules"

dima_path="dima/"
### includere rule di dima
### mettere switch per rule picard con file picard_exome.smk di diva
include:
    dima_path + include_prefix + "/functions.py"
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
    include_prefix + "/gatk_vcf_caller.rules"




