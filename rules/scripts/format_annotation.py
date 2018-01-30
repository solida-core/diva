
with open(snakemake.input[0], 'r') as fp:
    header = fp.readline()
    body = fp.readlines()

header = header.translate({ord('\t'): ','})
strings_to_replace = (('Chromosome', 'CHROM'), ('StartPositionHg19', 'POS'))
for s in strings_to_replace:
    header = header.replace(s[0], s[1], 1)

vcf = ''.join(map(lambda x: ''.join('chr' + x), body))
chars_to_replace = {ord('='): '|', ord(';'): '|', ord(' '): '|'}
vcf = vcf.translate(chars_to_replace)

with open(snakemake.output[0], 'w') as fp:
    fp.write(header)
    fp.write(vcf)
