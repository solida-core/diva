rule gatk_SelectVariants:
    input:
        vcf="variant_calling/all.snp_recalibrated.indel_recalibrated.vcf.gz",
        #lambda wildcards: get_sample_by_set(wildcards, sets)
    output:
        vcf="variant_calling/SelectVariants/{set}.selected.vcf"
    params:
        custom=java_params(tmp_dir=config.get("tmp_dir"), multiply_by=5),
        genome=resolve_single_filepath(*references_abs_path(), config.get("genome_fasta")),
        arguments=_multi_flag(config.get("rules").get("gatk_SelectVariants").get("arguments")),
#        samples_files=_get_samples_set(config.get("rules").get("gatk_SelectVariants").get("samples_files"))
        samples=lambda wildcards: get_sample_by_set(wildcards, sets)
    log:
        "logs/gatk/SelectVariants/{set}.SelectVariants.log"
    benchmark:
        "benchmarks/gatk/SelectVariants/{set}.SelectVariants.txt"
    conda:
       "../envs/gatk.yaml"

    shell:
        "gatk SelectVariants "
        "--java-options {params.custom} "
        "-R {params.genome} "
        "-V {input.vcf} "
        "{params.samples} "
        "-O {output.vcf} "
        "{params.arguments} "
#        "{params.samples_files} "



rule kggseq:
    input:
        vcf="variant_calling/SelectVariants/{set}.selected.vcf"
    output:
        vcf='annotation/{set}/kggseq/selected.flt.vcf',
        log='annotation/{set}/kggseq/selected.log',
        txt='annotation/{set}/kggseq/selected.flt.txt',
        ped='annotation/{set}/kggseq/selected.ped'
    params:
        custom=java_params(tmp_dir=config.get("tmp_dir"), multiply_by=5),
        cmd=config.get("rules").get("kggseq").get("cmd"),
        arguments=_multi_flag(config.get("rules").get("kggseq").get("arguments")),
        ped_file=config.get("rules").get("kggseq").get("ped_file"),
        out_basename='annotation/{set}/kggseq/selected'
    benchmark:
        "benchmarks/kggseq/{set}.kggseq.txt"
    threads: conservative_cpu_count()
    shell:
        "cp {params.ped_file} {output.ped} && "
        "{params.cmd} -nt {threads} {params.custom} "
        "--no-resource-check --no-lib-check --no-web --no-gz "
        "--no-qc --o-vcf "
        "{params.arguments} "
        "--vcf-file {input.vcf} "
        "--ped-file {output.ped} "
        "--out {params.out_basename}"

rule kggseq_doubleHits:
    input:
        vcf="variant_calling/SelectVariants/{set}.selected.vcf"
    output:
        vcf='annotation/{set}/kggseq/doubleHits.flt.vcf',
        log='annotation/{set}/kggseq/doubleHits.log',
        txt='annotation/{set}/kggseq/doubleHits.flt.txt',
        ped='annotation/{set}/kggseq/selected_doubleHits.ped',
        dHit='annotation/{set}/kggseq/doubleHits.doublehit.gene.trios.flt.gty.txt'
    params:
        custom=java_params(tmp_dir=config.get("tmp_dir"), multiply_by=5),
        cmd=config.get("rules").get("kggseq").get("cmd"),
        arguments=_multi_flag(config.get("rules").get("kggseq").get("arguments")),
        ped_file=config.get("rules").get("kggseq").get("ped_file"),
        out_basename='annotation/{set}/kggseq/doubleHits'
    benchmark:
        "benchmarks/kggseq/{set}.kggseq_doubleHits.txt"
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
        "--out {params.out_basename}"
