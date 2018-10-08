#!/bin/bash
mkdir -p dfoil
mkdir -p precheck
find ./counts/ -type f -name '*.counts' | parallel dfoil.py --mode dfoil --infile {} --out dfoil/{/.}.dfoil ">" precheck/{/.}.precheck
