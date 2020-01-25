####
# @Author: Shawn T. Schwartz
# @Email: <shawnschwartz@ucla.edu>
# @Description: Source Functions for Automatic Color Detection
####

#### Install Required Libraries ####
reqlibs <- c("colordistance", "segmented", "tidyverse")
if (length(setdiff(reqlibs, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(reqlibs, rownames(installed.packages())))  
}

#### Load Required Libraries ####
library(colordistance)
library(segmented)
library(tidyverse)

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
      cat(paste0("\nTesting k=",ii," for: ",imglist[imgs],"\n"))
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
    wcss <- rep(NA, length(kmeanslist[[images]]))
    for(clusters in 1:length(kmeanslist[[images]])) {
      imgname <- names(kmeanslist[[images]][clusters][[1]])
      cat(paste0("Obtaining values for: ", imgname, " (k=",clusters,")\n"))
      wcss[clusters] <- get(imgname,kmeanslist[[images]][clusters][[1]])$tot.withinss
    }
    allnames[images] <- imgname
    wcssList[[images]] <- wcss
  }
  names(wcssList) <- allnames
  print(wcssList)
  return(wcssList)
}

getExtremes <- function(k_values, wcss_values) {
  extreme_xx <- max(k_values)
  extreme_yy <- max(wcss_values)
  extreme_xy <- wcss_values[which.max(k_values)]
  extreme_yx <- k_values[which.max(wcss_values)]
  x = c(extreme_yx, extreme_xx)
  y = c(extreme_yy, extreme_xy)
  return(data.frame(x,y))
}

fitExtremes <- function(extremes) {
  return(lm(extremes$y ~ extremes$x))
}

computeDistances <- function(k_values, wcss_values, extremesFit) {
  dists <- rep(NA, length(k_values))
  for(ii in 1:length(k_values)) {
    dists[ii] <- abs(coef(extremesFit)[2]*k_values[ii] - wcss_values[ii] + coef(extremesFit)[1]) / sqrt(coef(extremesFit)[2]^2 + 1^2)
  }
  return(dists)
}

getMaxDistances <- function(k_values, wcss_values, distances) {
  max_x_distance <- k_values[which.max(distances)]
  max_y_distance <- wcss_values[which.max(distances)]
  return(c(max_x_distance, max_y_distance, max(distances)))
}

getElbowK <- function(k_values, wcss_values, imgnames, visualize=0) {
  #inspired by http://www.semspirit.com/artificial-intelligence/machine-learning/clustering/k-means-clustering/k-means-clustering-in-r/
  extremes <- getExtremes(k_values, wcss_values)
  fit <- fitExtremes(extremes)
  distances <- computeDistances(k_values, wcss_values, fit)
  elbow_data <- getMaxDistances(k_values, wcss_values, distances)
  if (visualize == 1) {
    visualizeElbow(k_values, wcss_values, elbow_data, imgnames)
  }
  return(elbow_data)
}

visualizeElbow <- function(k_values, wcss_values, elbow_data, imgnames) {
  wcss_len <- length(wcss_values)
  extremes_line_coef <- (k_values[wcss_len] - k_values[1]) / (wcss_values[wcss_len] - wcss_values[1])
  extremes_orthogonal_line_coef <- -1 / extremes_line_coef
  elbowpoint_orthogonal <- c(elbow_data[1] + elbow_data[3]/2, elbow_data[2] + extremes_orthogonal_line_coef * (elbow_data[3]/2))
  plot(k_values, wcss_values, type="b", main=paste0("WCSS vs. k\n","(",imgnames,")"), xlab="# clusters (k)", ylab = "WCSS value")
  lines(x=c(k_values[1], k_values[wcss_len]), y=c(wcss_values[1], wcss_values[wcss_len]), type="b", col="blue")
  lines(x=c(elbow_data[1], elbowpoint_orthogonal[1]), y=c(elbow_data[2], elbowpoint_orthogonal[2]), type="b", col="red")
}

bkstick <- function(k_values, wcss_values, psi) {
  fit <- lm(wcss_values ~ k_values)
  return(segmented(fit, seg.Z = ~k_values, psi=psi))
}

getBKStickK <- function(model,round.type="DOWN") {
  if(round.type == "DOWN") {return(floor(model$psi[2]))}
  else if(round.type =="UP") {return(ceiling(model$psi[2]))}
  else {return(NULL)}
}

#### Main Wrapper Functions ####
computeK <- function(k_min, k_max, wcss_list, method="elbow", visualize=0, psi=5) {
  k_values <- k_min:k_max
  predicted_ks <- rep(NA, length(wcss_list))
  imgnames <- names(wcss_list)
  for(ii in 1:length(wcss_list)) {
    if(method == "elbow") {
      predicted_ks[ii] <- getElbowK(k_values, wcss_list[[ii]], imgnames[ii], visualize = visualize)
    } else if(method == "bkstickdown") {
      bkstick_model <- bkstick(k_values, wcss_list[[ii]], psi=psi)
      predicted_ks[ii] <- getBKStickK(bkstick_model, round.type = "DOWN")
    } else if(method == "bkstickup") {
      bkstick_model <- bkstick(k_values, wcss_list[[ii]], psi=psi)
      predicted_ks[ii] <- getBKStickK(bkstick_model, round.type = "UP")
    } else {
      return(NULL)
    }
  }
  return(data.frame(image = names(wcss_list), k = predicted_ks))
}

run_all_ks <- function(path,min_k,max_k,nstart=50,iter.max=15,lowerR=0,lowerG=0.6,lowerB=0,upperR=0.4,upperG=1,upperB=0.4,color.space="rgb", method="elbow", psi=5, visualize=0) {
  images_list <- getImageList(path = path, ABSPATH = 1)
  kmeans_list <- executeKmeans(imglist = images_list, minK = min_k, maxK = max_k, nstart = nstart, iter.max = iter.max, lowerR = lowerR, lowerG = lowerG, lowerB = lowerB, upperR = upperR, upperG = upperG, upperB = upperB, color.space = color.space)
  wcss_list <- getWCSSList(kmeanslist = kmeans_list)
  return(computeK(min_k, max_k, wcss_list, method, visualize = visualize, psi = psi))
}
