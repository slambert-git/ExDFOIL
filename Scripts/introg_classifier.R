introg_classifier<-function(x,colintrog,col1,col2,col3,col4){
  
  if(x[colintrog] == "123"){
    
    return(paste(x[col1],"/",x[col2],"<->",x[col3]))  
    
  } else if (x[colintrog] == "124"){
    
    return(paste(x[col1],"/",x[col2],"<->",x[col4]))  
    
  } else if (x[colintrog] == "13"){
    
    return(paste(x[col1],"->",x[col3]))
    
  } else if (x[colintrog] == "31"){
    
    return(paste(x[col3],"->",x[col1]))
    
  } else if (x[colintrog] == "24"){
    
    return(paste(x[col2],"->",x[col4]))
    
  } else if (x[colintrog] == "42"){
    
    return(paste(x[col4],"->",x[col2]))
    
  } else if (x[colintrog] == "23"){
    
    return(paste(x[col2],"->",x[col3]))
    
  } else if (x[colintrog] == "32"){
    
    return(paste(x[col3],"->",x[col2]))
    
  } else if (x[colintrog] == "14"){
    
    return(paste(x[col1],"->",x[col4]))
    
  } else if (x[colintrog] == "41"){
    
    return(paste(x[col4],"->",x[col1]))
    
  } else{
    return("none")
  }
  
}


#example:
#MyData$introg_class<-unlist(apply(MyData,1,introg_classifier,colintrog,col1,col2,col3,col4))
