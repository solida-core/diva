rule format_annotation:
    input:
       'annotation/kggseq/selected.flt.txt'
    output:
       cname='annotation/kggseq/annot.cname',
       header='annotation/kggseq/annot.header',
       tab='annotation/kggseq/annot.tab'
    params:
        blocks=config.get("rules").get("format_annotation").get("blocks_file")
    script:
        "scripts/format_annotation.py"


rule tabix:
    "Bgzip-compressed and tabix-indexed file with annotations"
    input:
       'annotation/kggseq/annot.tab'
    output:
       'annotation/kggseq/annot.tab.gz'
    conda:
        "../envs/tabix.yaml"
    params:
       config.get("rules").get("tabix").get("params")
    shell:
        "bgzip {input}; tabix {params} {output}"



rule bcftools_annotate_add:
    input:
       cname='annotation/kggseq/annot.cname',
       header='annotation/kggseq/annot.header',
       gz='annotation/kggseq/annot.tab.gz',
       vcf='annotation/kggseq/selected.flt.vcf'
    output:
       'annotation/bcftools/selected.annot.vcf'
    conda:
        "../envs/bcftools.yaml"
    params:
        cmd='add'
    script:
        "scripts/bcftools_annotate.py"


rule bcftools_annotate_remove:
    input:
       'annotation/bcftools/selected.annot.vcf'
    output:
       'annotation/bcftools/selected.annot.lightened.vcf'
    conda:
        "../envs/bcftools.yaml"
    params:
        cmd='remove',
        blocks=config.get("rules").get("format_annotation").get("blocks_file"),
        params=config.get("rules").get("bcftools_annotate_remove").get("params")
    script:
        "scripts/bcftools_annotate.py"


rule bcftools_reheader:
    input:
       'annotation/bcftools/selected.annot.lightened.vcf'
    output:
       'annotation/bcftools/selected.annot.lightened.reheaded.vcf'
    conda:
        "../envs/bcftools.yaml"
    params:
        reheader=config.get("rules").get("bcftools_reheader").get("reheader")
    shell:
        "bcftools reheader "
        "-s {params.reheader} "
        "-o {output} "
        "{input} "


rule vcf_to_tabular:
    input:
       'annotation/bcftools/selected.annot.lightened.reheaded.vcf'
    output:
       'annotation/bcftools/selected.annot.lightened.reheaded.tsv'
    params:
       script='../rules/scripts/vcf_to_tabular_futurized.py',
       params= "--do-not-split-sample --print-format "

    conda:
        "../envs/future.yaml"
    shell:
        "python {params.script} {params.params} {input} {output}"

