
rule picard_mendelian_violations:
    input:
        vcf="variant_calling/SelectVariants/{set}.selected.vcf",
        ped="annotation/{set}/kggseq/selected.ped"
    output:
        metrics="annotation/{set}/kggseq/{set}.mendelian_violations.txt"
    params:
        custom=java_params(tmp_dir=config.get("paths").get("to_tmp"), multiply_by=5),
        params="DP=20"
    log:
        "logs/picard/FindMendelianViolations/{sample}.mendel.log"
    conda:
        "../envs/picard.yaml"
    threads: conservative_cpu_count(reserve_cores=2, max_cores=99)
    shell:
        "picard FindMendelianViolations "
        "{params.custom} "
        "I={input.vcf} "
        "PED={input.ped} "
        "O={output.metrics} "
        "{params.params} "
        "THREAD_COUNT {threads} "
        ">& {log} "


rule check_relationships:
    input:
        "variant_calling/all.snp_recalibrated.indel_recalibrated.vcf.gz"
    output:
        "qc/kinship/all.relatedness2"
    params:
        out_basename="all"
    conda:
        "../envs/vcftools.yaml"
    log:
        "logs/vcftools/relatedness2.log"
    shell:
        "vcftools "
        "--gzvcf {input} "
        "--out {params.out_basename} "
        "--relatedness2 "
        ">& {log}"