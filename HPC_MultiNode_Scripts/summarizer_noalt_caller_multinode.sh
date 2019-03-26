#!/bin/bash
nproc=`grep --count ^processor /proc/cpuinfo`
parallel --slf $PBS_NODEFILE --wd $PBS_O_WORKDIR --jobs $nproc 'summarizer_noalt.sh < <(echo {})' ::: counts/*.counts
cat summary/*.summary > all.summary.noalt.txt
