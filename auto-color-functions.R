####
# @Author: Shawn T. Schwartz
# @Email: <shawnschwartz@ucla.edu>
# @Description: Source Functions for Automatic Color Detection
####

#### Install Required Libraries ####
reqlibs <- c("colordistance", "pavo", "segmented", "tidyverse", "plyr")
if (length(setdiff(reqlibs, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(reqlibs, rownames(installed.packages())))  
}

#### Load Required Libraries ####
library(colordistance)
library(pavo)
library(segmented)
library(tidyverse)
library(plyr)

#### Helper Functions ####
getImageList <- function(path, ABSPATH=0) {
  if(ABSPATH == 1) {return(paste0(path,"/",list.files(path = path)))}
  else {return(list.files(path = path))}
}

executeKmeans <- function(imglist,minK=1,maxK=5,nstart=50,iter.max=15,lowerR=0,lowerG=0.6,lowerB=0,upperR=0.4,upperG=1,upperB=0.4,color.space="rgb") {
  #default color lower and upper bins are for detecting uniform lime green
  outputList <- list()
  for (imgs in 1:length(imglist)) {
    cat(paste0("\n\nAnalyzing Image (",imgs," of ",length(imglist),"): ",imglist[imgs]))
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
  return(wcssList)
}

getRGBsList <- function(kmeanslist) {
  rgbList <- list()
  allnames <- rep(NA, length(kmeanslist))
  for(images in 1:length(kmeanslist)) {
    rgbs <- list()
    for(clusters in 1:length(kmeanslist[[images]])) {
      imgname <- names(kmeanslist[[images]][clusters][[1]])
      cat(paste0("Obtaining RGB values for: ", imgname, " (k=",clusters,")\n"))
      rgbs_temp <- matrix(NA, nrow = clusters, ncol = 3)
      for(kk in 1:clusters) {
        coef_seq <- seq(from = 0, to = clusters*3, by = 3)
        for(ii in 1:3) {
          rgbs_temp[kk,ii] <- get(imgname,kmeanslist[[images]][clusters][[1]])$centers[kk,ii]
        }
      }
      rgbs_temp <- as.vector(rgbs_temp)
      rgbs[[clusters]] <- rgbs_temp
    }
    allnames[images] <- imgname
    rgbList[[images]] <- rgbs
  }
  names(rgbList) <- allnames
  return(rgbList)
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
computeK <- function(k_min, k_max, wcss_list, rgb_list, method="elbow", visualize=0, psi=5, fileout="rgb_out.txt", color.space) {
  k_values <- k_min:k_max
  predicted_ks <- rep(NA, length(wcss_list))
  rgb_extracted <- list()
  imgnames <- names(wcss_list)
  for(ii in 1:length(wcss_list)) {
    if(method == "elbow") {
      predicted_ks[ii] <- getElbowK(k_values, wcss_list[[ii]], imgnames[ii], visualize = visualize)
      rgb_extracted[[ii]] <- rgb_list[[ii]][predicted_ks[ii]]
    } else if(method == "bkstickdown") {
      bkstick_model <- bkstick(k_values, wcss_list[[ii]], psi=psi)
      predicted_ks[ii] <- getBKStickK(bkstick_model, round.type = "DOWN")
      rgb_extracted[[ii]] <- rgb_list[[ii]][predicted_ks[ii]]
    } else if(method == "bkstickup") {
      bkstick_model <- bkstick(k_values, wcss_list[[ii]], psi=psi)
      predicted_ks[ii] <- getBKStickK(bkstick_model, round.type = "UP")
      rgb_extracted[[ii]] <- rgb_list[[ii]][predicted_ks[ii]]
    } else {
      return(NULL)
    }
  }
  
  names(rgb_extracted) <- imgnames
  sink(fileout)
  print(rgb_extracted)
  sink()
  
  return(data.frame(image = names(wcss_list), k = predicted_ks, method = method, colorspace = color.space))
}

run_all_ks <- function(path,min_k,max_k,nstart=50,iter.max=15,lowerR=0,lowerG=0.6,lowerB=0,upperR=0.4,upperG=1,upperB=0.4,color.space="rgb", method="elbow", psi=5, visualize=0, fileout="rgb_out.txt") {
  images_list <- getImageList(path = path, ABSPATH = 1)
  kmeans_list <- executeKmeans(imglist = images_list, minK = min_k, maxK = max_k, nstart = nstart, iter.max = iter.max, lowerR = lowerR, lowerG = lowerG, lowerB = lowerB, upperR = upperR, upperG = upperG, upperB = upperB, color.space = color.space)
  wcss_list <- getWCSSList(kmeanslist = kmeans_list)
  rgb_list <- getRGBsList(kmeanslist = kmeans_list)
  return(computeK(min_k, max_k, wcss_list, rgb_list, method, visualize = visualize, psi = psi, fileout = fileout, color.space = color.space))
}

#### Color Classification Pipeline Helper Functions ####
## adapted from Alfaro, Karan, Schwartz, Shultz (2019)
classify_by_unique_k <- function(path, kdf) {
  images_list <- getImageList(path = path, ABSPATH = 1)
  classifications <- list()
  for(image in 1:length(images_list)) {
    pic <- getimg(images_list[image], max.size = 3)
    cat(paste0("Image (",image,"/",length(images_list),"): ", images_list[image],"\n"))
    classifications[[image]] <- classify(pic, kcols = kdf$k[image])
    cat("\n")
  }
  names(classifications) <- kdf$image
  return(classifications)
}

rgb_euc_dist <- function(rgb_table_altered, c1, c2) {
  euc_dist <- sqrt((rgb_table_altered[c1,"col1"]-rgb_table_altered[c2,"col1"])^2+(rgb_table_altered[c1,"col2"]-rgb_table_altered[c2,"col2"])^2) %>%
    .[1,1]
  return(euc_dist)
}

rgb_lum_dist <- function(rgb_table_altered, c1, c2){
  lum_dist <- sqrt((rgb_table_altered[c1,"lum"]-rgb_table_altered[c2,"lum"])^2) %>%
    .[1,1]
  return(lum_dist)
}

#input is a single classified image
calc_euc_lum_dists <- function(classified_image){
  #extract RGB values for n colors
  class_rgb <- attr(classified_image, 'classRGB')
  class_rgb_altered <- class_rgb %>%
    rownames_to_column(var = "col_num") %>%
    as.tibble %>%
    mutate(col1 = (R-G)/(R+G), col2 = (G-B)/(G+B), lum = R+G+B) %>%
    select(col1, col2, lum)
  
  #create a matrix to hold colors based on the number of possible color comparisons
  euc_dists <- matrix(nrow=choose(nrow(class_rgb),2),ncol=4)
  
  combos_simple <- t(combn(rownames(class_rgb),2)) %>%
    as.tibble %>%
    transmute(c1 = as.numeric(V1), c2 = as.numeric(V2)) %>%
    as.data.frame()
  
  combos <- matrix(nrow=nrow(combos_simple),ncol=4)
  for (i in 1:nrow(combos_simple)) {
    combos[i,1] <- combos_simple[i,1]
    combos[i,2] <- combos_simple[i,2]
    combos[i,3] <- rgb_euc_dist(class_rgb_altered,combos_simple[i,1],combos_simple[i,2])
    combos[i,4] <- rgb_lum_dist(class_rgb_altered,combos_simple[i,1],combos_simple[i,2])
  }
  
  combos <- combos %>%
    as.data.frame %>%
    as.tibble %>%
    dplyr::rename(c1 = V1,
                  c2 = V2,
                  dS = V3,
                  dL = V4) %>%
    as.data.frame
  
  return(combos)
}

#get distance data frame for each picture
get_img_class_k_dists <- function(classifications, euclidean_lum_dists) {
  return(map(.x=classifications,.f=euclidean_lum_dists))
}

#calculate the adjacency stats for each image, using the calculated distances as proxies for dS and dL
get_adj_stats <- function(classifications, img_class_k_dists, xpts=100, xscale=100) {
  adj_k_dists_list <- list()
  for(i in 1:length(classifications)) {
    adj_k_dists_list[[i]] <- adjacent(classimg = classifications[[i]],coldists=img_class_k_dists[[i]],xpts=xpts,xscale=xscale)
  }
  return(adj_k_dists_list)
}

#clean up and select relevant stats
get_cleanedup_stats <- function(adj_k_dists_list) {
  img_adj_k_dists <- Reduce(rbind.fill,adj_k_dists_list) %>%
    rownames_to_column(var = "name") %>%
    as.tibble()
  
  img_adj_k_dists_select <- img_adj_k_dists %>%
    dplyr::select(name,m,m_r,m_c,A,Sc,St,Jc,Jt,m_dS,s_dS,cv_dS,m_dL,s_dL,cv_dL)
  
  return(img_adj_k_dists_select)
}

#### Color Classification Pipeline Wrapper Functions ####
classify_color <- function(path, kdf) {
  classifications <- classify_by_unique_k(path, kdf)
  classified_k_dists <- get_img_class_k_dists(classifications, calc_euc_lum_dists)
  adj_stats_raw <- get_adj_stats(classifications, classified_k_dists, 100, 100)
  adj_stats <- get_cleanedup_stats(adj_stats_raw)
  return(adj_stats)
}

run_color_pca <- function(adj_stats) {
  #pca_input <- select(adj_stats, name, m, m_r, m_c, Sc, St, A, m_dS,s_dS,m_dL,s_dL) %>% as.data.frame %>%
  pca_input <- select(adj_stats, name, m, m_r, m_c, Sc, St, A, m_dS,m_dL) %>% as.data.frame %>%
    column_to_rownames("name")
  pca_res <- prcomp(pca_input, center = T, scale = T)
  return(pca_res)
}

get_color_pca_summary <- function(pca_res) {
  return(summary(pca_res))
}
