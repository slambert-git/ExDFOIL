#!/bin/bash
#This is for pasting loci together, a separate script helps the GNU parallel call in locus_bootstrap.sh work more easily

paste -d'\0' $(cat "$1") > "$1".boot
