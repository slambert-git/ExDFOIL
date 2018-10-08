#!/bin/bash
#This helper script will restore the header and sequence names of the boostrapped phylip sequences

#get the length of the alignment
len=`cat <(head -n1 $1) | wc -c`

#paste together the number of taxa and their names (previously output to phy_f1.txt by the main script, locus_bootstrap.sh) with the sequence length and actual sequences
paste -d' ' <(cat phy_f1.txt) <(cat <(echo -e "$len") $1) > $1.phy
