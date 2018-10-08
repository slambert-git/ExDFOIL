#!/bin/bash
## locus_boostrap.sh
# This script will accept as command-line arguments: 1) a phylip or fasta format file containing the sequence alignment 2) a RAxML-format partition file delimiting the loci within the alignment 3) the number of replicates to be created and 4) a path to a RAxML 8 executable.
# It will produce bootstrapped alignments by randomly resampling loci with replacement. These alignments will contain the same total number of loci as the original alignment
# The resulting bootstrapped alignments will be in .fasta format and will be located in a new directory bootstraps/. 
# I highly suggest working in a clean directory, as intermediate files and directories are produced and later removed using globs. 

##This script requires:
# Unix shell utilities (cut/paste/head/tail)
# GNU parallel
# rl v0.2.7 (https://arthurdejong.org/rl/)
# RAxML v8 (you will pass the location/name of this executable as these may vary depending on installation)
# Two helper bash scripts: paster.sh and phylip_repair.sh 
# The perl script phylip2fasta_sml.pl, a slightly modified version of N. Takebayashi's script (http://raven.wrrb.uaf.edu/~ntakebay/teaching/programming/perl-scripts/phylip2fasta.pl). My modification is simply to allow the use of sample IDs longer than 25 characters.

## read command-line arguments
phy=$1
parts=$2
nreps=$3
myrax=$4

## split the alignment using RAxML
mkdir split/
"$myrax" -f s -q $parts -s $phy -m GTRGAMMA -n split

mv "$phy".* split

## remove the names and header from the phylip files
cd split/
parallel "cut -d' ' -f2 {} | tail -n +2 > {.}.raw" ::: *.phy
rm -rf *.phy
cd ../

## create bootstrapped lists of loci
nloci=`ls split/*.raw | wc -l`
mkdir bootlists
parallel "ls split/*.raw | rl -r -c $nloci | tr $'\n' ' ' > bootlists/bootlist.{1}" ::: `seq 1 1 "$nreps"`

## paste together bootstrap alignments
parallel bash paster.sh {} ::: bootlists/*

## retrieve the number of taxa and the names of each taxon
tr $'\t' ' ' < TRS.indvs.phy | cut -d' ' -f1 > phy_f1.txt

## restore the header and names to each bootstrapped alignment
parallel bash phylip_repair.sh {} ::: bootlists/*.boot

## convert to fasta format 
parallel 'perl phylip2fasta.pl {} > {.}.fasta' ::: bootlists/*boot.phy

##move fastas to final results folder
mkdir bootstraps/
mv bootlists/*.fasta bootstraps/

## clean up
rm -rf bootlists/
rm -rf split/
rm phy_f1.txt
