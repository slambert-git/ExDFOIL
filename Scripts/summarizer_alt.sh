#!/bin/bash
mkdir -p summary
read file
fileraw=`basename $file`
echo $(echo "$fileraw" | cut -d'.' -f1-4 --output-delimiter=' ') $(tail -n 1 "$file" | cut -f4,5,7,11 | awk  '{print($4," ",$3," ",$2," ",$1)}') $(cat "dfoil/${fileraw%.counts}.dfoil_alt" | cut -f32 | tail -n 1) $(cat "dfoil/${fileraw%.counts}.dfoil_alt"  | cut -f11,13,17,19,23,25,29,31 | tail -n 1) > "summary/${fileraw%.counts}.summary_alt"

