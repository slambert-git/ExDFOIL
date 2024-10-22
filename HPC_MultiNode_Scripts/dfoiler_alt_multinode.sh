#!/bin/bash
mkdir -p dfoil
mkdir -p precheck
nproc=`grep --count ^processor /proc/cpuinfo`
find ./counts/ -type f -name '*.counts' | parallel --slf $PBS_NODEFILE --wd $PBS_O_WORKDIR --jobs $nproc dfoil.py --mode dfoilalt --infile {} --out dfoil/{/.}.dfoil_alt ">" precheck/{/.}.precheck_alt
