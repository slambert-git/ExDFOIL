# Exhaustive *D*<sub>FOIL</sub> (Ex*D*<sub>FOIL</sub>)

This repository contains scripts and example data for the "exhaustive" *D*<sub>FOIL</sub> (https://github.com/jbpease/dfoil) analyses of Lambert et al. "Inferring historical introgression using RADseq and *D*<sub>FOIL</sub>: power and pitfalls revealed in a case study of spiny lizards (*Sceloporus*)" (in press, Molecular Ecology Resources). The idea behind "Ex*D*<sub>FOIL</sub>" is simply the application of the *D*<sub>FOIL</sub> method for inferring introgression to all combinations of sequences from a multiple sequence alignment that meet the assumptions of *D*<sub>FOIL</sub>, according to a user-defined, rooted phylogenetic tree. The Ex*D*<sub>FOIL</sub> helper scripts will automate and parallelize this process, useful when the number of unique combinations of individuals to consider is large (e.g., >200,000 as in the manuscript). Example scripts for summarizing and visualizing the results over phylogenetic and geographic space in R are also provided. Scripts to run single-site-per-locus and bootstrap resampling analyses are found in the AppendixS2 folder. Scripts for converting from .vcf to TreeMix format (using individuals or populations) are found in the AppendixS3 folder. 

## What's it for?
In the manuscript, we combine this Ex*D*<sub>FOIL</sub>  approach with RADseq data to assess the evidence for nuclear introgression between two spiny lizard species for which mitochondrial data independently suggests recurrent introgression. We think the Ex*D*<sub>FOIL</sub> approach could also be used as a tool for data exploration without a specific a-priori hypothesis for introgression.

## Disclaimer / License
Ex*D*<sub>FOIL</sub> is a collection of R and shell scripts for 1) selecting appropriate combinations of taxa for *D*<sub>FOIL</sub> (https://github.com/jbpease/dfoil) given a rooted phylogenetic tree, 2) running *D*<sub>FOIL</sub> tests in parallel using GNU parallel (https://www.gnu.org/software/parallel/), and 3) summarizing and visualizing the results in R. 

It is *not* standalone software, and it does *not* alter the underlying *D*<sub>FOIL</sub> method in any way. It is provided under a GNU General Public License (see `LICENSE.txt`). 

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

## Dependencies
Unix shell (tested with GNU bash v4.3.48(1)-release and 4.1.2(2)-release), GNU awk (tested with v3.1.7 and v4.1.3), GNU parallel (tested on 20160722 and 20141022), R v3.4.1 and the packages stringr v1.0.0 / phytools v0.6-44 / ape v5.0 / ggtree v1.10, and *D*<sub>FOIL</sub> https://github.com/jbpease/dfoil (commit on 09-19-2018). Also required is `selectSeqs.pl` by Dr. Naoki Takebayashi (found in `Scripts/`). All versions provided are those tested on; older or younger versions may or may not work. 

Note that the scripts for Stage 2) assume that you have the scripts from `Scripts/` in your working directory with executable permissions (or $PATH), as well as the scripts of *D*<sub>FOIL</sub>.

## Quick Start
### Warning: Prior results will be overwritten. Start in a clean directory.

### Select taxa and run *D*<sub>FOIL</sub> tests:
You can execute the selection of taxa and run *D*<sub>FOIL</sub> on the results all at once using `run_ExDFOIL.sh`. You must provide four command-line arguments in the following order : 1) a plaintext list of taxa, one on each line (`mynamesfile`), 2) a rooted phylogenetic tree containing at least all of the taxa of the list (`mytreefile`) 3) a .fasta file containing sequence data for at least all of the taxa (`myfastafile`) 4) a sample to use as the outgroup for *D*<sub>FOIL</sub> (`myoutgroup`). The script will select taxa based on the tree (Stage 1 below) and then execute Ex*D*<sub>FOIL</sub> in parallel on all the corresponding four-taxon subtrees (Stage 2 below). For examples of how I summarized and visualized our results in R; see "Stage 3: Summarization and Visualization" below. 


usage:
``./run_ExDFOIL.sh mynamefiles mytreefile myfastafile myoutgroup
``

You can use the files in `ExampleData/` to test the pipeline:

```
mkdir test/
cd test/
../Scripts/run_ExDFOIL.sh ../ExampleData/ornatus_names.txt ../ExampleData/ornatus_tree.txt ../ExampleData/oberon_ornatus_reduced.fasta ../ExampleData/minorOG.txt
```

Note that by default, all the output files of *D*<sub>FOIL</sub> are saved. For the example data, this will be >100,000 small files.

### Just select taxa:

To just select taxa for *D*<sub>FOIL</sub>, you will need  1) a list of taxa (`mynamesfile`) and 2) a rooted phylogenetic tree (`mytreefile`):
    
``DFOIL_Picker.R mynamesfile mytreefile``


### Just run exhaustive *D*<sub>FOIL</sub>:

To run all *D*<sub>FOIL</sub> tests in parallel, you will need 1) A list of taxon combinations (`mynames`) formatted like the output of `DFOIL_Picker.R` 2) a fasta file (`myfasta`) and 3) a file containing the name of the outgroup sequence (`myoutgroup`). 

```
## convert fasta files to count files
fasta2foiler.sh mynames myfasta myoutgroup

## run dfoil
dfoiler_alt.sh

## summarize the results
parallel 'summarizer_alt.sh < <(echo {})' ::: counts/*.counts
cat summary_alt/*.summary_alt > all.summary.alt.txt
```

## Tutorial
This section will guide the user through the selection of taxa, application of *D*<sub>FOIL</sub> in parallel, and subsequent visual summaries of results conducted for Lambert et al. (submitted) step-by-step. It is divided into three major stages: *__1) Selection of Taxa__*; *__2) Execution of D<sub>FOIL</sub> using GNU parallel__*; and *__3) Summarizing and Visualizing Results__*. Example input files provided, allowing the user to reproduce the analyses of the targeted dataset with reduced-individual sampling from Lambert et al. (submitted). Note however that there are >30,000 tests to run in this case, and >100,000 output files will be produced. Using 28 cores on the University of Arizona HPC, running Stage 2) for the example data took between 1.5 and 2 hours. Computational time should scale roughly linearly with the number of processors.

## Stage 1: Selection of Taxa
The R script `DFOIL_Picker.R` will accept as standard input the file paths of (1) a list of taxa and (2) a rooted phylogenetic tree; and return all unique sets of four taxa that are arranged in a symmetric tree, listing the younger clade first. It is important that the younger clade is listed first because the *D*<sub>FOIL</sub> script `fasta2dfoil.py` expects this, and if the order is switched, ancestral introgression signatures are not interpretable (Pease & Hahn 2015). The members of each possible symmetrical four-taxon subtrees are written to a line of `./DFOIL_picked.txt` as e.g. "taxon1 taxon2 taxon3 taxon4". 

Note that `DFOIL_Picker.R` will not check if your tree is rooted for you! It can be executed as follows:

    chmod +x DFOIL_Picker.R
    Rscript DFOIL_Picker.R mynamesfile mytreefile 

Where `mynamesfile` is the path to a plain-text file of taxon names, each on a separate line, and `mytreefile` is the path to a Newick-format treefile that contains (at least) all of the taxa in the names file. Example input files are provided as `ornatus_names.txt` and `ornatus_tree.txt`. 

For the  manuscript, I excluded combinations that did not have at least one representative of *S. ornatus* and one representative of *S. oberon*, using grep on the output of `DFOIL_Picker.R`:

    grep "oberon" DFOIL_picked.txt | grep "ornatus" > names_filtered.txt

You may want to do something similar if there are hypotheses that you're not interested in testing; for example, tests involving only one species. We will use this filtered file,  which should contain 32,368 unique combinations, for the subsequent stages of the tutorial.


## Stage 2: Running *D*<sub>FOIL</sub>  with GNU Parallel

### Getting site-pattern counts

We then use the *D*<sub>FOIL</sub> script `fasta2dfoil.py` to get the site-pattern count data for each of our tests, parallelizing using GNU parallel. This step uses the script `fasta2foiler.sh` with three command line arguments:

    fasta2foiler.sh mynames myfasta myoutgroup
 
  `mynames` is the path to the file containing names as formatted by `DFOIL_Picker.R` (e.g., `names_filtered.txt` if following the tutorial)

  `myfasta` is the path to a fasta file containing (at least) all individuals listed ("oberon_ornatus_reduced.fasta" for the example data). 

  `myoutgroup` is the path to a file with one line, containing the name of the outgroup sequence. ("minor_OG.txt" for the example data). 


The `fasta2foiler.sh` command will subset the fasta file containing all individuals to contain only the individuals in each test using N. Takebayashi's perl script `selectSeqs.pl`. This script will also ensure that the taxa in the correct order for *D*<sub>FOIL</sub>. However, process substitution `<(command here)` is used to pass the output directly to `fasta2dfoil.py`, so these subsetted fasta files are not written permanently to disk. Files containing the site-pattern counts for each test are written as e.g., taxon1.taxon2.taxon3.taxon4.counts in a folder `./counts/`.

Here is the content of the `fasta2foiler.sh` script:

```
#!/bin/bash
mkdir -p counts/
names=$1
fasta=$2
outgroup=$3

cat $names | parallel --env outgroup --env fasta 'fasta2dfoil.py <(selectSeqs.pl -f <(echo {} | tr " " $"\n"; cat '$outgroup') '$fasta') --out counts/$(echo {} | tr " " ".").counts --names $(echo {} | tr " " ","),$(cat '$outgroup')'
```

Please note that running the example data will take a while, there are >30,000 tests, and this step is the longest of any, per-test. Removing any sequences from the fasta file that are not used at all in the tests should save some computational time (you can use `selectSeqs.pl` for this). Using 28 processors on the UA HPC, this step still takes approximately one hour for the example data. 

You could of course save the .fasta files to disk; this would save computational time if the counts needed to be re-done (at the expense of disk space). There is a script in the AppendixS2 folder that will accept a directory of fasta files rather than a single fasta(` `). However, `selectSeqs.pl` is still run on the resulting fastas in order to ensure the taxa are in the correct order for *D*<sub>FOIL</sub>; this step could also be ran in advance to save more compuational time.


### Running *D*<sub>FOIL</sub>
We then run `dfoil.py` on each of the count files using the wrapper script `dfoiler_alt.sh`. In the same directory containing your "names/" and "counts/" directories, execute, e.g.:
  
    dfoiler_alt.sh

Here are the contents of the `dfoiler_alt.sh` script:
    
    #!/bin/bash
    mkdir -p dfoil
    mkdir -p precheck
    find ./counts/ -type f -name '*.counts' | parallel python dfoil.py --mode dfoilalt --infile {} --out dfoil/{/.}.dfoil_alt ">" precheck/{/.}.precheck_alt
         
For this example, we run `dfoil.py` using the `--mode dfoilalt` flag. The default `--mode dfoil` flag includes singleton site pattern counts (e.g., ABAAA), which can cause false positives when sample-specific error (or substitution rate) is sufficiently uneven (Pease & Hahn 2015). You can run `dfoil.py` while including singleton counts (using the `--mode dfoil` flag) with `dfoiler_noalt.sh` to follow along with the example analysis. 

The *D*<sub>FOIL</sub> tests results are written in the directory `./dfoil/` with the extension `.dfoil_alt` or `.dfoil_noalt`, depending on which script is used. The "precheck" files are written to the folder `./precheck/` with the extension `.precheck_alt` or `precheck_noalt`. See the *D*<sub>FOIL</sub> documentation for an explanation of the precheck files. 


### Summarizing tests
At this point, you could run the *D*<sub>FOIL</sub> script`dfoil_analyze.py` on each of the `dfoil.py` output files using the wrapper script `analyzer_alt.sh`. This script returns the result of the test in a more easily digestable format than the output of `dfoil.py`. It also returns summary statistics, but we don't use them here, as we are computing a single genomic mean value for each *D*<sub>FOIL</sub> test. This step is not necessary for any of our downstream analyses. We'll skip it here.
          
To summarize results, we first use `summarizer_alt.sh`, again using GNU parallel, collate results and get them ready for visualization in R. 

```
parallel './summarizer_alt.sh < $(echo {})' ::: counts/*.counts
```

Here's the `summarizer_alt.sh` script:

```
#!/bin/bash
mkdir -p summary
read file
fileraw=`basename $file`
echo $(echo "$fileraw" | cut -d'.' -f1-4 --output-delimiter=' ') $(tail -n 1 "$file" | cut -f4,5,7,11 | awk  '{print($4," ",$3," ",$2," ",$1)}') $(cat "dfoil/${fileraw%.counts}.dfoil_alt" | cut -f32 | tail -n 1) $(cat "dfoil/${fileraw%.counts}.dfoil_alt"  | cut -f11,13,17,19,23,25,29,31 | tail -n 1) > "summary/${fileraw%.counts}.summary_alt"
```
This is a bit ugly, but for each test, it will print the name of each taxon, the number of singleton counts for each taxon, the introgression result, and the *D*-statistic followed by the p-value for each of the four *D*<sub>FOIL</sub> components to a file in a directory `summary/` with the extension `.summary_alt`. 

### Once more from the top
As an example; here's how we would run each step of *D*<sub>FOIL</sub> pipeline, plus the additional summarization step, using the gnu parallel wrapper scripts:

    fasta2foiler.sh mynamesdir myfasta myoutgroup
    dfoiler_alt.sh
    parallel 'summarizer_alt.sh < <(echo {})' ::: counts/*.counts
    
To do the same while including singleton site-pattern counts, use `dfoiler_noalt.sh`, `analyzer_noalt.sh`, and `summarizer_noalt.sh`. You'll need to run these on the example data to reproduce our Figure 6 (see below). 
  
To to get all the test summaries in a single file for use in the next stage:

`cat summary_alt/*.summary_alt > all.summary.alt.txt`

## Stage 3: Summarizing and Visualizing Results

### Associating Sample Info
We will first associate the requisite sample information (e.g., batch, population, species) with each test summary. I do this using bash and grep with the `associate.sh` script.

To run `associate.sh`:
```
associate.sh all.summary.alt.txt mysampleinfo.txt
```

Where `all.summary.alt.txt` is the file containing test summaries (one per line), and `mysampleinfo.txt` is a file containing sample information. The example sample info file is `oberon_ornatus_sampleinfo.txt`. 

Here's a look at the format for the file containing sample information:

```
Individual batch popID speciesID subspeciesID
oberon10_JJW683p1 1 oberon10 oberon oberon_black
oberon10_JJW684p1 1 oberon10 oberon oberon_black
oberon10_JJW685 2 oberon10 oberon oberon_black

```

To use the `associate.sh` script, the only critical thing about your `mysampleinfo.txt` file is that the entries are separated by spaces, and that your unique sample identifiers are one of the column entries.


Here are the contents of `associate.sh`:

```
#!/bin/bash
tests=$1
info=$2
while read i; do IFS=" " read -r -a array <<< $i; echo $i `grep "${array[0]} "  "$info"` `grep "${array[1]} " "$info"` `grep "${array[2]} " "$info"` `grep "${array[3]} " "$info"`; done < "$tests" > "${tests%.*}_appended.txt
```

This will append the rows of the `mysampleinfo.txt` file corresponding to taxa P<sub>1</sub>, P<sub>2</sub>, P<sub>3</sub>, and P<sub>4</sub>, in that order, to each row of `all.summary.txt`. The output will be written to a file named `all.summary_appended.txt` Note that the name of each taxon will now be in two places in each row; this is redundant, but I kept it as a check that `associate.sh` is working correctly. 


### Getting DFOIL results into R
From this point on, all subsequent code snippets are in R. These will make use of the following packages, so make sure they are installed and loaded:

```
library(ape)
library(phytools)
library(RColorBrewer)
library(ggtree)
```
We are now ready to read the table containing test results and associated sample information (`all.summary.alt_appended.txt`) into R.

```
MyDFOIL<-read.table("all.summary.alt_appended.txt",header=FALSE)
MyDFOIL<-as.data.frame(MyDFOIL)
colnames(MyDFOIL)<-c("ind1","ind2","ind3","ind4","count1","count2","count3","count4","introg","DFO_stat","DFO_p","DIL_stat","DIL_p","DFI_stat","DFI_p","DOL_stat","DOL_p","name1","batch1","pop1","species1","subsp1","name2","batch2","pop2","species2","subsp2","name3","batch3","pop3","species3","subsp3","name4","batch4","pop4","species4","subsp4")
```
The third line specifies the name of each column in a character vector. These should be the name for each column of the `all.summary.alt.txt` file, followed by names for the columns of the `mysampleinfo.txt` file, repeated once for each taxon.

### Classifying introgression
To help summarize and visualize our many *D*<sub>FOIL</sub> results, I found helpful to bin introgression signatures into categories or "classes". I wrote a function for this, `introg_classifier.R` that will translate the "raw" *D*<sub>FOIL</sub> introgression result (i.e., the format returned by `dfoil_analyze.py`; e.g., "123"  or "31") into an introgression class, which might be based on species, subspecies, locality, or any other column of the sample information data frame. An example using species would translate "31" into "species3 -> species1", and "123" into "species1 / species2 <-> species3".

For reusability, the function requires that you specify the column number containing raw *D*<sub>FOIL</sub> introgression results, as well as the column numbers corresponding to the categories you wish to bin by for each taxon P<sub>1</sub> through P<sub>4</sub>. I use `apply()` to execute this function on each row of the dataframe, with column numbers passed to `apply` after the function name. 

To categorize by species using the example data:

```
source("introg_classifier.R")
MyDFOIL$introg_class <- unlist(apply(MyDFOIL,1,introg_classifier,9,21,26,31,36))
```

In the above example, the raw *D*<sub>FOIL</sub> introgression results are in column 9, the species of taxon P1 is in column 21, the species of taxon P2 is in column 26, the species of taxon P3 is in column 31, and the species of taxon P4 is in column 36. 


### Summary tables

To obtain broad summaries of *D*<sub>FOIL</sub> test results, I use `table()` and/or `prop.table()`, base functions in R. For instance, `table(MyDFOIL$introg_class)` will return the number of test results in each introgression "class", using the `introg_class` column created in the above subheading. 

In some cases, you may first want to restrict the dataframe to particular cases, e.g., considering only tests that returned an introgression signature. I use subscripting and logical statements for this. As an example: `MyDFOIL[MyDFOIL$introg_class != "none",]` will only keep the rows of the MyDFOIL object where the `introg_class` entry is *not* "none". Tables 1-6 of Lambert et al. (submitted) were all generated with the combination of subscripting and `table()` or `prop.table()`. 


### Summary and visualization of results by locality
To summarize *D*<sub>FOIL</sub> results by geographic locality (or any other column of the data frame), I use `aggregate()` to get the data in a format that can be plotted as a series of stacked bar plots using `barplot()`. The example below will recreate the stacked bar plots seen in Figure 4 of the manuscript. 

```
##First, we subset to the tests we are interested in comparing for Fig. 4. These tests have S. ornatus individuals for taxa P1 and P2, and one each of oberon-black and oberon-red for taxa P3 and P4. 
MyDFOIL_reduced<-MyDFOIL[(grepl("ornatus",MyDFOIL$species1) & grepl("ornatus",MyDFOIL$species2)) & ((grepl("oberon_black",MyDFOIL$subsp3) & grepl("oberon_di",MyDFOIL$subsp4)) | (grepl("oberon_black",MyDFOIL$subsp4) & grepl("oberon_di",MyDFOIL$subsp3))),]


##Aggregate
aggregate(pop1 ~ introg_class,data=MyDFOIL_reduced,FUN=table)->agg_p1
aggregate(pop2 ~ introg_class,data=MyDFOIL_reduced,FUN=table)->agg_p2
aggregate(pop3 ~ introg_class,data=MyDFOIL_reduced,FUN=table)->agg_p3
aggregate(pop4 ~ introg_class,data=MyDFOIL_reduced,FUN=table)->agg_p4

##These lines reformat the output of aggregate to prepare for plotting
as.matrix(agg_p1[,-1]) -> p1num
rownames(p1num)<-agg_p1[,1]
as.matrix(agg_p2[,-1]) -> p2num
rownames(p2num)<-agg_p2[,1]
as.matrix(agg_p3[,-1]) -> p3num
rownames(p3num)<-agg_p3[,1]
as.matrix(agg_p4[,-1]) -> p4num
rownames(p4num)<-agg_p4[,1]

##Below we combine the counts for pop1 and pop2, for simplicity, as these are pulled from the same group of populations (S. ornatus only). 
p1num + p2num -> p12num

##Remove empty columns (localities never used for a particular taxon P1-P4)
p12num[,-(1:10)] -> p12num_pruned
p3num[,-c(1:4,6:8,11,15:23)] -> p3num_pruned
p4num[,-c(1,5:6,8:23)] -> p4num_pruned

##Plot three sets of stacked bar plots, one for each locality set. These match the stacked bar plots of Figure 4. 
par(mfrow=c(1, 1), mar=c(6, 5, 4, 12) + 0.1)
barplot(prop.table(p4num_pruned,margin=2),xlim=c(0, ncol(prop.table(p4num_pruned,margin=2)) + 3),col=brewer.pal(nrow(prop.table(p4num_pruned,margin=2)), "Paired"),ylab="Proportion", las=3,legend.text=rownames(p4num_pruned),args.legend=list( x=12,bty = "n", xpd=TRUE))
barplot(prop.table(p3num_pruned,margin=2),xlim=c(0, ncol(prop.table(p3num_pruned,margin=2)) + 3),col=brewer.pal(nrow(prop.table(p3num_pruned,margin=2)), "Paired"),ylab="Proportion", las=3,legend.text=rownames(p3num_pruned),args.legend=list( x=16,bty = "n", xpd=TRUE))
barplot(prop.table(p12num_pruned,margin=2),xlim=c(0, ncol(prop.table(p12num_pruned,margin=2)) + 3),col=brewer.pal(nrow(prop.table(p12num_pruned,margin=2)), "Paired"),ylab="Proportion", las=3,legend.text=rownames(p12num_pruned),args.legend=list( x=25,bty = "n", xpd=TRUE))
```


### Summary and visualization of results across phylogeny
To summarize *D*<sub>FOIL</sub> results across phylogenetic space, we will first need read in a rooted phylogenetic tree containing all of the individuals. This tree can optionally be pruned to remove individuals not involved in any tests. The example file is `oberon_ornatus_pruned.tree`.

```
MyTree <- read.tree("oberon_ornatus_pruned.tree")
```

I use phytools `getMRCA()` function to return the node number of the most recent common ancestor of taxa P1 and P2 ("mrca12") and taxa P3 and P4 ("mrca34"). 
```
MyDFOIL$mrca12<-apply(MyDFOIL,1,function(x) getMRCA(MyTree,c(x[1],x[2])))
MyDFOIL$mrca34<-apply(MyDFOIL,1,function(x) getMRCA(MyTree,c(x[3],x[4])))
```

Now that the node numbers are associated with each test, we can summarize test results by the ancestral node(s) involved again using `aggregate()`.
```
##First subset to tests that contain two representatives of S. ornatus, two representatives of S. oberon, and one representative of oberon "black" to match Figure 3 of Lambert et al.

MyDFOIL$subsp_sig<-paste(MyDFOIL$subsp1,MyDFOIL$subsp2,MyDFOIL$subsp3,MyDFOIL$subsp4)
MyDFOIL_black<-MyDFOIL[grepl("ornatus.*ornatus",MyDFOIL$subsp_sig) & grepl("oberon.*oberon",MyDFOIL$subsp_sig) & grepl("black",MyDFOIL$subsp_sig),]


#Aggregate
aggregate(as.factor(mrca12) ~ introg_class,data=MyDFOIL_black,FUN=table) -> mrca12_fig
aggregate(as.factor(mrca34) ~ introg_class,data=MyDFOIL_black,FUN=table) -> mrca34_fig

```

Next, we reformat the output for `ggtree`:
```
#For the MRCA of Taxa P1 and P2
as.matrix(mrca12_fig[,-1]) -> mrca12_fig_num 
rownames(mrca12_fig_num) <- mrca12_fig[,1]
prop.table(mrca12_fig_num) -> mrca12_fig_prop
t(mrca12_fig_prop) -> mrca12_fig_prop_t
as.data.frame(mrca12_fig_prop_t) -> mrca12_fig_prop_df
mrca12_fig_prop_df$node <- rownames(mrca12_fig_prop_df)
pies12<-nodepie(mrca12_fig_prop_df,cols=1:5, color=c("gray","orange","yellow","brown","blue"))

#For the MRCA of Taxa P3 and P4
as.matrix(mrca34_fig[,-1]) -> mrca34_fig_num 
rownames(mrca34_fig_num) <- mrca34_fig[,1]
prop.table(mrca34_fig_num) -> mrca34_fig_prop
t(mrca34_fig_prop) -> mrca34_fig_prop_t
as.data.frame(mrca34_fig_prop_t) -> mrca34_fig_prop_df
mrca34_fig_prop_df$node <- rownames(mrca34_fig_prop_df)
pies34<-nodepie(mrca34_fig_prop_df,cols=1:5, color=c("gray","orange","yellow","brown","blue"))

```

Finally, for plotting with ggtree:
```
MyTree_GG <- ggtree(MyTree) 
pietest<-inset(MyTree_GG + geom_tiplab(size=2)+ ggplot2::xlim(0,8),pies34, width=0.06, hjust=0.125,vjust=-0.6)
pietest2<-inset(pietest,pies12, width=0.06, hjust=0.125,vjust=0.8)
print(pietest2)
```


### Examining singleton count ratios
Once again, the key functions here are `aggregate()` and `barplot()`. The example below will make a figure like our Figure 6. 

```
##Read in a data table with DFOIL results produced using "--mode dfoil"
MyDFOIL_noalt<-read.table("all.summary.noalt_appended.txt",header=FALSE)
MyDFOIL_noalt<-as.data.frame(MyDFOIL_noalt)
colnames(MyDFOIL_noalt)<-c("ind1","ind2","ind3","ind4","count1","count2","count3","count4","introg","DFO_stat","DFO_p","DIL_stat","DIL_p","DFI_stat","DFI_p","DOL_stat","DOL_p","name1","batch1","pop1","species1","subsp1","name2","batch2","pop2","species2","subsp2","name3","batch3","pop3","species3","subsp3","name4","batch4","pop4","species4","subsp4")


## Get the ratio of singleton counts between P3 and P4:
MyDFOIL$ratio34<-MyDFOIL$AABAA / MyDFOIL$AAABA
MyDFOIL_noalt$ratio34<-MyDFOIL_noalt$AABAA / MyDFOIL_noalt$AAABA

##Aggregate
aggregate(ratio34 ~ introg_standard, data=MyDFOIL,FUN=mean) -> MyDFOIL_ratio34
aggregate(ratio34 ~ introg_standard, data=MyDFOIL_noalt,FUN=mean) -> MyDFOIL_noalt_ratio34

##Remove the row for introgression signature "23" from the "noalt" output of aggregate - as we have nothing to compare it to for the "alt" output
MyDFOIL_noalt_ratio34<-MyDFOIL_noalt_ratio34[-5,]

##Remove the row for introgression signature "na" fro the alt output of aggregate - as we have nothing to compare it to for the noalt output
MyDFOIL_ratio34<-MyDFOIL_ratio34[-10,]


#Combine the outputs of aggregate - can double check if rows are in the same order using this output
cbind(MyDFOIL_ratio34, MyDFOIL_noalt_ratio34) -> countratio_df

#Some reformatting
countratio_df[,-c(1,3)] -> countratio_df
rownames(countratio_df)<-MyDFOIL_ratio34[,1]

#Plotting
par(mfrow=c(1, 1), mar=c(6, 5, 4, 14.5) + 0.1)
barplot(t(as.matrix(countratio_df)),beside=TRUE,col=c("black","grey"),ylab="Ratio of P3:P4 Single Counts", las=3,legend.text=c("No Singleton Counts (dfoil_alt)","With Singleton Counts (dfoil)"),args.legend=list( x=63,bty = "n", xpd=TRUE))
```


### Examining batch effects
To examine how batch effects might influence our results, we compared the "batch signatures" of our tests to the results. We defined "batch signature" as simply the membership of taxa P<sub>1</sub> through P<sub>4</sub> to either batch 1 or batch 2, for example, "1112" would indicate that taxa P<sub>1</sub>, P<sub>2</sub>, and P<sub>3</sub> are from batch one, and taxon P<sub>4</sub> is from batch 2. To get these batch signatures as a new column:

`MyDFOIL$batchsig<-paste(MyDFOIL$batch1,MyDFOIL$batch2,MyDFOIL$batch3,MyDFOIL$batch4,sep="")`

And here's example code for generating a plot like our Figure 5:

```
##First subset to tests that contain at least one representation of oberon-black, to match Figure 5
MyDFOIL_black<-MyDFOIL[grepl("oberon_black",MyDFOIL$subsp1) | grepl("oberon_black",MyDFOIL$subsp2) | grepl("oberon_black",MyDFOIL$subsp3) | grepl("oberon_black",MyDFOIL$subsp4),]

##Get batch signatures
MyDFOIL_black$batchsig<-paste(MyDFOIL_black$batch1,MyDFOIL_black$batch2,MyDFOIL_black$batch3,MyDFOIL_black$batch4,sep="")

##Aggregate and plot
aggregate(introg ~ batchsig,data=MyDFOIL_black,FUN=table)->batchsig_fig
batchsig_fig[,-1]->batchsig_num
rownames(batchsig_num)<-batchsig_fig[,1]
apply(batchsig_num,1,prop.table)-> batchsig_props
par(mfrow=c(1, 1), mar=c(6, 5, 4, 6) + 0.1)
barplot(batchsig_props,legend.text=colnames(batchsig_num),col=brewer.pal(12,"Paired"),args.legend=list( x=25,bty = "n", xpd=TRUE),las=3)

```


