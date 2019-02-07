

###dopo BSQR

rule picard_pre_HsMetrics:
   input:
       bam="reads/recalibrated/{sample}.dedup.recal.bam"
   output:
       probes=temp("references/{sample}_probes_header"),
       hsTarget=temp("references/{sample}_hsTarget_header")
   conda:
       "../envs/samtools.yaml"
   params:
        probes = lambda wildcards: resolve_single_filepath(*references_abs_path(), config.get("intervals").get(config.get("samples_intervals").get(wildcards.sample, config["intervals_default"])).get("probes")),
        hsTarget = lambda wildcards: resolve_single_filepath(*references_abs_path(), config.get("intervals").get(config.get("samples_intervals").get(wildcards.sample, config["intervals_default"])).get("hsTarget")),
   shell:
       "samtools view -H  {input.bam} | cat - {params.probes} > {output.probes}; "
       "samtools view -H  {input.bam} | cat - {params.hsTarget} > {output.hsTarget}"

rule picard_HsMetrics:
   input:
       bam="reads/recalibrated/{sample}.dedup.recal.bam",
       probes="references/{sample}_probes_header",
       hsTarget="references/{sample}_hsTarget_header"
   output:
       "reads/recalibrated/{sample}.dedup.recal.hs.txt"
   conda:
       "../envs/picard.yaml"
   params:
        custom=java_params(tmp_dir=config.get("tmp_dir"), multiply_by=5),
   benchmark:
       "benchmarks/picard/HsMetrics/{sample}.txt"
   shell:
       "picard {params.custom} CollectHsMetrics "
       "INPUT={input.bam} OUTPUT={output} "
       "BAIT_INTERVALS={input.probes} TARGET_INTERVALS={input.hsTarget} "
       "CLIP_OVERLAPPING_READS=false MINIMUM_MAPPING_QUALITY=-1 MINIMUM_BASE_QUALITY=-1 "


rule picard_InsertSizeMetrics:
   input:
      bam="reads/recalibrated/{sample}.dedup.recal.bam"
   output:
       metrics="reads/recalibrated/{sample}.dedup.recal.is.txt",
       histogram="reads/recalibrated/{sample}.dedup.recal.is.pdf"
   conda:
       "../envs/picard.yaml"
   params:
        custom=java_params(tmp_dir=config.get("tmp_dir"), multiply_by=5),
   benchmark:
       "benchmarks/picard/IsMetrics/{sample}.txt"
   shell:
       "picard {params.custom} CollectInsertSizeMetrics "
       "INPUT={input.bam} "
       "OUTPUT={output.metrics} "
       "HISTOGRAM_FILE={output.histogram} "