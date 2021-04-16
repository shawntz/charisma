spatial_recurs<-function(data,color,threshold){
  xdf=nrow(data)
  ydf=ncol(data)
  newdf<-matrix(unlist(data),nrow = (xdf*ydf),ncol = 1)
  #return(newdf)
  #output<-sapply(newdf,function(x) ifelse(x==color,topfn(xdf,ydf,newdf,color),0))
  output <- apply(data, c(1,2), function(x) ifelse(x==color,topfn(xdf,ydf,newdf,color),0))
  return(output)
  finaldf<-matrix(unlist(output),nrow = xdf,ncol = ydf)
  return(finaldf)
  output<-which(finaldf>=threshold)
  return(output)
}

topfn<-function(xdf,ydf,newdf,color){
  count<-0
  row<-which(newdf==color)[1]
  count<-count+bottomfn(xdf,ydf,newdf,color,count,row)
  return (count)
}

bottomfn<-function(xdf,ydf,newdf,color,count,row){
  count<-1+count
  newdf[row]="done"
  if(row %% ydf==0){
    if(newdf[row-ydf]==color){
      row<-row-ydf
      return(count+bottomfn(xdf,ydf,newdf,color,count,row))
    }
    if(newdf[row+ydf]==color){
      row<-row+ydf
      return(count+bottomfn(xdf,ydf,newdf,color,count,row))
    }
    if(newdf[row-1]==color){
      row<-row-1
      return(count+bottomfn(xdf,ydf,newdf,color,count,row))
    }
  }
  if(row %% ydf==1){
    if(newdf[row-ydf]==color){
      row<-row-ydf
      return(count+bottomfn(xdf,ydf,newdf,color,count,row))
    }
    if(newdf[row+ydf]==color){
      row<-row+ydf
      return(count+bottomfn(xdf,ydf,newdf,color,count,row))
    }
    if(newdf[row+1]==color){
      row<-row+1
      return(count+bottomfn(xdf,ydf,newdf,color,count,row))
    }
  }
  if(row %% ydf>=2){
    if(newdf[row-ydf]==color){
      row<-row-ydf
      return(count+bottomfn(xdf,ydf,newdf,color,count,row))
    }
    if(newdf[row+ydf]==color){
      row<-row+ydf
      return(count+bottomfn(xdf,ydf,newdf,color,count,row))
    }
    if(newdf[row+1]==color){
      row<-row+1
      return(count+bottomfn(xdf,ydf,newdf,color,count,row))
    }
    if(newdf[row-1]==color){
      row<-row-1
      return(count+bottomfn(xdf,ydf,newdf,color,count,row))
    }
  }
  return(count)
}
