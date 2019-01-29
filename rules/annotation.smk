rule gatk_SelectVariants:
    input:
        vcf=expand("{path_to_recal_vcf}/all.snp_recalibrated.indel_recalibrated.vcf", \
                     path_to_recal_vcf=config.get("paths").get("to_recalibrated_vcf"))
    output:
        vcf="variant_calling/SelectVariants/selected.vcf"
    params:
        custom=java_params(tmp_dir=config.get("paths").get("to_tmp"), multiply_by=5),
        genome=resolve_single_filepath(*references_abs_path(), config.get("genome_fasta")),
        arguments=_multi_flag(config.get("rules").get("gatk_SelectVariants").get("arguments")),
        samples_files=_get_samples_set(config.get("rules").get("gatk_SelectVariants").get("samples_files"))

    log:
        "logs/gatk/SelectVariants/SelectVariants.log"
    benchmark:
        "benchmarks/gatk/SelectVariants/SelectVariants.txt"
    conda:
       "../envs/gatk.yaml"

    shell:
        "gatk SelectVariants "
        "--java-options {params.custom} "
        "-R {params.genome} "
        "-V {input.vcf} "
        "-O {output.vcf} "
        "{params.arguments} "
        "{params.samples_files} "



rule kggseq:
    input:
       vcf="variant_calling/SelectVariants/selected.vcf"
    output:
       vcf='annotation/kggseq/selected.flt.vcf',
       log='annotation/kggseq/selected.log',
       txt='annotation/kggseq/selected.flt.txt',
       ped='annotation/kggseq/selected.ped'
    params:
       custom=java_params(tmp_dir=config.get("paths").get("to_tmp"), multiply_by=5),
       cmd=config.get("rules").get("kggseq").get("cmd"),
       arguments=_multi_flag(config.get("rules").get("kggseq").get("arguments")),
       ped_file=config.get("rules").get("kggseq").get("ped_file")
    benchmark:
        "benchmarks/kggseq/kggseq.txt"
    threads: conservative_cpu_count()
    shell:
        "cp {params.ped_file} {output.ped} && "
        "{params.cmd} -nt {threads} {params.custom} "
        "--no-resource-check --no-lib-check --no-web --no-gz "
        "--no-qc --o-vcf "
        "{params.arguments} "
        "--vcf-file {input.vcf} "
        "--ped-file {output.ped} "
        "--out annotation/kggseq/selected"

rule kggseq_doubleHits:
    input:
       vcf="variant_calling/SelectVariants/selected.vcf"
    output:
       vcf='annotation/kggseq/doubleHits.flt.vcf',
       log='annotation/kggseq/doubleHits.log',
       txt='annotation/kggseq/doubleHits.flt.txt',
       ped='annotation/kggseq/selected.ped'
   params:
       custom=java_params(tmp_dir=config.get("paths").get("to_tmp"), multiply_by=5),
       cmd=config.get("rules").get("kggseq").get("cmd"),
       arguments=_multi_flag(config.get("rules").get("kggseq").get("arguments")),
       ped_file=config.get("rules").get("kggseq").get("ped_file")
    benchmark:
        "benchmarks/kggseq/kggseq.txt"
    threads: conservative_cpu_count()
    shell:
        "cp {params.ped_file} {output.ped} && "
        "{params.cmd} -nt {threads} {params.custom} "
        "--no-resource-check --no-lib-check --no-web --no-gz "
        "--no-qc --o-vcf "
        "{params.arguments} "
        "--double-hit-gene-trio-filter "
        "--vcf-file {input.vcf} "
        "--ped-file {output.ped} "
        "--out annotation/kggseq/doubleHits"