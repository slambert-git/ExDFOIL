#!/bin/bash
## vcfindv2treemix.sh
## Author: Shea M Lambert
# This script will accept a (1) a file containing individual names (1 on each line) and (2) a vcf file, and return a file that is ready for analysis in TreeMix (all.treemix.gz). 
# Usage example: "bash vcfindv2treemix.sh my_indvs.txt my_vcf.vcf"
# The first command-line argument must be the individuals file (my_indvs.txt), and the second must be the vcf file (my_vcf.vcf). 
# It's best to run this in 'clean' directory with no other files. In particular make sure there are no stray files with the extension .allelecounts
##

## Read command-line arguments
indvs=$1
vcf=$2

## For each individual, output the counts of each allele for all sites:
for i in `cat $indvs`
do 
vcftools --vcf $vcf --indv $i --counts
mv out.frq.count $i.frq.count
done

## Then, extract the allele counts in the format expected by TreeMix:
for i in `cat $indvs`
do 
paste <(cut -d: -f2 "$i".frq.count) <(cut -d: -f3 "$i".frq.count) | cut -f1,3 | tr $'\t' ',' | tail -n +2 > "$i".allelecounts
done

## Now combine these count files and give the file a header line identifying each individual/population:
cat <(tr $'\n' $'\t' < "$indvs") <(echo) <(paste *.allelecounts) > all.treemix

## Clean up intermediate files
for i in `cat $indvs`
rm $i.frq.count
rm $i.allelecounts
done

## Finally, gzip the file for input to TreeMix:
gzip all.treemix
