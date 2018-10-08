#!/bin/bash
#Author: Shea M. Lambert

############################################################################
# Author: Shea M. Lambert
# This script will first select taxa from a rooted phylogenetic tree that meet the assumptions of DFOIL. It will then prepare input files and run DFOIL in parallel for all tests using the "dfoilalt" mode, which ignores singleton counts. 

# The command line arguments required are: 1) a plaintext list of taxa, one on each line (mynamesfile), 2) a rooted phylogenetic tree containing at least all of the taxa of the list (mytreefile) 3) a fastafile containing sequence data for at least all of the taxa (myfastafile) 4) a sample to use as the outgroup for DFOIL (myoutgroup)

# Copy all scripts in the Scripts/ folder to the current working directory or $PATH. The DFOIL scripts should also be in the current working directory or $PATH. 

# Prior results will be overwritten. Use a clean directory. 

# usage:
# run_ExDFOIL.sh mynamefiles mytreefile myfastafile myoutgroup mysampleinfo
#############################################################################

# read command line arguments
taxa=$1
tree=$2
fasta=$3
outgroup=$4


# Select Taxa
DFOIL_Picker.R $taxa $tree


##Convert fasta files to count files
fasta2foiler.sh DFOIL_picked.txt $fasta $outgroup

##run dfoil
dfoiler_alt.sh

## run dfoil_analyze
analyzer_alt.sh

## Summarize the results
parallel './summarizer_alt.sh < $(echo {})' ::: counts/*.counts
cat summary/*.summary_alt > all.summary.alt.txt

