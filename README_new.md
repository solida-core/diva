[![depends](https://img.shields.io/badge/depends%20from-bioconda-brightgreen.svg)](http://bioconda.github.io/)
![matteo](https://img.shields.io/badge/snakemake-5.3-brightgreen.svg)

# DiVA
DiVA (**DNA .......Variant?** ) is a Snakemake-based pipeline for NGS Exome Sequencing data anlysis.
This pipeline follows GATK Best Practices for Germline Variant Discovery.



## Workflow
DiVA workflow comprise three analysis phases:
 * [_Mapping_](https://github.com/solida-core/dima/blob/master/README.md): paired-end reads in fastq format are aligned against a reference genome to produce a deduplicated and recalibrated BAM file
 * [Configuration](#snakefile)
 * _Variant_, from bam through all the gvcf toghether to a recalibrated vcf  

 * _Annotation_, to produce a callset ready for downstream genetic analysis.  


## Informazioni necessarie
 * sample e units in formato tsv
 * kit di enrichment utilizzato
 
## Post-Deploy Operations
All'interno della cartella di progetto bisogna verificare che i dati nel config.yaml siano corretti (reference, path vari).
Fondamentale: 
 * intervals_default: inserire il nome del kit di enrichment
 * db_suffix: aggiungere il suffisso del progetto (es. matteo --> db_matteo)
 * tmp_dir: verificare che sia stato inserito correttamente per evitare di saturare la tmp di un nodo
 
## Snakefile
Nella pipeline sono presenti 2 snakefile: Snakefile e Snakefile.annotation. Il primo è deputato all'analisi dal fq al vcf non annotato. L'altro performa l'annotazione.

## Prima parte analisi
Nello Snakefile sono presenti due rule: ruel_repos e rule_all.
Questo è necessario perchè Solida non fa il deploy del subrepository con le rule di allineamento.
Alla prima run verrà letta solo la rule_repos che clonerà tutto quello che serve e poi una volta finito determinerà uno stop.
La rule repos deve poi essere semplicemente commentata "#" in modo che possa essere letta la rule_all. A quel punto l'analisi va tranquillamente.
```bash
./run.project.sh -s Snakefile -c config.yaml -p '--profile exome' -w workdir
```
Una volta che le rule_repos sono eseguite verrà creata la cartella "dima".
é necessario editare manualmente i file dima/rules/trimming.smk, dima/rules/picard.smk e il file rules/qc.smk per sostituire il link del wrapper di snakemake con i file e i path fisici dei wrapper.
## Seconda parte: Annotation
Per la parte di annotazione è necessario editare il file config.yaml.
Vanno aggiunti:
 * paths - to_gvcfs e to_recalibrated_vcf (coincidono): inserire il path della cartella 2019_***/variant_calling
 * path dei sofware per kggseq
 * path dei file ped, blocks_file, reheader

Per ciascun set da annotare deve essere preparato un file set***.args
Questo va indicato poi nella sezione gatk_SelectVariants nella forma:
        setname: "path_to_set_file/setfile.args"
        othersetname: "path_to_set_file/othersetfile.args"

Infine l'analisi viene eseguita specificando il set name e la cartella che si vuole creare per quel set:        
```bash
./run.project.sh -s Snakefile.annotation -c config.yaml -p '--config sample_set=set1 --profile crs4' -w set1 
```
Fondamentale: l'argomento inserito "sample_set" deve essere assolutamente identico al nome del set indicato nel config.yaml. In caso contrario varranno selezionati tutti i set.


per Fare plot:
```bash
snakemake --configfile config.yaml --dag | dot -Tpng > diva_4.1.png
```