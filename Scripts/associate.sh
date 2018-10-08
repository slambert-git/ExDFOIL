#!/bin/bash
tests=$1
info=$2
while read i; do IFS=" " read -r -a array <<< $i; echo $i `grep "${array[0]} "  "$info"` `grep "${array[1]} " "$info"` `grep "${array[2]} " "$info"` `grep "${array[3]} " "$info"`; done < "$tests" > "${tests%.*}_appended.txt"
