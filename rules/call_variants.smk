
rule gatk_HaplotypeCaller_ERC_GVCF:
    input:    
        cram="reads/recalibrated/{sample}.dedup.recal.cram"
    output:
        gvcf="variant_calling/{sample}.g.vcf.gz"
    conda:
       "../envs/gatk.yaml"
    params:
        custom=java_params(tmp_dir=config.get("tmp_dir"), multiply_by=5),
        intervals = lambda wildcards: resolve_single_filepath(*references_abs_path(), config.get("intervals").get(config.get("samples_intervals").get(wildcards.sample, config["intervals_default"])).get("bedTarget")),
        genome=resolve_single_filepath(*references_abs_path(), config.get("genome_fasta"))
    log:
        "logs/gatk/HaplotypeCaller/{sample}.genotype_info.log"
    benchmark:
        "benchmarks/gatk/HaplotypeCaller/{sample}.txt"
    threads: 2
    shell:
        "gatk HaplotypeCaller --java-options {params.custom} "
        "-R {params.genome} "
        "-I {input.cram} "
        "-O {output.gvcf} "
        "-ERC GVCF "
        "-L {params.intervals} "
        "-ip 200 "
        "-G StandardAnnotation "
        # "--use-new-qual-calculator "
        ">& {log}"