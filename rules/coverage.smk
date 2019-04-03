
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


rule coverage_heatmap:
    input:
        expand("qc/bedtools/{sample.sample}.coverage.tsv", sample=samples.reset_index().itertuples())
    output:
        "qc/bedtools/bedtools_coverage_summary.tsv",
        report("qc/bedtools/heatmap_enriched_regions.png", category="COVERAGE"),
        report("qc/bedtools/heatmap_enriched_regions_low_coverage.png", category="COVERAGE")
    params:
        path="qc/bedtools/",
        sample_files=config.get("sample_info"),
        reheader="reheader.tsv"
    conda:
        "../envs/heatmap.yaml"
    script:
        "scripts/heatmap.R"