# Addressing linkage with sub-sampling and bootstrapping

## Single-site-per-locus analyses

Before sampling a single SNP per locus, I first filtered the pool of possible SNPs to make sure that they could be used by dfoil (specifically, the `dfoilalt` mode, which does not use singleton counts). The entire process is as follows:

1) Reducing the vcf file to the four individuals used in a given test (P1 - P4, plus the outgroup)

2) Removing any missing data

3) Removing any heterozygous sites

4) Removing any sites for which there are not at least two homozygotes for each allele (i.e., no singleton counts).

5) Select a single SNP per RAD locus. 

The script `filt_and_thin.sh` will accomplish these steps in parallel when provided as command line arguments: 1) a .vcf file 2) a path to a names directory (names files formatted as as in main ExDFOIL analyses), and 3) a file containing the outgroup sample. 

The script requires GNU parallel, vcftools v0.1.15, and a perl script originally by CM Bergey (https://code.google.com/archive/p/vcf-tab-to-fasta/) that I made a slight adjustment to (to handle missing data coded as "./." instead of "./"). My version is provided here as `vcf-tab-to-fasta-sml.pl`. This script needs to be in the working directory, which I also suggest is a clean directory containing no extraneous files, to avoid accidental file deletion.

Once the fasta files for each test are created, I used a slightly modified version of the `fasta2foiler.sh` script used in the main ExDFOIL pipeline to acquire count data from each fasta file. This modified version (`fasta2foiler_premadefasta.sh`) is provided here. The only difference is that this script will accept directory of fasta files created using the `filt_and_thin.sh` script, rather than a single fasta file. All remaining steps of the ExDFOIL pipeline can be run normally.


## Locus bootstrapping analyses

To generate bootstrapped datasets by resampling entire ddRAD loci, I use RAxML to split the alignment, the command-line utility "rl" to generate bootstrapped lists of loci, Unix command-line utilities (cut/paste) to create a phylip-format bootstrapped alignment, and a perl script to convert fo fasta format for use by DFOIL. These steps can be executed using the script `locus_bootstrap.sh`. This script will accept as command-line arguments: 1) a phylip or fasta format file containing the sequence alignment 2) a RAxML-format partition file delimiting the loci within the alignment and 3) the number of replicates to be created. A few directories and many intermediate files will be produced, but cleaned up by the script. The resulting bootstraps will be located in a new directory `bootstraps/`. Once again I highly suggest working in a clean directory, as intermediate files are removed using globs.

The script requires Unix shell utilities (cut/paste/head/tail), GNU parallel, rl v0.2.7 (https://arthurdejong.org/rl/), RAxML v8, two helper scripts `paster.sh` and `phylip_repair.sh`, and the script `phylip2fasta_sml.pl`, a slightly modified version of N. Takebayashi's script (http://raven.wrrb.uaf.edu/~ntakebay/teaching/programming/perl-scripts/phylip2fasta.pl). My modification is simply to allow the use of sample IDs of up to 25 characters.

To save time, it is helpful to reduce the original phylip or fasta file to just the individuals that you are interested in running bootstraps for before running `locus_bootstrap.sh`. 
