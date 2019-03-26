#!/bin/bash
mkdir -p analyzed
nproc=`grep --count ^processor /proc/cpuinfo`
find ./dfoil/ -type f -name '*.dfoil' | parallel --slf $PBS_NODEFILE --wd $PBS_O_WORKDIR --jobs $nproc dfoil_analyze.py {} ">" analyzed/{/.}.analyzed
