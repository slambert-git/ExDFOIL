#!/usr/bin/env Rscript
#Author: Shea M. Lambert

##package dependencies 
##user must install these prior to running the function
library(ape)
library(phytools)
library(combinat)

##Usage: Run this script using "Rscript DFOIL_Picker.R mynamesfile mytreefile" in the directory containing these files. 
##Output will be written as "myoutput.txt" 
##Example files for the names file (plain-text) and tree file (newick format) are provided as alloborn.txt and obornfull_point_dated.tre

###Tree_Eval subfunction
tre_eval<-function(nam,tre){
  
  #must provide four taxa for DFOIL
  stopifnot(length(nam) == 4)
  
  #Prune all but the four taxa in "list" from the tree 
  drop.tip(tre,setdiff(tre$tip.label,nam)) -> evaltre

  #Find reciprocally monophyletic clades of size 2
  getCladesofSize(evaltre,clade.size=2)-> clades
  
  #If there are two such clades, find which is older, so they may be returned in the order expected by DFOIL
  if(length(clades)==2){
    #find which clade is P1/P2 and which is P3/P4
    clades[[1]]$edge.length[1] -> length1
    clades[[2]]$edge.length[1] -> length2  
    if((length1 >= length2) == TRUE){
      return(c(clades[[2]]$tip.label,clades[[1]]$tip.label))
    } else{
      return(c(clades[[1]]$tip.label,clades[[2]]$tip.label))
    }
  } 
} 

###DFOIL_picker function (Applies tre_eval subfunction to each possible four-taxon combination)
DFOIL_picker<-function(names,tree){
  
  #get all unique combinations of names
  combn(names,4)->comb_names
  
  #apply the tree evaluation subfunction to each
  apply(comb_names,2,function(x) tre_eval(x,tree))->full_list
  
  #remove combinations that failed evaluation
  full_list <- full_list[-which(sapply(full_list, is.null))]
  
  #prepare output file
  output <- matrix(unlist(full_list), ncol = 4, byrow = TRUE)
  
  #write output file
  write.table(output,file="./myoutput.txt",quote=FALSE,row.names=FALSE,col.names=FALSE)
}



##Read Input from Command Line
commandArgs(trailingOnly = TRUE) -> args

##read list file
scan(paste(args[1]),what="character")-> names

##read tree file
read.tree(paste(args[2])) -> top

##Run Function - output saved to current working directory as "myoutput.txt"
DFOIL_picker(names,top)
