Sequence Alignments:
"ND4_uniq_Sep30_NoHybrid.fasta" -- This is the alignment used for phylogenetic analysis of the mitochondrial gene ND4 in BEAST2.

"TRS.Q30.DP3.MI50.G80.dDcust1.FIL.RM.AP.NI.MAC3.5P.consensus.phyl_red2.nocyaneus.no593.noA.fasta" -- This is the alignment file used for phylogenetic analysis of ddRADseq data, with "reduced" individual sampling of the clade-wide dataset.

"TRS.Q30.DP3.MI50.G80.dDcust1.FIL.RM.AP.NI.MAC3.5P.consensus.phyl_red2.obornfull.no593.noA.fasta" -- This is the alignment file used for phylogenetic analysis of ddRADseq data, with "full" individual sampling of the clade-wide dataset.

"TRS.Q30.DP3.BA.NI.MI01.recode.vcf.fasta" -- This is the alignment file used for DFOIL analysis of the targeted dataset (for both reduced and full individual sampling).



Phylogenetic Trees:
"RAxML_phylred2_no593_noA.rooted.tre" -- This is the phylogenetic tree estimated using RAxML and the clade-wide dataset with "reduced" individual sampling.

"RAxML_oborn_no593_noA.rooted.tre" -- This is the phylogenetic tree estimated using RAxML and the clade-wide dataset with "full" individual sampling.

"phylred2_point_dated_support.tre" -- This is the time-calibrated (using treePL) version of the phylogenetic tree estimated with the clade-wide dataset and "reduced" individual sampling.

"obornfull_point_dated.tre" -- This is the time-calibrated (using treePL) version of the phylogenetic tree estimated with the clade-wide dataset and "full" individual sampling.

"ND4.mcc.10pburn.tre" -- This is the time-calibrated phylogeny estimated from the mitochondrial gene ND4 using BEAST2. 


Miscellaneous Files:
"DAPC.bed" -- This is the .bed file used to remove batch-effect sites identified with DAPC.

"DAPC_samples_used" -- This is the list of samples used to identify batch-effects with DAPC.

"dDocent_filters_custom" -- This is our modified version of the dDocent_filters.sh script, used in filtering of variants. 
