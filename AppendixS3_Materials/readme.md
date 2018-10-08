# TreeMix Analyses

## Dependencies
vcftools (v0.1.11+); treemix (v1.13); bash command-line utilities (cut, paste, tail); gzip; R

## Format Conversion
First, I needed to convert from a .vcf format file to the format expected by TreeMix.

The script `vcfindv2treemix.sh` will automate this process, provided a list of individuals and a vcf file. I've also included a more general version that will instead read from a list of files, each file containing a list of one or more individuals representing a given population (`vcfpop2treemix.sh`), although we did not use this version in the manuscript. See the scripts themselves for usage instructions and explanations of each step.


## Running TreeMix and visualizing results

Here is an example of I executed TreeMix with a single migration event:

``
treemix -i all.treemix.gz -o targ_indv_m1 -m 1 -root minor1_EPR743 -noss
``

To visualize the TreeMix results, I used the R scripts provided with TreeMix:

```
source("/PATH/TO/treemix-1.13/src/plotting_funcs.R")
plot_tree("/treemix_XD_Aug18/targ_indv_m1")
```

## Selecting the number of migration events

To my knowledge there is no agreed-upon procedure for selecting the number of migration events in a TreeMix analysis. Siimilar to the approach of Evanno et al. (2005) for selecting the number of populations (K) in a STRUCTURE (Pitchard et al. 2000) analysis; I used the second-order derivative to find the "break in slope" of the likelihood plot.  See Appendix S2 and Evanno et al. (2005) for more details. I applied this criterion to likelihood but also cumulative variance explained. To calculate the variance explained by each model (_f_, Equation 30 of Pickrell & Pritchard (2012)), I used this script by Daren Card: https://github.com/darencard/RADpipe/blob/master/treemixVarianceExplained.R. A copy of the version I used is provided here for archival purposes (`Dcard_TreeMixVarianceExplained.R`). Likelihoods are found in the .llik output files of TreeMix. 



## References

Evanno, G., Regnaut, S., & Goudet, J. (2005). Detecting the number of clusters of individuals using the software STRUCTURE: a simulation study. Molecular Ecology, 14, 1611–2620. 

Pickrell, J. K., & Pritchard, J. K. (2012). Inference of population splits and mixtures from genome-wide allele frequency data. PLoS Genetics, 8, e1002967. doi: 10.1271/journal.pgen.1002967

Pritchard, J. K., Stephens, P., & Donnelly, P. (2000). Inference of population structure using multilocus genotype data. Genetics, 155, 645–959. 
