#!/bin/bash
mkdir -p analyzed
find ./dfoil/ -type f -name '*.dfoil_alt' | parallel dfoil_analyze.py {} ">" analyzed/{/.}.analyzed_alt
