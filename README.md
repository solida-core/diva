[![depends](https://img.shields.io/badge/depends%20from-bioconda-brightgreen.svg)](http://bioconda.github.io/)
[![snakemake](https://img.shields.io/badge/snakemake-5.3-brightgreen.svg)](https://snakemake.readthedocs.io/en/stable/)

# DiVA
**DiVA** (DNA Variant Analysis) is a pipeline for Next-Generation Sequencing **Exome** data anlysis.

All **[solida-core](https://github.com/solida-core)** workflows follow GATK Best Practices for Germline Variant Discovery, with the incorporation of further improvements and refinements after their testing with real data in various [CRS4 Next Generation Sequencing Core Facility](http://next.crs4.it) research sequencing projects.

Pipelines are based on [Snakemake](https://snakemake.readthedocs.io/en/stable/), a workflow management system that provides all the features needed to create reproducible and scalable data analyses.

Software dependencies are specified into the `environment.yaml` file and directly managed by Snakemake using [Conda](https://docs.conda.io/en/latest/miniconda.html), ensuring the reproducibility of the workflow on a great number of different computing environments such as workstations, clusters and cloud environments.


### Pipeline Overview
The pipeline workflow is composed by three major analysis sections:
 * [_Mapping_](https://github.com/massiddamt/docs/tree/master/dima/README.md): paired-end reads in fastq format are aligned against a reference genome to produce a deduplicated and recalibrated BAM file. This section is executed by DiMA pipeline.

 * [_Variant Calling_](docs/diva_workflow.md#variant-calling): a joint call is performed from all project's bam files
 
 * [_Annotation_](docs/diva_workflow.md#annotation): discovered variants are annotated and results are converted in a set of different output file formats enabling downstream analysis for all kind of users
 
A complete view of the analysis workflow is provided by the pipeline's [graph](images/diva.png).
![Workflow](./images/diva.png)

### Pipeline Handbook
**DiVA** pipeline documentation can be found in the `docs/` directory:


1. [Pipeline Structure:](docs/pipeline_structure.md)
    * [Snakefile](docs/pipeline_structure.md#snakefile)
    * [Configfile](docs/pipeline_structure.md#configfile)
    * [Rules](docs/pipeline_structure.md#rules)
    * [Envs](docs/pipeline_structure.md#envs)
2. [Pipeline Workflow](docs/diva_workflow.md)
3. [Required Files:]()
    * [Reference files](docs/reference_files.md)
    * [User files](docs/user_files.md)
4. [Quick-Start](docs/installation.md)
5. [Usage:]()
    * [Manual Snakemake Usage](docs/diva_snakemake.md)
    * [SOLIDA:]()
        * [CLI - Command Line Interface](https://github.com/solida-core/solida/blob/master/README.md)
        * [GUI - Graphical User Interface]()






### Contact us
[support@solida-core](mailto:m.massidda@crs4.it) 



