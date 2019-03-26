#!/bin/bash
nproc=`grep --count ^processor /proc/cpuinfo`
parallel --slf $PBS_NODEFILE --wd $PBS_O_WORKDIR --jobs $nproc 'summarizer_alt.sh < <(echo {})' ::: counts/*.counts
cat summary_alt/*.summary_alt > all.summary.alt.txt

