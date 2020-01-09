def get_sample_by_client(wildcards, reheader, label='LIMS', structure="folder/{sample}.extension"):
    re.sub(r"{sample}",reheader.loc[wildcards.Client,[label]][0], structure)
    return re.sub(r"{sample}",reheader.loc[wildcards.Client,[label]][0], structure)


rule delivery_completed:
    input:
        xslx=expand("delivery/annotation/{set.set}/{set.set}.selected.annot.lightened.xlsx", set=sets.reset_index().itertuples()),
        bam=expand("delivery/bams/{Client.Client}.bam", Client=reheader.reset_index().itertuples())
    output:
        touch("delivery.completed")



rule delivery_bam:
    input:
        bam=lambda wildcards: get_sample_by_client(wildcards, reheader, label="LIMS", structure='reads/recalibrated/{sample}.dedup.recal.bam'),
        bai=lambda wildcards: get_sample_by_client(wildcards, reheader, label="LIMS", structure='reads/recalibrated/{sample}.dedup.recal.bai')
    output:
        bam="delivery/bams/{Client}.bam",
        bai="delivery/bams/{Client}.bam.bai"
    shell:
        "cp {input.bam} {output.bam} && "
        "cp {input.bai} {output.bai} "



rule delivery_annotation:
    input:
        vcf='annotation/{set}/bcftools/selected.annot.lightened.reheaded.vcf',
        tsv='annotation/{set}/bcftools/selected.annot.lightened.reheaded.tsv',
        xlsx='annotation/{set}/bcftools/selected.annot.lightened.reheaded.xlsx'
    output:
        vcf="delivery/annotation/{set}/{set}.selected.annot.lightened.vcf",
	tsv="delivery/annotation/{set}/{set}.selected.annot.lightened.tsv",
	xlsx=report("delivery/annotation/{set}/{set}.selected.annot.lightened.xlsx", caption="../report/bcftools.rst", category="ANNOTATION")
    shell:
        "cp {input.vcf} {output.vcf} && "
        "cp {input.tsv} {output.tsv} && "
        "cp {input.xlsx} {output.xlsx} "
