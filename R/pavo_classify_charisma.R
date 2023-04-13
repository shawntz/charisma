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

  plot(0:1, 0:1, type = "n", axes = FALSE, asp = asp, main = "input to pavo", xlab = "", ylab = "")
  graphics::rasterImage(imagedata2, 0, 0, 1, 1)

  palette <- rgb(attr(pavo_class, "classRGB"))
  image(seq_along(palette), 1, as.matrix(seq_along(palette)),
        col = palette,
        main = paste0("pavo classification (charisma k=", charisma_k_cols, ")"),
        xlab = paste("Color class IDs: 1 -", length(palette)),
        ylab = "",
        xaxt = "n",
        yaxt = "n",
        asp = asp)
}

## TODO: add in a graphic for the proportion of colors selected by charisma to determine k (like the old plots w/ threshold line) [Done]
## TODO: in the final version of classification plot (hide the color id for the background) -- stick with pure white for now
## TODO: force out the white classification from the plot + figure out it's id within the array to pass to the adjacency funcs
## TODO: fix aspect ratio of 3rd pavo plot [Done -- "input to pavo" plot now fixed by replotting it from source]
## TODO: bypass manual intervention step [Done -- this is accomplished by passing verbose = FALSE to the charisma() function call, which is then passed to the load_image() function call]
## TODO: make sure all charisma objects are forced to have an image path upon initial load [Done -- this is accomplished when image is loaded via the charisma() function]

## NOTES:
## https://book.colrverse.com/analysing-data.html
## https://github.com/rmaia/pavo/blob/master/R/summary.rimg.R#L101
## https://github.com/ShawnTylerSchwartz/charisma/blob/955c45840c521372903f49a81b00a3fb9333061e/R/plotImage.R
## https://github.com/hiweller/recolorize/blob/master/R/plotImageArray.R


