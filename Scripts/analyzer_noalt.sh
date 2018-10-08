#!/bin/bash
mkdir -p analyzed
find ./dfoil/ -type f -name '*.dfoil' | parallel dfoil_analyze.py {} ">" analyzed/{/.}.analyzed
