
rule preprare_samples:
    input:
        config.get("rules").get("bcftools_reheader").get("reheader")
    output:
        "reheader.tsv"
    shell:
        "perl -pe 's/ /\t/g' {input} > {output} "



rule multiqc:
    input:
        "logs/multiqc/gatkdoc_plugin_activation.done",
        expand("qc/untrimmed_{unit.unit}.html", unit=units.reset_index().itertuples()),
        expand("qc/trimmed_{unit.unit}.html", unit=units.reset_index().itertuples()),
        expand("reads/trimmed/{unit.unit}-R1.fq.gz_trimming_report.txt", unit=units.reset_index().itertuples()),
        expand("reads/dedup/{sample.sample}.metrics.txt",sample=samples.reset_index().itertuples()),
        expand("reads/recalibrated/{sample.sample}.dedup.recal.hs.txt",sample=samples.reset_index().itertuples()),
        expand("reads/recalibrated/{sample.sample}.dedup.recal.is.txt",sample=samples.reset_index().itertuples()),
        expand("qc/picard/{sample.sample}_gc_bias_metrics.txt",sample=samples.reset_index().itertuples()),
        expand("qc/picard/{sample.sample}_summary_metrics.txt",sample=samples.reset_index().itertuples())

    output:
        "qc/multiqc.html"
    params:
        params=config.get("rules").get("multiqc").get("arguments"),
        outdir="qc",
        outname="multiqc.html",
        reheader="reheader.tsv"
    conda:
        "../envs/multiqc.yaml"
    log:
        "logs/multiqc/multiqc.log"
    shell:
        "multiqc "
        "{input} "
        "{params.params} "
        "-o {params.outdir} "
        "-n {params.outname} "
        "--sample-names {params.reheader} "
        ">& {log}"


rule fastqc:
    input:
       "reads/{unit}-R1.fq.gz",
       "reads/{unit}-R2.fq.gz"
    output:
        html="qc/untrimmed_{unit}.html",
        zip="qc/untrimmed_{unit}_fastqc.zip"
    log:
        "logs/fastqc/{unit}.log"
    params: ""
    wrapper:
        config.get("wrappers").get("fastqc")


rule fastqc_trimmed:
    input:
       "reads/trimmed/{unit}-R1-trimmed.fq.gz",
       "reads/trimmed/{unit}-R2-trimmed.fq.gz"
    output:
        html="qc/trimmed_{unit}.html",
        zip="qc/trimmed_{unit}_fastqc.zip"
    log:
        "logs/fastqc/{unit}.log"
    params: ""
    wrapper:
        config.get("wrappers").get("fastqc")



rule multiqc_heatmap:
    input:
        "qc/kinship/all.relatedness2"
    output:
        "qc/kinship/multiqc_heatmap.html"
    params:
        params=config.get("rules").get("multiqc").get("arguments"),
        outdir="qc/kinship",
        outname="multiqc_heatmap.html",
        reheader="reheader.tsv"
    conda:
        "../envs/multiqc.yaml"
    log:
        "logs/multiqc/multiqc_heatmap.log"
    shell:
        "multiqc "
        "{input} "
        "{params.params} "
        "-m vcftools "
        "-o {params.outdir} "
        "-n {params.outname} "
        "--sample-names {params.reheader} "
        ">& {log}"
