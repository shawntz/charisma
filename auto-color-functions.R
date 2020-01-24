###
# @Author: Shawn T. Schwartz
# @Email: <shawnschwartz@ucla.edu>
# Source Functions for Automatic Color Detection
###

#### Required Libraries ####
reqlibs <- c("colordistance", "segmented", "tidyverse")
if (length(setdiff(reqlibs, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(reqlibs, rownames(installed.packages())))  
}

library(colordistance)
library(segmented)
library(tidyverse)

##temp##
wd <- "~/Developer/automatic-color"
setwd(wd)
##temp##

#### Helper Functions ####
getImageList <- function(path, ABSPATH=0) {
  if(ABSPATH == 1) {return(paste0(path,"/",list.files(path = path)))}
  else {return(list.files(path = path))}
}

executeKmeans <- function(imglist,minK=1,maxK=5,nstart=50,iter.max=15,lowerR=0,lowerG=0.6,lowerB=0,upperR=0.4,upperG=1,upperB=0.4,color.space="rgb") {
  #default color lower and upper bins are for detecting uniform lime green
  outputList <- list()
  for (imgs in 1:length(imglist)) {
    print(paste0("Analyzing Image #",imgs,": ",imglist[imgs]))
    clusterList <- list()
    for(ii in minK:maxK) {
      cat(paste0("Testing k=",ii," for: ",imglist[imgs],"\n"))
      clusterList[[ii]] <- getKMeansList(imglist[imgs],bins=ii,nstart=nstart,iter.max=iter.max,lower=c(lowerR,lowerG,lowerB),upper=c(upperR,upperG,upperB),color.space=color.space)
    }
    outputList[[imgs]] <- clusterList
  }
  return(outputList)
}

splitImageFile <- function(filename,extension,path) {
  nopath <- str_remove(filename,paste0(path,"/"))
  return(strsplit(nopath,extension)[1])
}

getWCSSList <- function(kmeanslist) {
  wcssList <- list()
  allnames <- rep(NA, length(kmeanslist))
  for(images in 1:length(kmeanslist)) {
    wcss <- rep(NA, length(kmeanslist))
    for(clusters in 1:length(kmeanslist[[images]])) {
      imgname <- names(kmeanslist[[images]][clusters][[1]])
      cat(paste0("Obtaining values for: ", imgname, " (k=",clusters,")\n"))
      wcss[clusters] <- get(imgname,kmeanslist[[images]][clusters][[1]])$tot.withinss
    }
    allnames[images] <- imgname
    wcssList[[images]] <- wcss
  }
  names(wcssList) <- allnames
  return(wcssList)
}

testlist <- getImageList("testing",1)
testclusterexecution <- executeKmeans(testlist)

