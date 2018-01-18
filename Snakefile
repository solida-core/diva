# vim: syntax=python tabstop=4 expandtab
# coding: utf-8

from snakemake.utils import min_version

min_version("4.1.0")

UNIT_TO_SAMPLE = {
    unit: sample for sample, units in config["samples"].items()
    for unit in units}

rule all:
    input:
           expand("mapped_reads/merged_samples/{sample}.dedup.realn.recal.hs.txt", \
                  sample=config["samples"]),
           expand("mapped_reads/merged_samples/{sample}.dedup.realn.recal.is.txt", \
                  sample=config["samples"]),
           expand("mapped_reads/merged_samples/{sample}.recalibration_plots.pdf", \
                  sample=config["samples"]),
           "variant_calling/all.snp_recalibrated.indel_recalibrated.vcf",


include:
    "Snakefile.single_samples_only"

include_prefix="rules"
include:
    include_prefix + "/gatk_variant_recalibrator.rules"
