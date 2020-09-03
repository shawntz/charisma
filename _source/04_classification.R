#################################################################
##           Color Classification Pipeline Functions           ##
##    Adapted from Alfaro, Karan, Schwartz, & Shultz (2019)    ##
#################################################################
classifyByUniqueK <- function(path, kdf)
{
  image_paths <- kdf$img
  images_list <- rep(NA, length(image_paths))
  for(image in 1:length(images_list))
  {
    if(Sys.info()['sysname'] != "Windows")
    {
      images_list[image] <- tail(strsplit(image_paths[image], "/")[[1]], 1)
    }
    else
    {
      images_list[image] <- tail(strsplit(as.character(image_paths[image]), "\\\\")[[1]], 1)
    }
  }
  
  classifications <- list()
  
  for(image in 1:length(images_list))
  {
    pic <- pavo::getimg(file.path(path, images_list[image]), max.size = 3)
    cat(paste0("Image (", image, "/", length(images_list),"): ", images_list[image], 
               " with (k = ", kdf$k[image], ")\n"))
    classifications[[image]] <- pavo::classify(pic, kcols = kdf$k[image])
    cat("\n")
  }
  
  names(classifications) <- images_list
  return(classifications)
}

rgbEucDist <- function(rgb_table_altered, c1, c2) 
{
  euc_dist <- sqrt((rgb_table_altered[c1,"col1"]-rgb_table_altered[c2,"col1"])^2+(rgb_table_altered[c1,"col2"]-rgb_table_altered[c2,"col2"])^2) %>%
    .[1,1]
  return(euc_dist)
}

rgbLumDist <- function(rgb_table_altered, c1, c2)
{
  lum_dist <- sqrt((rgb_table_altered[c1,"lum"]-rgb_table_altered[c2,"lum"])^2) %>%
    .[1,1]
  return(lum_dist)
}

#input is a single classified image
calcEucLumDists <- function(classified_image)
{
  #extract RGB values for n colors
  class_rgb <- attr(classified_image, 'classRGB')
  class_rgb_altered <- class_rgb %>%
    rownames_to_column(var = "col_num") %>%
    as_tibble %>%
    mutate(col1 = (R-G)/(R+G), col2 = (G-B)/(G+B), lum = R+G+B) %>%
    select(col1, col2, lum)
  
  #create a matrix to hold colors based on the number of possible color comparisons
  euc_dists <- matrix(nrow=choose(nrow(class_rgb),2),ncol=4)
  
  combos_simple <- t(combn(rownames(class_rgb),2)) %>%
    as_tibble %>%
    transmute(c1 = as.numeric(V1), c2 = as.numeric(V2)) %>%
    as.data.frame()
  
  combos <- matrix(nrow=nrow(combos_simple),ncol=4)
  for(i in 1:nrow(combos_simple))
  {
    combos[i,1] <- combos_simple[i,1]
    combos[i,2] <- combos_simple[i,2]
    combos[i,3] <- rgbEucDist(class_rgb_altered,combos_simple[i,1],combos_simple[i,2])
    combos[i,4] <- rgbLumDist(class_rgb_altered,combos_simple[i,1],combos_simple[i,2])
  }
  
  combos <- combos %>%
    as.data.frame %>%
    as_tibble %>%
    dplyr::rename(c1 = V1,
                  c2 = V2,
                  dS = V3,
                  dL = V4) %>%
    as.data.frame
  
  return(combos)
}

#get distance data frame for each picture
getImgClassKDists <- function(classifications, euclidean_lum_dists) 
{
  return(map(.x=classifications,.f=euclidean_lum_dists))
}

#calculate the adjacency stats for each image, using the calculated distances as proxies for dS and dL
getAdjStats <- function(classifications, img_class_k_dists, xpts=100, xscale=100) 
{
  adj_k_dists_list <- list()
  
  for(i in 1:length(classifications)) 
  {
    adj_k_dists_list[[i]] <- pavo::adjacent(classimg = classifications[[i]],coldists=img_class_k_dists[[i]],xpts=xpts,xscale=xscale)
    cat("\n")
  }
  
  return(adj_k_dists_list)
}

#clean up and select relevant stats
getCleanedupStats <- function(adj_k_dists_list) 
{
  img_adj_k_dists <- Reduce(rbind.fill,adj_k_dists_list) %>%
    rownames_to_column(var = "name") %>%
    as_tibble()
  
  img_adj_k_dists_select <- img_adj_k_dists %>%
    dplyr::select(name,m,m_r,m_c,A,Sc,St,Jc,Jt,m_dS,s_dS,cv_dS,m_dL,s_dL,cv_dL)
  
  return(img_adj_k_dists_select)
}