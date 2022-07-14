
rule check_relationships:
    input:
        resolve_results_filepath(config.get("paths").get("results_dir"),"variant_calling/all.snp_recalibrated.indel_recalibrated.vcf.gz")
    output:
        resolve_results_filepath(config.get("paths").get("results_dir"),"qc/kinship/all.relatedness2")
    params:
        out_basename=resolve_results_filepath(config.get("paths").get("results_dir"),"qc/kinship/all")
    conda:
        "../envs/vcftools.yaml"
    log:
        resolve_results_filepath(config.get("paths").get("results_dir"),"logs/vcftools/relatedness2.log")
    shell:
        "vcftools "
        "--gzvcf {input} "
        "--out {params.out_basename} "
        "--relatedness2 "
        ">& {log}"