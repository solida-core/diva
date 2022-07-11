
rule gatk_HaplotypeCaller_ERC_GVCF:
    input:    
        bam=resolve_results_filepath(config.get("paths").get("results_dir"),"reads/recalibrated/{sample}.dedup.recal.bam"),
        bai=resolve_results_filepath(config.get("paths").get("results_dir"),"reads/recalibrated/{sample}.dedup.recal.bam.bai")
    output:
        gvcf=resolve_results_filepath(config.get("paths").get("results_dir"),"variant_calling/{sample}.g.vcf.gz")
    conda:
       "../envs/gatk.yaml"
    params:
        custom=java_params(tmp_dir=config.get("tmp_dir"), multiply_by=5),
        intervals = config.get("resources").get("bed"),
        genome=config.get("resources").get("reference")
    log:
        resolve_results_filepath(config.get("paths").get("results_dir"),"logs/gatk/HaplotypeCaller/{sample}.genotype_info.log")
    benchmark:
        "benchmarks/gatk/HaplotypeCaller/{sample}.txt"
    threads: 2
    shell:
        "gatk HaplotypeCaller --java-options {params.custom} "
        "-R {params.genome} "
        "-I {input.bam} "
        "-O {output.gvcf} "
        "-ERC GVCF "
        "-L {params.intervals} "
        "-ip 200 "
        "-G StandardAnnotation "
        # "--use-new-qual-calculator "
        ">& {log}"