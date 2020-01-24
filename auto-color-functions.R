###
# @Author: Shawn T. Schwartz
# @Email: <shawnschwartz@ucla.edu>
# Source Functions for Automatic Color Detection
###

#### Required Libraries ####
reqlibs <- c("colordistance", "segmented")
if (length(setdiff(reqlibs, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(reqlibs, rownames(installed.packages())))  
}

library(colordistance)
library(segmented)

##temp##
wd <- "~/Developer/automatic-color"
setwd(wd)
##temp##

getImageList <- function(path, ABSPATH=0) {
  if(ABSPATH == 1) {return(paste0(path,"/",list.files(path = path)))}
  else {return(list.files(path = path))}
}

##TODO: store list of cluster lists for each image, add color.space arg
###default color lower and upper bins are for detecting uniform lime green
executeKmeans <- function(imglist,minK=1,maxK=5,nstart=50,iter.max=15,lowerR=0,lowerG=0.6,lowerB=0,upperR=0.4,upperG=1,upperB=0.4) {
  outputList <- list()
  clusterList <- list()
  for (imgs in 1:length(imglist)) {
    print(paste0("Analyzing Image #",imgs,": ",imglist[imgs]))
    for(ii in minK:maxK) {
      print(paste0("Testing k=",ii," for: ",imglist[imgs]))
      clusterList[[ii]] <- getKMeansList(imglist[imgs],bins=ii,nstart=nstart,iter.max=iter.max,lower=c(lowerR,lowerG,lowerB),upper=c(upperR,upperG,upperB))
    }
    outputList[[imgs]] <- clusterList
  }
  return(outputList)
}


testclusterexecution <- executeKmeans(testlist)

