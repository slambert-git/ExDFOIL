#!/bin/bash
## filt_and_thin.sh
##
## This script will accept as command-line arguments: 1) a vcf file 2) a directory containing names files (four individuals, one on each line) and 3) a file containing the name of an outgroup sample
## The script will then produce fasta files for each set of individuals. These fasta files will have at most one SNP per locus, and each SNP will be informative for DFOIL.
## It is highly advisable to run this script in a clean directory (no extraneous files) to avoid accidental removal of files.
## This script requires GNU parallel, perl, vcftools (v0.1.15), and the script vcf_tab_to_fasta_alignment_sml.pl to be in the working directory (original vcf_tab_to_fasta_alignment.pl script by CM Bergey: https://code.google.com/archive/p/vcf-tab-to-fasta/)


##Get command line arguments
vcf=$1
names=$2
OG=$3

## Select only relevant individuals, remove any sites with missing data
parallel "vcftools --vcf $vcf --keep <(cat {} $OG) --max-missing 1 --recode --out {/}.filt1" ::: $names/*

## Extract the header of the vcf file. Then, extract only positions that have no heterozygotes, and at least two homozygotes for each allele
parallel "cat <(head -n `grep -n "#CHROM" "$vcf" | cut -d':' -f1` {/}.filt1.recode.vcf) <(grep -v "0/1" {/}.filt1.recode.vcf | grep "0/0.*0/0" | grep "1/1.*1/1") > {/}.filt2.vcf" ::: $names/*

## Remove intermediate files
rm -rf *.filt1.recode.vcf

## Now select one SNP per locus. By specifying a value of "--thin" greater than the length of a locus, we ensure that only one SNP per locus will be retained
parallel 'vcftools --vcf {/}.filt2.vcf --thin 9999 --recode --recode-INFO-all --out {/}.filt3' ::: $names/*

## Remove intermediate files
rm -rf *.filt2.vcf

## Convert the final vcf files into fasta files
parallel 'cat {} | vcf-to-tab > {}.tab' ::: *.filt3.recode.vcf
parallel 'perl vcf_tab_to_fasta_alignment_sml.pl -i {} > {.}.fasta' ::: *.filt3.recode.vcf.tab

## Remove intermediate files
rm -rf *.filt3.recode.vcf
rm -rf *.filt3.log
rm -rf *.tab
rm -rf *.tab_clean

