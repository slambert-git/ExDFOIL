#!/bin/bash
## vcfpop2treemix.sh
## Author: Shea M Lambert
# This script will accept (1) a list of files that define populations by listing individuals, 1 per-line and (2) a vcf file, and return a file that is ready for analysis in TreeMix (all.treemix.gz).
# Usage example: "bash vcfpop2treemix.sh my_pops.txt my_vcf.vcf"
# The first command-line argument must be the list of population files (my_pops.txt), and the second must be the vcf file (my_vcf.vcf). 
# It's best to run this in 'clean' directory with no other files. Intermediate files produced are removed using a glob. 
###

## Read command-line arguments
indvs=$1
vcf=$2

## For each individual, output the counts of each allele for all sites:
for i in `cat $indvs`
do 
vcftools --vcf $vcf --keep $i --counts
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
