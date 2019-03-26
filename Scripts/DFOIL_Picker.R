#!/usr/bin/env Rscript
#Author: Shea M. Lambert

##package dependencies 
if(!require(ape)){
    install.packages("ape")
    library(somepackage)
}
if(!require(phytools)){
    install.packages("phytools")
    library(somepackage)
}
if(!require(stringr)){
    install.packages("stringr")
    library(somepackage)
}


##Usage: Run this script using "Rscript DFOIL_Picker.R mynamesfile mytreefile" in the directory containing these files. 
##Output will be written as "myoutput.txt" 
##Example files for the names file (plain-text) and tree file (newick format) are provided as ornatus_names.txt and ornatus_tree.txt


##Read Input from Command Line
commandArgs(trailingOnly = TRUE) -> args

##read list file
scan(paste(args[1]),what="character") -> names

##read tree file
read.tree(paste(args[2])) -> tree

#drop all but names
tree=drop.tip(tree,setdiff(tree$tip.label,names))

#get node heights
heights=nodeHeights(tree)

#get edge heights
edgeheights=cbind(heights[,1],tree$edge[,1])

#get number of taxa
tiplen=length(tree$tip.label)

#get list of nodes and heights
nodes=edgeheights[!duplicated(edgeheights[,2]),]


#get all descendants for all nodes
get_descs<-function(node){
  desc=getDescendants(tree,node)
  return(desc)
}

alldescs=lapply(nodes[,2],get_descs)


#get all clades of size 2 with MRCA at each node
get_pairs<-function(node){
  desc1=alldescs[[which(nodes[,2] == node)]] 
  child1=desc1[1]
  child2=desc1[2]
  if(child1 <= tiplen){
    cd1=tree$tip.label[child1]
  } else {
    cdtemp=alldescs[[which(nodes[,2] == child1)]]
    cdtemp=cdtemp[cdtemp <= tiplen]
    cd1=tree$tip.label[cdtemp]
  }
  if(child2 <= tiplen){
    cd2=tree$tip.label[child2]
  } else {
    cdtemp=alldescs[[which(nodes[,2] == child2)]] 
    cdtemp=cdtemp[cdtemp <= tiplen]
    cd2=tree$tip.label[cdtemp]
  }
  result=expand.grid(cd1,cd2)
  return(apply(result,1,paste,collapse=" "))
}

allpairs=lapply(nodes[,2],get_pairs)


#prepare results vector
results=vector()

#get all valid combinations for each node
for(i in nodes[,2]){
  h1=nodes[nodes[,2] == i ,1]
  desc1=alldescs[[which(nodes[,2] == i)]] 
  compnodes=nodes[!(nodes[,2] %in% c(i,desc1)) & nodes[,1] >= h1,2]
  if(length(compnodes) == 0){
    next
  } else{
    compairs=unlist(lapply(compnodes,function(x) allpairs[[which(nodes[,2] == x)]]))
    nextres=apply(expand.grid(compairs,allpairs[[which(nodes[,2] == i)]]),1,paste,collapse=" ")
    results=c(results,nextres)
  }
}


#duplicate checking: duplicates could occur if there are nodes with identical heights. 
taxsort<-function(vec){
  splt=strsplit(vec," ")
  sorted=sort(splt[[1]])
  return(paste(sorted,collapse=" "))
}

sortvec=lapply(results,taxsort)

results=results[!duplicated(unlist(sortvec))]

##write results
write.table(results,file="./myoutput.txt",quote=FALSE,row.names=FALSE,col.names=FALSE)





