from subprocess import run

run(['bcftools', 'annotate',
     snakemake.params[0],
     '-o', snakemake.output[0],
     snakemake.input[0]
     ])
