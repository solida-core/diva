
rule gatk_GenomicsDBImport:
    input:
        gvcfs=expand("variant_calling/{sample.sample}.g.vcf.gz",
                     sample=samples.reset_index().itertuples())
    output:
        touch("db/imports/pippo")
    conda:
       "../envs/gatk.yaml"
    params:
        custom=java_params(tmp_dir=config.get("tmp_dir"), multiply_by=5),
        intervals = resolve_single_filepath(*references_abs_path(),config.get("intervals").get(config.get("intervals_default")).get("bedTarget")),
        genome=resolve_single_filepath(*references_abs_path(), config.get("genome_fasta")),
        gvcfs=_multi_flag_dbi("-V", expand("variant_calling/{sample.sample}.g.vcf.gz", sample=samples.reset_index().itertuples())),
        db=config.get("db_suffix")
    log:
        "logs/gatk/GenomicsDBImport/genomicsdbi.info.log"
    benchmark:
        "benchmarks/gatk/GenomicsDBImport/genomicsdbi.txt"
    shell:
        "mkdir -p db; "
        "gatk GenomicsDBImport --java-options {params.custom} "
        "{params.gvcfs} "
        "--genomicsdb-workspace-path {params.db} "
        "-L {params.intervals} "
        "-ip 200 "
        "--merge-input-intervals "
        ">& {log} "


rule gatk_GenotypeGVCFs:
    input:
        "db/imports/pippo"
    output:
        protected("variant_calling/all.vcf.gz")
    # wildcard_constraints:
    #     chr="[0-9XYM]+"
    conda:
       "../envs/gatk.yaml"
    params:
        custom=java_params(tmp_dir=config.get("tmp_dir"), multiply_by=2),
        genome=resolve_single_filepath(*references_abs_path(), config.get("genome_fasta")),
        dbsnp=resolve_single_filepath(*references_abs_path(), config.get("known_variants").get("dbsnp")),
        db=config.get("db_suffix")
    log:
        "logs/gatk/GenotypeGVCFs/all.info.log"
    benchmark:
        "benchmarks/gatk/GenotypeGVCFs/all.txt"
    shell:
        "gatk GenotypeGVCFs --java-options {params.custom} "
        "-R {params.genome} "
        "-V gendb://{params.db} "
        "-G StandardAnnotation "
        "--use-new-qual-calculator "
        "-O {output} "
        "--dbsnp {params.dbsnp} "
        ">& {log} "