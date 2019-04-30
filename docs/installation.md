# DiVA
DiVA (**DNA .......Variant?** ) is a Snakemake-based pipeline for NGS Exome Sequencing data anlysis.
This pipeline follows GATK Best Practices for Germline Variant Discovery.



## Installation
DiVA pipeline contains the instruction to automatically download and install all required dependecies can workflow consists of three main analysis phases:
 * [_Mapping_](https://github.com/solida-core/dima/blob/master/README.md): paired-end reads in fastq format are aligned against a reference genome to produce a deduplicated and recalibrated BAM file

 * [_Variant Calling_](): from bam files is performed a joint call and a recalibration of discovered variants
 
 * [_Annotation_](): perfomed for each set specified in an accessory file 




per Fare plot:
```bash
snakemake --configfile config.yaml --dag | dot -Tpng > diva_4.1.png
```