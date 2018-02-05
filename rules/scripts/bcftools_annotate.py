import csv
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
    remove_params = snakemake.params['params']
    annot_dict = dict()
    with open(snakemake.params.blocks, 'r') as csvfile:
        reader = csv.DictReader(csvfile, delimiter='\t')
        for row in reader:
            annot_dict[row['Field']] = row

    for k, v in annot_dict.items():
        remove_params.replace(k, '_'.join([v['Block'], v['Field']]), 1)

    run(['bcftools', 'annotate',
         remove_params,
         '-o', snakemake.output[0],
         snakemake.input[0]
         ])