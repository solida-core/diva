
rule gatk_GenomicsDBImport:
    input:
        gvcfs=expand(resolve_results_filepath(config.get("paths").get("results_dir"),"variant_calling/{sample.sample}.g.vcf.gz"),
                     sample=samples.reset_index().itertuples())
    output:
        touch(resolve_results_filepath(config.get("paths").get("results_dir"),"db/imports/check"))
    conda:
       "../envs/gatk.yaml"
    params:
        custom=java_params(tmp_dir=config.get("tmp_dir"),multiply_by=5),
        intervals=config.get("resources").get("bed"),
        genome=config.get("resources").get("reference"),
        gvcfs=multi_flag_dbi("-V", expand(resolve_results_filepath(config.get("paths").get("results_dir"),
            "variant_calling/{sample.sample}.g.vcf.gz"), sample=samples.reset_index().itertuples())),
        base_db=resolve_results_filepath(config.get("paths").get("results_dir"),"db"),
        db=resolve_results_filepath(config.get("paths").get("results_dir"),config.get("resources").get("db_suffix"))
    log:
        resolve_results_filepath(config.get("paths").get("results_dir"),"logs/gatk/GenomicsDBImport/genomicsdbi.info.log")
    benchmark:
        resolve_results_filepath(config.get("paths").get("results_dir"),"benchmarks/gatk/GenomicsDBImport/genomicsdbi.txt")
    shell:
        "mkdir -p {params.base_db} ; "
        "gatk GenomicsDBImport --java-options {params.custom} "
        "{params.gvcfs} "
        "--genomicsdb-workspace-path {params.db} "
        "-L {params.intervals} "
        "-ip 200 "
        "--merge-input-intervals "
        ">& {log} "


rule gatk_GenotypeGVCFs:
    input:
        resolve_results_filepath(config.get("paths").get("results_dir"),"db/imports/check")
    output:
        protected(resolve_results_filepath(config.get("paths").get("results_dir"),"variant_calling/all.vcf.gz"))
    conda:
       "../envs/gatk.yaml"
    params:
        custom=java_params(tmp_dir=config.get("tmp_dir"),multiply_by=5),
        genome=config.get("resources").get("reference"),
        dbsnp=config.get("resources").get("known_variants").get("dbsnp"),
        db=resolve_results_filepath(config.get("paths").get("results_dir"),config.get("resources").get("db_suffix"))
    log:
        resolve_results_filepath(config.get("paths").get("results_dir"),"logs/gatk/GenotypeGVCFs/all.info.log")
    benchmark:
        resolve_results_filepath(config.get("paths").get("results_dir"),"benchmarks/gatk/GenotypeGVCFs/all.txt")
    shell:
        "gatk GenotypeGVCFs --java-options {params.custom} "
        "-R {params.genome} "
        "-V gendb://{params.db} "
        "-G StandardAnnotation "
        # "--use-new-qual-calculator "
        "-O {output} "
        "--dbsnp {params.dbsnp} "
        ">& {log} "