## PIPELINE STRUCTURE

[solida-core]() pipelines are based on Snakemake and for this reason are organized in a defined structure of files and directories.

The content of a general pipeline directory an be summarized as follows:

```
PIPELINE FOLDER
    │
    ├── Snakefile
    |
    ├── config.yaml
    |
    ├── envs
    │   ├── rule_a_env.yaml
    │   └── rule_b_env.yaml
    |
    ├── rules
    │   ├── rules_file_1.smk
    │   ├── rules_file_2.smk
    │   └── scripts
    │       └── personal_script_a
    |
    ├── environment.yaml
    |
    └── user_data_file_1.tsv
```
### Configfile
The configfile, generally present in out pipelines as `config.yaml`, is a file containing multiple dictionaries which is queried by Snakemake during each step execution.

In fact, in each process of the pipeline, called [rule](#rules), a section of the configfile can be imported for passing parameters to a function or the path of a given file or whatever the user want to import.

In example, the following configfile section:

```
genome_fasta: "reference_files_path/my_genome.fasta"
mapping_parameters: "-A 20 -C 40"
```
shows the specification of a fasta file with its path and a couple of parameters for an hypotetical mapping step.
 
Snakemake allows accessing information contained in the configfile via the global variable `config`:
```
config.get("genome_fasta") 
config.get("mapping_parameters")
```
In this way it is possible the separation between general structure of an analysis workflow and the related parameters that can be edited in a specific configuration file.


### Rules
Snakemake workflows are essentially Python scripts extended by declarative code to define rules, which describe how to create output files from input files.

Generally a rule is composed by the rule name, input and output and the command which generates the output.
```
rule my_rule_name:
    input:
        "raw/my_first_input"
    output:
        "plots/my_first_output"
    shell:
        "somecommand {input} {output}"
```
The output of a given rule can be either the input of a successive rule. In this way it is possible build a workflow comprising multiple steps. Snakemake determines the rule dependencies by matching file names.

Further [arguments](https://snakemake.readthedocs.io/en/stable/snakefiles/writing_snakefiles.html#grammar) of a rule that can be included are `log`,`params`,`benchmark`,`threads`,`conda`,`run` and so on. For complete manual directly refer to [Snakemake](https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#rules).

##### Scripts
A rule can also point to an external script instead of a shell command or inline Python code:
```
rule NAME:
    input:
        "path/to/inputfile",
        "path/to/other/inputfile"
    output:
        "path/to/outputfile",
        "path/to/another/outputfile"
    script:
        "path/to/script.py"
```
The script path is always relative to the Snakefile (in contrast to the input and output file paths, which are relative to the working directory). 
Inside the script, you have access to an object `snakemake` that provides access to the same objects that are available in the `run` and `shell` directives (input, output, params, wildcards, log, threads, resources, config), e.g. you can use `snakemake.input[0]` to access the first input file of above rule.

Apart from Python scripts, this mechanism also allows you to integrate R and R Markdown scripts with Snakemake:
```
rule NAME:
    input:
        "path/to/inputfile",
        "path/to/other/inputfile"
    output:
        "path/to/outputfile",
        "path/to/another/outputfile"
    script:
        "path/to/script.R"
```
In the R script, an S4 object named `snakemake` analog to the Python case above is available and allows access to input and output files and other parameters. 
Here the syntax follows that of S4 classes with attributes that are R lists: we can access the first input file with `snakemake@input[[1]]` (note that the first file does not have index 0 here, because R starts counting from 1).


### Envs 
With Snakemake it is possible to define isolated software environments per rule. 
Upon execution of a workflow, the [Conda package manager](https://conda.io/en/latest/) is used to obtain and deploy the defined software packages in the specified versions. 

Packages will be installed into your working directory, without requiring any admin/root priviledges. 

Given that conda is available on your system (see [Miniconda](https://docs.conda.io/en/latest/miniconda.html)), to use the Conda integration, add the `--use-conda` flag to your workflow execution command, e.g. `snakemake --cores 8 --use-conda`. 

When `--use-conda` is activated, Snakemake will automatically create software environments for any used wrapper (see [Wrappers](https://snakemake.readthedocs.io/en/stable/snakefiles/modularization.html#wrappers)). 

Further, you can manually define environments via the `conda` directive:
```
rule NAME:
    input:
        "table.txt"
    output:
        "plots/myplot.pdf"
    conda:
        "envs/ggplot.yaml"
    script:
        "scripts/plot-stuff.R"
```
where the `ggplot.yaml` file contains the following environment definition:
```
channels:
 - r
dependencies:
 - r=3.3.1
 - r-ggplot2=2.1.0
```
[solida-core]() pipelines include all environment definition files inside the `envs/` folder.


### Snakefile
The **Snakefile** of a Snakemake-based pipeline is mostly the "head" of the workflow.
In fact in this file there is a "target" rule named `rule all` which inputs are the desired output files that the workflow should produce.

Given that Snakemake automatically checks rule dependencies by matching input/output filenames, it is not necessary to inlcude in the rule all every generated output file. The required ones are those produced in the last step of a workflow ramo (CLADE?).

This section looks like:

```
rule all:
    input:
        "reads/my_sample.bam",
        "qc/multiqc.html",
        "variant_calling/my_sample.vcf"

```
In this case we have 3 desired outputs:
 - a BAM file
 - a MULTIQC report
 - a VCF file

From these files, Snakemake performs a back-check for input/output matches. If the BAM file is inlcuded in VCF file generation steps, is not required to be indicated in the rule all, because that clade of the workflow is aimed at producing the VCF.

On the other hand, because the MULTIQC report is not input of any dependency for generating the VCF file, it needs to be indicated. Is like a collateral part of the main workflow. 

Other two sections of Snakefile need to be mentioned.

```
### LOAD LIBRARIES
import pandas as pd


## USER FILES ##
samples = pd.read_csv(config["samples"], index_col="sample", sep="\t")
```
The above section represent an example of library loading and its usage in creating variables. 
In this case we used pandas to read a table in which we stored sample names. 
Notice that the complete path and the filename are declared in the configfile under the `samples` entry.

Finally,files including rules to be executed by a Snakefile need to be "included" with the `include` statement as follows:
```
include: "rules/my_first_set_of_rules.smk"
include: "rules/another_set_of_rules.smk"
include: "otherfolder/set_of_rules_in_a_different_folder.smk"
```

Further information and tutorials can be found in the [Snakemake](https://snakemake.readthedocs.io/en/stable/) official page.
___________________
Part of the documentation reported in this file comes from [Snakemake](https://snakemake.readthedocs.io/en/stable/) official guide.
