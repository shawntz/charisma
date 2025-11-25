charisma_to_img <- function(
  charisma_obj,
  out_type = c("jpg", "jpeg", "png"),
  bg_color = "white",
  render_method = c("array", "raster"),
  render_with_threshold = FALSE,
  filename = ""
) {
  out_type <- tolower(out_type)
  out_type <- match.arg(out_type)

  render_method <- tolower(render_method)
  render_method <- match.arg(render_method)

  # if user specifies a transparent background, set a placeholder color
  #  before adding the alpha layer
  if (is.null(bg_color)) {
    is_transparent <- TRUE
    bg_color <- "white"
  } else {
    is_transparent <- FALSE
  }

  # adapted from recolorize

  # make two copies of matrix as a cimg object:
  index_cimg <- imager::as.cimg(charisma_obj$pixel_assignments)
  final_cimg <- index_cimg

  # color the background in
  # you won't see this unless you remove the alpha layer:
  final_cimg <- imager::colorise(final_cimg, index_cimg == 0, bg_color)

  # color in every color center:
  for (i in 1:nrow(charisma_obj$centers)) {
    if (render_with_threshold) {
      hex_values <- charisma_obj$color_mask_LUT_filtered$hex
    } else {
      hex_values <- charisma_obj$color_mask_LUT$hex
    }
    final_cimg <- imager::colorise(
      final_cimg,
      index_cimg == i,
      hex_values[i + 1]
    )
  }

  # convert to a regular array:
  as_array <- cimg_to_array(final_cimg)

  # and add an alpha channel:
  if (is_transparent) {
    alpha_layer <- charisma_obj$pixel_assignments
    alpha_layer[which(alpha_layer > 0)] <- 1
    as_array <- abind::abind(as_array, alpha_layer, along = 3)
  }

  img <- as_array

  if (render_method == "raster") {
    img <- grDevices::as.raster(charisma_obj$color_mask)
  }

  if (out_type %in% c("jpg", "jpeg")) {
    jpeg::writeJPEG(img, target = filename, quality = 1)
  }

  if (out_type == "png") {
    png::writePNG(img, target = filename)
  }
}

# from recolorize
cimg_to_array <- function(x) {
  img <- as.numeric(x)
  dim(img) <- dim(x)[c(1, 2, 4)]
  if (dim(img)[3] == 1) {
    dim(img) <- dim(img)[1:2]
  }
  return(img)
}

generate_filename <- function(filepath, check_dir_plus_base = FALSE) {
  dir <- dirname(filepath)
  base <- tools::file_path_sans_ext(basename(filepath))
  ext <- tools::file_ext(filepath)

  # edge case: paths/computers change between reloads of charisma.RDS files
  # allow user to force a new directory to avoid saving errors
  check_logdir <- TRUE

  if (check_dir_plus_base) {
    dir_to_check <- file.path(dir, base)
  } else {
    dir_to_check <- dir
  }

  # check if directory exists

  if (!dir.exists(dir_to_check)) {
    message(paste(
      "\nCRITICAL MESSAGE:\n",
      dir_to_check,
      "\nThis charisma `logdir` (directory) does not exist on this computer.\n",
      ">> Please enter a new logdir:"
    ))
    new_dir <- readline()
    if (new_dir != "") {
      if (dir.exists(new_dir)) {
        dir <- new_dir
      } else {
        message(
          "Log directory provided does not exist. Creating new directory..."
        )
      }
    } else {
      stop("No valid directory provided.")
    }
  } else {
    new_dir <- dir
  }

  if (!check_dir_plus_base) {
    new_filename <- file.path(new_dir, sprintf("%s.%s", base, ext))
  } else {
    new_filename <- new_dir
  }

  list.out <- list(
    new_filename = new_filename,
    new_basepath = new_dir
  )

  return(list.out)
}

get_colors <- function(charisma_obj) {
  return(unique(charisma_obj$classification))
}

get_k <- function(charisma_obj) {
  return(length(unique(charisma_obj$classification)))
}

get_lut_colors <- function(clut = charisma::clut) {
  return(unique(clut[, 1]))
}

get_lut_hex <- function(clut = charisma::clut) {
  return(dplyr::select(clut, color.name, default.hex))
}

load_image <- function(img_path, interactive = TRUE, bins = 4, cutoff = 20) {
  # validate and clean the image path
  if (!is.character(img_path) || length(img_path) != 1) {
    stop("img_path must be a single character string")
  }
  if (!file.exists(img_path)) {
    stop(paste("Image file not found:", img_path))
  }
  img <- charisma_readImage(img_path, resize = NULL, rotate = NULL)

  recolorize_defaults <- suppressMessages(
    # recolorize::recolorize2(img = img,
    charisma_recolorize2(
      img = img,
      bins = bins,
      cutoff = cutoff,
      plotting = FALSE
    )
  )

  if (interactive) {
    out.list <- interactive_session(recolorize_defaults)
  } else {
    out.list <- list(
      final_img = recolorize_defaults,
      replacement_history = NULL,
      replacement_states = NULL,
      merge_history = NULL,
      merge_states = NULL
    )
  }

  return(out.list)
}

merge_colors <- function(img, color.list) {
  if (!is.null(color.list)) {
    parsed_expression <- eval(parse(text = paste0("list(", color.list, ")")))
  } else {
    parsed_expression <- NULL
  }

  merged <- recolorize::mergeLayers(
    recolorize_obj = img,
    merge_list = parsed_expression,
    plotting = TRUE
  )
  out.list <- list()
  out.list$img <- merged
  return(out.list)
}

replace_color <- function(img, color_from, color_to) {
  if (!is.null(color_from) && !is.null(color_to)) {
    img$pixel_assignments[
      which(img$pixel_assignments == as.numeric(color_from))
    ] <- as.numeric(color_to)

    img$centers[as.numeric(color_from), ] <- img$centers[as.numeric(color_to), ]
  }

  out.list <- list()
  out.list$img <- img
  return(out.list)
}

save_recolored <- function(img, fname) {
  recolorize::recolorize_to_png(img, fname)
}

summarise_colors <- function(uniq_color_vec, clut = charisma::clut) {
  # get all color names from CLUT
  color_names <- get_lut_colors(clut)

  color_summary <- ifelse(color_names %in% uniq_color_vec, 1, 0)

  names(color_summary) <- color_names

  # get total number of color calls (k) and append to end of data frame
  color_summary <- color_summary %>%
    t() %>%
    as.data.frame() %>%
    dplyr::mutate(k = rowSums(.))

  return(color_summary)
}

# custom readImage function to handle path evaluation issues
charisma_readImage <- function(img_path, resize = NULL, rotate = NULL) {
  # ensure img_path is a single character string
  if (!is.character(img_path)) {
    stop("img_path must be a character string")
  }
  
  if (length(img_path) != 1) {
    warning("img_path has length > 1, using first element")
    img_path <- img_path[1]
  }
  
  # get file extension and ensure it's a single value
  img_ext <- tolower(tools::file_ext(img_path))
  if (length(img_ext) != 1) {
    stop("Unable to determine file extension for: ", img_path)
  }
  
  # check if file extension is supported
  if (img_ext %in% c("jpeg", "jpg", "png", "bmp", "tif", "tiff")) {
    img <- imager::load.image(img_path)
  } else {
    stop("Image must be either JPG, PNG, TIFF, or BMP")
  }
  
  # apply resize if specified
  if (!is.null(resize)) {
    img <- imager::imresize(img, scale = resize, interpolation = 6)
  }
  
  # apply rotation if specified
  if (!is.null(rotate)) {
    img <- imager::imrotate(img, angle = rotate)
  }
  
  # standard rotation and processing from recolorize
  img <- imager::imrotate(img, -90)
  temp <- array(dim = dim(img)[c(1:2, 4)])
  temp <- img[, , 1, ]
  
  if (length(dim(temp)) == 3) {
    temp[, , ] <- apply(temp, 3, function(mat) {
      mat[, ncol(mat):1, drop = FALSE]
    })
  } else if (length(dim(temp)) == 2) {
    temp <- temp[, ncol(temp):1, drop = FALSE]
  }
  
  if (max(temp) > 1) {
    temp <- temp / max(temp)
  }
  
  img <- temp
  rm(temp)
  return(img)
}
