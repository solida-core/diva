import csv
from collections import OrderedDict

with open(snakemake.input[0], 'r') as fp:
    _cname = fp.readline().strip()
    _body = fp.readlines()

annot_dict = dict()
with open(snakemake.params.blocks, 'r') as csvfile:
    reader = csv.DictReader(csvfile, delimiter='\t')
    for row in reader:
        annot_dict[row['Field']] = row

cname = OrderedDict()
cname['CHROM'] = None
cname['POS'] = None
for s in _cname.split('\t'):
    if s in annot_dict:
        cname['_'.join([annot_dict[s]['Block'], annot_dict[s]['Field']])] = None
cname = ','.join(cname.keys())

header = []
template = '##INFO=<ID={i},Number={n},Type={t},Description="{d}">\n'
for k, v in annot_dict.items():
    header.append(template.format(i='_'.join([v['Block'], v['Field']]),
                                  n=v['Number'],
                                  t=v['Type'],
                                  d=v['Description']))
header = ''.join(header)

vcf = ''.join(map(lambda x: ''.join('chr' + x), _body))
vcf = vcf.replace('; ', ';')
vcf = vcf.replace(', ', ',')
vcf = vcf.replace('\tN\t', '\t.\t').replace('\tN\t', '\t.\t')

chars_to_replace = {ord('='): ':', ord(';'): '|', ord(' '): '_'}
vcf = vcf.translate(chars_to_replace)


with open(snakemake.output['cname'], 'w') as fp:
    fp.write(cname)

with open(snakemake.output['header'], 'w') as fp:
    fp.write(header)

with open(snakemake.output['tab'], 'w') as fp:
    fp.write(vcf)
