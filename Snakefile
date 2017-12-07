# vim: syntax=python tabstop=4 expandtab
# coding: utf-8

from snakemake.utils import min_version

min_version("4.1.0")

onstart:
    shell("mail -s 'Workflow started' email_address < {log}")

onsuccess:
    shell("mail -s 'Workflow finished, no error' email_address < {log}")

onerror:
    shell("mail -s 'an error occurred' email_address < {log}")

UNIT_TO_SAMPLE = {
    unit: sample for sample, units in config["samples"].items()
    for unit in units}

rule all:
    input: expand("mapped_reads/merged_samples/{sample}.dedup.realn.recal.hs.txt", \
                  sample=config["samples"]),
           expand("mapped_reads/merged_samples/{sample}.dedup.realn.recal.is.txt", \
                  sample=config["samples"]),
           expand("mapped_reads/merged_samples/{sample}.recalibration_plots.pdf", \
                  sample=config["samples"]),
           "variant_calling/all.snp_recalibrated.indel_recalibrated.vcf",
           "variant_calling/cohort/cohort.gvcf"

include_prefix="rules"

include:
    include_prefix + "/functions.py"
include:
    include_prefix + "/bwa_mem.rules"	
include:
    include_prefix + "/samtools.rules"
include:
    include_prefix + "/picard.rules"
include:
    include_prefix + "/gatk.rules" 
include:
    include_prefix + "/gatk_haplotype_caller.rules"
include:
    include_prefix + "/gatk_variant_recalibrator.rules"	
