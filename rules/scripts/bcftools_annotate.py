from subprocess import run

if snakemake.params['cmd'] == 'add':
    with open(snakemake.input['cname'], 'r') as fp:
            cname = fp.read()

    run(['bcftools', 'annotate',
         '-a', snakemake.input['gz'],
         '-h', snakemake.input['header'],
         '-c', cname,
         '-o', snakemake.output[0],
         snakemake.input['vcf']
         ])
elif snakemake.params['cmd'] == 'remove':
    run(['bcftools', 'annotate',
         snakemake.params['params'],
         '-o', snakemake.output[0],
         snakemake.input[0]
         ])