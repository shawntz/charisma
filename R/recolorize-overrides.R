charisma_hclust_color <- function(rgb_centers,
                         dist_method = "euclidean",
                         hclust_method = "complete",
                         channels = 1:3,
                         color_space = "Lab",
                         ref_white = "D65",
                         cutoff = NULL,
                         n_final = NULL,
                         return_list = TRUE,
                         plotting = TRUE) {

  # convert to hex colors (for plotting) and specified color space (for
  # distances)
  print("welcome to hclust...")
  print(rgb_centers)
  # stop("first hclust..")
  hex_cols <- grDevices::rgb(rgb_centers)
  conv_cols <- col2col(rgb_centers,
                       from = "sRGB",
                       to = color_space,
                       ref_white = ref_white)

  # get distance matrix
  d <- stats::dist(conv_cols[ , channels], method = dist_method)

  # get hierarchical clustering
  hc <- stats::hclust(d, method = hclust_method)

  # convert to dendrogram
  hcd <- stats::as.dendrogram(hc)

  # set colors
  hcd <- stats::dendrapply(hcd, function(x) labelCol(x, hex_cols, cex = 3))

  if (plotting) {

    # reset graphical parameters when function exits:
    current_par <- graphics::par(no.readonly = TRUE)
    on.exit(graphics::par(current_par))

    # plot
    graphics::par(mar = c(3, 4, 0, 0))
    plot(hcd, xlab = "", ylab = paste(color_space, "color distance"))

    # plot cutoff value if provided:
    if (!is.null(cutoff)) {
      graphics::abline(h = cutoff, lty = 2, col = "red", lwd = 2)
    }
  }

  # get list of layers to merge
  if (return_list) {
    if (is.null(cutoff)) { cutoff <- 0 }
    clust_groups <- stats::cutree(hc, h = cutoff, k = n_final)
    merge_list <- lapply(unique(clust_groups),
                         function(i) which(clust_groups == i))
    return(merge_list)
  }

}

ensure_matrix <- function(x, ncol = NULL) {
  if (is.null(dim(x))) {
    if (is.null(ncol)) stop("Need ncol to coerce to matrix.")
    matrix(x, ncol = ncol)
  } else {
    x
  }
}

charisma_recluster <- function(recolorize_obj,
                      dist_method = "euclidean",
                      hclust_method = "complete",
                      channels = 1:3,
                      color_space = "Lab",
                      ref_white = "D65",
                      cutoff = 60,
                      n_final = NULL,
                      plot_hclust = TRUE,
                      refit_method = c("imposeColors", "mergeLayers"),
                      resid = FALSE,
                      plot_final = TRUE,
                      color_space_fit = "sRGB") {

  # stop("I MADE IT HERE!")

  # rename, to keep things clear
  init_fit <- recolorize_obj
  init_fit <- expand_recolorize(init_fit,
                                original_img = TRUE)

  # first, ignore empty clusters -- they're not informative
  sizes <- init_fit$sizes
  centers <- init_fit$centers

  print(sizes == 0)
  print(sizes)
  # stop("checking sizes 1")

  print("old centers:")
  print(centers)

  # if any are empty, remove them
  if (any(sizes == 0)) {
    warning("if any are empty, remove them")
    zero_idx <- which(sizes == 0)
    sizes <- sizes[-zero_idx]
    print("new sizes:")
    print(sizes)
    centers <- init_fit$centers[-zero_idx, ]
    centers <- ensure_matrix(centers, ncol = 3)
    print("new centers:")
    print(centers)
  }

  # convert to Lab space for better clustering
  lab_init <- col2col(centers,
                      from = "sRGB",
                      to = color_space,
                      ref_white = ref_white)
  print(lab_init)

  # perform clustering, plot clusters, generate merge list
  merge_list <- charisma_hclust_color(centers,
                             dist_method = dist_method,
                             hclust_method = hclust_method,
                             channels = channels,
                             color_space = color_space,
                             ref_white = ref_white,
                             cutoff = cutoff,
                             n_final = n_final,
                             return_list = TRUE,
                             plotting = plot_hclust)

  # get refit method
  refit_method <- match.arg(refit_method)

  print("this is the merge list:")
  print(merge_list)
  print(length(merge_list))

  if (refit_method == "imposeColors") {
    # get weighted avg new colors:
    if (length(merge_list) <= 2) {
      warning("skipping merge list...")
      new_centers <- centers
    }
    if (length(merge_list) > 2) {
      for (i in 1:length(merge_list)) {
        temp_colors <- centers[merge_list[[i]], ]
        if (is.null(nrow(temp_colors))) {
          new_color <- temp_colors
        } else {
          new_color <- apply(temp_colors, 2, function(j)
            stats::weighted.mean(j, w = sizes[merge_list[[i]]]))
        }

        # make new dataframe/add new colors:
        if (i == 1) {
          new_centers <- data.frame(R = new_color[1],
                                    G = new_color[2],
                                    B = new_color[3])
        } else {
          new_centers <- rbind(new_centers, new_color)
        }
      }


    }
    # and refit:
    final_fit <- imposeColors(init_fit$original_img,
                              centers = new_centers,
                              plotting = FALSE)

    print(final_fit)

  } else if (refit_method == "mergeLayers") {
    # the hiccup here is that we removed some empty clusters (above)
    # so the indexing no longer matches
    init_fit$centers <- centers
    init_fit$sizes <- sizes
    final_fit <- mergeLayers(init_fit,
                             merge_list = merge_list,
                             plotting = FALSE)

  }

  # if plotting...
  if (plot_final) {

    # reset graphical parameters when function exits:
    current_par <- graphics::par(no.readonly = TRUE)
    on.exit(graphics::par(current_par))

    # first, set nice margins and layout
    graphics::par(mar = c(0, 0, 2, 0))
    graphics::layout(matrix(1:4, nrow = 1), widths = c(0.3, 0.3, 0.3, 0.1))

    # plot original image
    plotImageArray(init_fit$original_img, main = "original")

    # plot initial fit
    plotImageArray(constructImage(init_fit$pixel_assignments,
                                  init_fit$centers), main = "initial fit")

    # plot reclustered fit
    plotImageArray(constructImage(final_fit$pixel_assignments,
                                  final_fit$centers), main = "reclustered fit")

    # and the new color palette
    graphics::par(mar = rep(0.5, 4))
    plotColorPalette(final_fit$centers, sizes = final_fit$sizes, horiz = FALSE)
  }

  final_fit <- list(original_img = grDevices::as.raster(final_fit$original_img),
                    pixel_assignments = final_fit$pixel_assignments,
                    sizes = final_fit$sizes,
                    centers = final_fit$centers,
                    call = append(recolorize_obj$call, match.call()))

  class(final_fit) <- "recolorize"
  return(final_fit)

}

#' Change colors of dendrogram tips
#'
#' Internal function for [recolorize::recluster] plotting.
#'
#' @param x Leaf of a dendrogram.
#' @param hex_cols Hex color codes for colors to change to.
#' @param pch The type of point to draw.
#' @param cex The size of the point.
#' @return An `hclust` object with colored tips.
labelCol <- function(x, hex_cols, pch = 20, cex = 2) {

  if (length(cex) == 1) {
    cex <- rep(cex, length(hex_cols))
  }

  if (stats::is.leaf(x)) {
    ## fetch label
    label <- attr(x, "label")
    ## set label color
    attr(x, "nodePar") <- list(lab.col = hex_cols[label],
                               col = hex_cols[label],
                               pch = pch, cex = cex[label])
  }
  return(x)
}


charisma_recolorize2 <- function(img, method = "histogram",
                        bins = 2, n = 5,
                        cutoff = 20,
                        channels = 1:3,
                        n_final = NULL,
                        color_space = "sRGB",
                        recluster_color_space = "Lab",
                        refit_method = "impose",
                        ref_white = "D65",
                        lower = NULL, upper = NULL,
                        transparent = TRUE,
                        resize = NULL, rotate = NULL,
                        plotting = TRUE) {

  # initial fit - don't plot yet
  fit1 <- charisma_recolorize(img, method = method,
                     bins = bins, n = n,
                     color_space = color_space,
                     ref_white = ref_white,
                     lower = lower, upper = upper,
                     transparent = transparent,
                     resize = resize, rotate = rotate,
                     plotting = FALSE)

  # recluster
  fit2 <- charisma_recluster(fit1, color_space = recluster_color_space,
                    ref_white = ref_white,
                    cutoff = cutoff, channels = channels,
                    n_final = n_final, refit_method = refit_method,
                    plot_hclust = plotting, plot_final = plotting)
  fit2$call <- match.call()
  return(fit2)
}


charisma_recolorize <- function(img, method = c("histogram", "kmeans"),
                       bins = 2, n = 5,
                       color_space = "sRGB", ref_white = "D65",
                       lower = NULL, upper = NULL,
                       transparent = TRUE,
                       resid = FALSE,
                       resize = NULL, rotate = NULL,
                       plotting = TRUE, horiz = TRUE,
                       cex_text = 1.5, scale_palette = TRUE,
                       bin_avg = TRUE) {

  # get method
  method <- match.arg(method)

  # if 'img' is a filepath, read in image
  if (is.character(img)) {
    if (file.exists(img)) {
      img <- readImage(img, resize = resize, rotate = rotate)
    } else {
      stop(paste("Could not find", img))
    }

  } else if (!is.array(img) | length(dim(img)) != 3) {

    # otherwise, make sure it's an image array
    stop("'img' must be a path to an image or an image array.")

  }

  # make background condition
  alpha_channel <- dim(img)[3] == 4 # is there a transparency channel?
  bg_condition <- backgroundCondition(lower = lower, upper = upper,
                                      center = NULL, radius = NULL,
                                      transparent = transparent,
                                      alpha_channel = alpha_channel)

  # index background
  bg_indexed <- backgroundIndex(img, bg_condition)

  # color clusters & assign pixels
  color_clusters <- colorClusters(bg_indexed, method = method,
                                  n = n, bins = bins,
                                  color_space = color_space,
                                  ref_white = ref_white,
                                  bin_avg = bin_avg)

  # get sizes vector
  sizes <- color_clusters$sizes
  if (scale_palette) { s <- sizes } else { s <- NULL }

  # returnables:
  original_img <- img

  # add an alpha channel if there is none
  if (!alpha_channel) {
    a <- matrix(1, nrow = nrow(original_img), ncol = ncol(original_img))
    if (length(bg_indexed$idx_flat != 0 )) {
      a[bg_indexed$idx_flat] <- 0
    }
    original_img <- abind::abind(original_img, a)
  }

  # return binning scheme
  method <- if( method == "kmeans" ) {
    list(method = "kmeans", n = n)
  } else {
    list(method = "histogram", bins = bins)
  }

  # only rgb for now...would others be useful?
  centers <- color_clusters$centers
  pixel_assignments <- color_clusters$pixel_assignments

  # return em
  return_list <- list(original_img = grDevices::as.raster(original_img),
                      centers = centers,
                      sizes = sizes,
                      pixel_assignments = pixel_assignments,
                      call = match.call())

  # get residuals if TRUE
  if (resid) {
    return_list$resids <- colorResiduals(bg_indexed$non_bg,
                                         color_clusters$pixel_assignments,
                                         centers)
  }

  # set class
  class(return_list) <- "recolorize"

  # plot result
  if (plotting) {
    plot.recolorize(return_list, horiz = horiz,
                    cex_text = cex_text,
                    sizes = TRUE)
  }

  # and...you know
  return(return_list)

}

expand_recolorize <- function(recolorize_obj,
                              original_img = FALSE,
                              recolored_img = FALSE,
                              sizes = FALSE) {

  rc <- recolorize_obj

  if (original_img) {
    rc$original_img <- raster_to_array(recolorize_obj$original_img)
  }

  if (recolored_img) {
    rc$recolored_img <- constructImage(recolorize_obj$pixel_assignments,
                                       recolorize_obj$centers)
  }

  if (sizes) {
    sizes <- table(recolorize_obj$pixel_assignments)
    sizes <- sizes[-which(names(sizes) == 0)]
    rc$sizes <- sizes[order(as.numeric(names(sizes)))]
  }

  return(rc)

}

col2col <- function(pixel_matrix,
                    from = c("sRGB", "Lab", "Luv", "HSV"),
                    to = c("sRGB", "Lab", "Luv", "HSV"),
                    ref_white = "D65") {

  # match color space args
  from_color_space <- match.arg(from)
  to_color_space <- match.arg(to)

  # if HSV is not in site, we can use convertColor
  if (from_color_space != "HSV" & to_color_space != "HSV") {

    # ok, first convert pixels
    pm <- grDevices::convertColor(pixel_matrix,
                                  from = from_color_space,
                                  to = to_color_space,
                                  to.ref.white = ref_white,
                                  from.ref.white = ref_white)

  } else if (from_color_space == "sRGB" & to_color_space == "HSV") {

    # if we're converting from RGB to HSV, we can use rgb2hsv:
    pm <- t(grDevices::rgb2hsv(t(pixel_matrix), maxColorValue = 1))

  } else if (from_color_space == "HSV") {

    # if we're converting from HSV, first convert to RGB
    pm_temp <- grDevices::hsv(pixel_matrix[ , 1],
                              pixel_matrix[ , 2],
                              pixel_matrix[ , 3])

    pm_rgb <- t(grDevices::col2rgb(pm_temp)) / 255

    # then proceed as usual
    pm <- grDevices::convertColor(pm_rgb,
                                  from = "sRGB",
                                  to = to_color_space,
                                  to.ref.white = ref_white)
  }

  return(pm)

}
