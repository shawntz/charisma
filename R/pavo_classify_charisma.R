## Mirror matrices about x axis
## source: https://github.com/rmaia/pavo/blob/master/R/plot.rimg.R
mirrorx <- function(x) {
  if (length(dim(x)) == 3) {
    for (i in seq_len(dim(x)[3])) {
      x[, , i] <- x[, , i][, rev(seq_len(ncol(x[, , i])))]
    }
  } else {
    x <- x[, rev(seq_len(ncol(x)))]
  }
  x
}

rgbEucDist <- function(rgb_table_altered, c1, c2) {
  euc_dist <- sqrt((rgb_table_altered[c1,"col1"]-rgb_table_altered[c2,"col1"])^2+(rgb_table_altered[c1,"col2"]-rgb_table_altered[c2,"col2"])^2) %>%
    .[1,1]

  return(euc_dist)
}

rgbLumDist <- function(rgb_table_altered, c1, c2) {
  lum_dist <- sqrt((rgb_table_altered[c1,"lum"]-rgb_table_altered[c2,"lum"])^2) %>%
    .[1,1]

  return(lum_dist)
}

#input is a single classified image
calcEucLumDists <- function(classified_image) {
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
  for(i in 1:nrow(combos_simple)) {
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
getImgClassKDists <- function(classifications, euclidean_lum_dists) {
  return(purrr::map(.x=classifications,.f=euclidean_lum_dists))
}

#calculate the adjacency stats for each image, using the calculated distances as proxies for dS and dL
getAdjStats <- function(classifications, img_class_k_dists, xpts=100, xscale=100, bkgID=NULL) {
  adj_k_dists_list <- list()
  # pavo::adjacent(pavo_class, , xscale = dim(imagedata2)[2])
  for(i in 1:length(classifications)) {
    adj_k_dists_list[[i]] <- pavo::adjacent(classimg = classifications[[i]],coldists=img_class_k_dists[[i]],xpts=xpts,xscale=xscale,bkgID = as.numeric(bkgID))
    cat("\n")
  }

  return(adj_k_dists_list)
}

#clean up and select relevant stats
getCleanedupStats <- function(adj_k_dists_list) {
  img_adj_k_dists <- Reduce(plyr::rbind.fill,adj_k_dists_list) %>%
    rownames_to_column(var = "name") %>%
    as_tibble()

  img_adj_k_dists_select <- img_adj_k_dists %>%
    dplyr::select(name,m,m_r,m_c,A,Sc,St,Jc,Jt,m_dS,s_dS,cv_dS,m_dL,s_dL,cv_dL)

  return(img_adj_k_dists_select)
}

pavo_classify_charisma <- function(charisma_obj, tmp_dir = "pavo_tmp") {
  # create tmp directory to store recolored jpeg outputs
  if (!dir.exists(tmp_dir)) {
    dir.create(tmp_dir)
  }

  # tmp filepath
  tmp_out_target <- file.path(tmp_dir, basename(charisma_obj$path))

  # number of colors classes to classify in pavo
  charisma_k_cols <- charisma_obj$k

  # save out tmp recolored jpeg
  charisma_to_jpeg(charisma_obj, tmp_out_target)

  # read back in
  pavo_img <- pavo::getimg(tmp_out_target, max.size = 3)

  # run classification
  ## remember, this includes the background color as one of the k classes...
  ## ... which can be identified to be excluded before running the adjacency analyses
  pavo_class <- pavo::classify(pavo_img, kcols = charisma_k_cols + 1)
  classifications <- list()
  classifications[[1]] <- pavo_class
  names(classifications) <- basename(charisma_obj$path)
  # # print out summary plot
  # summary(pavo_class, plot = TRUE)

  # custom plotting function to integrate with the other charisma diagnostic plots
  # asp <- dim(pavo_class)[1] / dim(pavo_class)[2]
  asp <- dim(charisma_obj$original_img)[1] / dim(charisma_obj$original_img)[2]

  # manually transform image
  ## adapted from: https://github.com/rmaia/pavo/blob/master/R/plot.rimg.R
  img3 <- rev(t(apply(pavo_class, 1, rev))) # mirror
  dim(img3) <- dim(pavo_class)
  img <- t(apply(img3, 2, rev)) # rotate 90
  # Reconstitute image
  rgbs <- attr(pavo_class, "classRGB")

  mapR <- setNames(rgbs$R, seq_len(nrow(rgbs)))
  mapG <- setNames(rgbs$G, seq_len(nrow(rgbs)))
  mapB <- setNames(rgbs$B, seq_len(nrow(rgbs)))
  R <- matrix(mapR[img], nrow = nrow(img), dimnames = dimnames(img))
  G <- matrix(mapG[img], nrow = nrow(img), dimnames = dimnames(img))
  B <- matrix(mapB[img], nrow = nrow(img), dimnames = dimnames(img))

  imageout <- array(c(R, G, B), dim = c(dim(img)[1], dim(img)[2], 3))

  # Convert and transform
  imagedata2 <- suppressWarnings(as.raster(imageout))
  imagedata2 <- mirrorx(imagedata2)
  imagedata2 <- apply(t(as.matrix(imagedata2)), 2, rev)

  plot(0:1, 0:1, type = "n", axes = FALSE, asp = asp, main = "input2pavo", xlab = "", ylab = "")
  graphics::rasterImage(imagedata2, 0, 0, 1, 1)

  tmp_pavo_cols <- attr(pavo_class, "classRGB")
  white_bg_id <- rownames(subset(tmp_pavo_cols, rowSums(tmp_pavo_cols[,1:3] > 0.99) > 0)) ## TODO: this works for now as an ID to pass into the pavo adjaceny function, but will fail if there are multiple ID's that fall within the white boundary, so it'll be critical to figure out an elegant solution for this
  tmp_pavo_cols <- subset(tmp_pavo_cols, rowSums(tmp_pavo_cols[,1:3] > 0.99) == 0)
  # print(tmp_pavo_cols)
  # print(white_bg_id)
  palette <- rgb(tmp_pavo_cols)
  # print(palette)
  image(seq_along(palette), 1, as.matrix(seq_along(palette)),
        col = palette,
        main = paste0("pavo class (k=", charisma_k_cols, ")"),
        xlab = paste("Color class IDs: 1 -", length(palette)),
        ylab = "",
        xaxt = "n",
        yaxt = "n",
        asp = asp)

  # get relevant coldists data before running adjacency
  classified_k_dists <- getImgClassKDists(classifications, calcEucLumDists)
  adj_stats_raw <- getAdjStats(classifications, classified_k_dists, 100, 100, white_bg_id)
  adj_stats <- getCleanedupStats(adj_stats_raw)
  # run the adjacency analysis
  # print(dim(imagedata2))
  # color_stats <- pavo::adjacent(pavo_class, bkgID = as.numeric(white_bg_id), xscale = dim(imagedata2)[2])
  # return(color_stats)
  return(adj_stats)
}

## TODO: figure out the xscale dimensions what happens if we use procimg() {find the original script and match the scaling parameters}
## TODO: build in the stepwise rerun of pavo until desired output is achieved, then directly run adjacency stats and save to a csv file
##

## [still needs a bit more work with getting the adjacency function wrapper written...]
## TODO: force out the white classification from the plot + figure out it's id within the array to pass to the adjacency funcs [Done -- just need to pass into the adjacency function by making a custom wrapper for this that passes the ignore value in as well]

## [pretty much fully done for now]:
## TODO: add in a graphic for the proportion of colors selected by charisma to determine k (like the old plots w/ threshold line) [Done -- currently only showing color bars that have any value > 0 .. should we show all 10 colors with empty slots instead?]
## TODO: in the final version of classification plot (hide the color id for the background) -- stick with pure white for now [Done -- need to address potential issue of values being close to (but not exactly) pure white [i.e., "the 0.99" problem, and what happens if there are meaningful colors in the image that fall within this range?...]]
## TODO: fix aspect ratio of 3rd pavo plot [Done -- "input to pavo" plot now fixed by replotting it from source]
## TODO: bypass manual intervention step [Done -- this is accomplished by passing verbose = FALSE to the charisma() function call, which is then passed to the load_image() function call]
## TODO: make sure all charisma objects are forced to have an image path upon initial load [Done -- this is accomplished when image is loaded via the charisma() function]

## NOTES:
## https://book.colrverse.com/analysing-data.html
## https://github.com/rmaia/pavo/blob/master/R/summary.rimg.R#L101
## https://github.com/ShawnTylerSchwartz/charisma/blob/955c45840c521372903f49a81b00a3fb9333061e/R/plotImage.R
## https://github.com/hiweller/recolorize/blob/master/R/plotImageArray.R


