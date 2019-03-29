
rule bedtools_coverage:
    input:
        bam="reads/recalibrated/{sample}.dedup.recal.bam"
    output:
        "qc/bedtools/{sample}.coverage.tsv"
    params:
        interval=config.get("interval_list"),
        params=config.get("rules").get("bedtools_coverage").get("params")
    conda:
        "../envs/bedtools.yaml"
    shell:
        "bedtools coverage "
        "-a {params.interval} "
        "-b {input.bam} "
        "{params.params} "
        "> {output} "


rule bedtools_select_regions_coverage:
    input:
        "qc/bedtools/{sample}.coverage.tsv"
    output:
        "qc/bedtools/target/{sample}.coverage.target.tsv"
    params:
        interval=config.get("interval_target_list")
    conda:
        "../envs/bedtools.yaml"
    shell:
        "bedtools intersect "
        "-b {params.interval} "
        "-a {input} "
        "> {output} "