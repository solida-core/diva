from subprocess import run

with open(snakemake.input['cname'], 'r') as fp:
        cname = fp.read()

run(['bcftools', 'annotate',
     '-a', snakemake.input['gz'],
     '-h', snakemake.params.header,
     '-c', cname,
     '-o', snakemake.output[0],
     snakemake.input['vcf']
     ])
