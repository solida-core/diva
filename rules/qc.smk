rule multiqc:
    input:
       # expand("reads/recalibrated/{sample.sample}.dedup.txt",sample=samples.reset_index().itertuples()),
        expand("reads/recalibrated/{sample.sample}.recalibration_plots.pdf",sample=samples.reset_index().itertuples()),
        expand("reads/recalibrated/{sample.sample}.dedup.recal.hs.txt",sample=samples.reset_index().itertuples()),
        expand("reads/recalibrated/{sample.sample}.dedup.recal.is.txt",sample=samples.reset_index().itertuples())

    output:
        "qc/multiqc.html"
    params:
        config.get("rules").get("multiqc").get("arguments")
    log:
        "logs/multiqc/multiqc.log"
    wrapper:
        "0.27.0/bio/multiqc"

