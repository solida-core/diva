import csv

with open(snakemake.input[0], 'r') as fp:
    _cname = fp.readline()
    _body = fp.readlines()

annot_dict = dict()
with open(snakemake.params.blocks, 'r') as csvfile:
    reader = csv.DictReader(csvfile, delimiter='\t')
    reader.__next__()
    print(reader.fieldnames)
    for row in reader:
        annot_dict[row['Field']] = row

cname = ['CHROM', 'POS']
for s in _cname.split('\t'):
    if s in annot_dict:
        cname.append('_'.join([annot_dict[s]['Block'], annot_dict[s]['Field']]))
cname = ','.join(cname)

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
