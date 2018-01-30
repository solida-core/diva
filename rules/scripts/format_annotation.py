
with open(snakemake.input[0], 'r') as fp:
    cname = fp.readline()
    body = fp.readlines()

cname = cname.translate({ord('\t'): ','})
strings_to_replace = (('Chromosome', 'CHROM'), ('StartPositionHg19', 'POS'),
                      ('(', '\('))
for s in strings_to_replace:
    cname = cname.replace(s[0], s[1], 2)

vcf = ''.join(map(lambda x: ''.join('chr' + x), body))
chars_to_replace = {ord('='): '|', ord(';'): '|', ord(' '): '|'}
vcf = vcf.translate(chars_to_replace)

with open(snakemake.output['cname'], 'w') as fp:
    fp.write(cname)

with open(snakemake.output['tab'], 'w') as fp:
    fp.write(vcf)
