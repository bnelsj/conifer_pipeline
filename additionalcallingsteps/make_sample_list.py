#!/usr/bin/python

import conifertools

#Get configuration options
with open('Makefile', 'r') as make_reader:
    for line in make_reader:
        if line.find('conifer_file =') != -1:
            conifer_file = line.split('=')[1].strip()
            break

with open('config.sh', 'r') as config_file:
    for line in config_file:
        if line.find('PROJECT_DIR=') != -1:
            project_dir = line.split('=')[1].strip()

outfile = project_dir + '/batch_conifer_sample_list.txt'

print conifer_file, outfile

p = conifertools.ConiferPipeline(conifer_file)

with open(outfile, 'w') as outf:
    for sample in p.samples:
        outf.write(sample+'\n')

