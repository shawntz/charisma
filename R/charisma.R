#' Characterize color classes in biological images
#'
#' The primary function of \code{charisma} is to characterize the distribution
#' of human-visible color classes present in an image. This function provides
#' a standardized and reproducible framework for classifying colors into
#' discrete categories using a biologically-inspired Color Look-Up Table (CLUT).
#'
#' @param img_path Character string specifying the path to an image file, or a
#'   \code{recolorize} object (for use with \code{charisma2}).
#' @param threshold Numeric value between 0 and 1 specifying the minimum
#'   proportion of pixels required for a color to be retained. Colors with
#'   proportions below this threshold are automatically removed. Default is 0.0
#'   (retain all colors).
#' @param auto.drop Logical. If \code{TRUE}, automatically removes the
#'   background layer (layer 0) from color counts. Default is \code{TRUE}.
#' @param interactive Logical. If \code{TRUE}, enables manual intervention for
#'   color merging and replacement operations. Saves all states for full
#'   reproducibility. Default is \code{FALSE}.
#' @param plot Logical. If \code{TRUE}, generates diagnostic plots during
#'   processing. Default is \code{FALSE}.
#' @param pavo Logical. If \code{TRUE}, computes color pattern geometry
#'   statistics using the \pkg{pavo} package. Default is \code{TRUE}.
#' @param logdir Character string specifying the directory path for saving
#'   output files. If provided, saves timestamped .RDS (charisma object) and
#'   .PDF (diagnostic plots) files. Default is \code{NULL} (no files saved).
#' @param stack_colors Logical. If \code{TRUE}, stacks color proportions in
#'   plots. Default is \code{TRUE}.
#' @param bins Integer specifying the number of bins for each RGB channel in the
#'   histogram method. Default is 4 (resulting in 4^3 = 64 cluster centers).
#' @param cutoff Numeric value specifying the Euclidean distance threshold for
#'   combining similar color clusters. Default is 20.
#' @param k.override Integer to force a specific number of color clusters,
#'   bypassing automatic detection. Default is \code{NULL}.
#' @param clut Data frame containing the Color Look-Up Table with HSV boundaries
#'   for each color class. Default is \code{charisma::clut} (10 human-visible
#'   colors: black, blue, brown, green, grey, orange, purple, red, white,
#'   yellow).
#'
#' @return A \code{charisma} object (list) containing:
#'   \item{centers}{RGB cluster centers}
#'   \item{pixel_assignments}{Pixel-to-cluster mapping}
#'   \item{classification}{Discrete color labels from CLUT}
#'   \item{color_mask_LUT}{Mapping of clusters to averaged colors}
#'   \item{color_mask_LUT_filtered}{Color mapping after threshold applied}
#'   \item{merge_history}{Record of all merge operations performed}
#'   \item{replacement_history}{Record of all replacement operations performed}
#'   \item{merge_states}{List of charisma states after each merge}
#'   \item{replacement_states}{List of charisma states after each replacement}
#'   \item{pavo_stats}{Color pattern geometry metrics (if pavo = TRUE)}
#'   \item{prop_threshold}{Threshold value used}
#'   \item{path}{Path to original image}
#'   \item{logdir}{Directory where outputs were saved}
#'   \item{auto_drop}{Value of auto.drop parameter}
#'   \item{bins}{Value of bins parameter}
#'   \item{cutoff}{Value of cutoff parameter}
#'   \item{clut}{CLUT used for classification}
#'   \item{stack_colors}{Value of stack_colors parameter}
#'
#' @details
#' The \code{charisma} pipeline consists of three main stages:
#' \enumerate{
#'   \item \strong{Image preprocessing}: Uses
#'     \code{\link[recolorize:recolorize2]{recolorize::recolorize2()}} to
#'     perform spatial-color binning, removing noisy pixels and creating a
#'     smoothed representation of dominant colors.
#'   \item \strong{Color classification}: Converts RGB cluster centers to HSV
#'     color space and matches them against non-overlapping HSV ranges defined
#'      in the CLUT using \code{charisma::color2label()}.
#'   \item \strong{Optional manual curation}: In interactive mode, users can
#'     merge color clusters (e.g., c(2,3)) or replace pixels between clusters
#'     to refine classifications.
#' }
#'
#' The workflow can be run fully autonomously or with varying degrees of manual
#' intervention. All operations are logged for complete reproducibility.
#'
#' @references
#' Schwartz, S.T., Tsai, W.L.E., Karan, E.A., Juhn, M.S., Shultz, A.J.,
#' McCormack, J.E., Smith, T.B., and Alfaro, M.E. (2025). charisma: An R package
#' to perform reproducible color characterization of digital images for
#' biological studies. (In Review).
#'
#' Weller, H.I., Hiller, A.E., Lord, N.P., and Van Belleghem, S.M. (2024).
#' \pkg{recolorize}: An R package for flexible colour segmentation of biological
#' images. Ecology Letters, 27(2):e14378.
#'
#' @seealso
#' \code{\link{charisma2}} for re-analyzing saved charisma objects,
#' \code{\link{color2label}} for RGB to color label conversion,
#' \code{\link{validate}} for CLUT validation,
#' \code{\link{plot.charisma}} for visualization
#'
#' @examples
#' \donttest{
#' # Basic usage with example image
#' img <- system.file("extdata", "Tangara_fastuosa_LACM60421.png",
#'                    package = "charisma")
#' result <- charisma(img)
#'
#' # With threshold to remove minor colors
#' result <- charisma(img, threshold = 0.05)
#'
#' # Save outputs to directory
#' out_dir <- file.path(tempdir(), "charisma_outputs")
#' result <- charisma(img, threshold = 0.05, logdir = out_dir)
#'
#' # View results
#' plot(result)
#' }
#'
#' # Interactive mode with manual curation (only runs in interactive sessions)
#' if (interactive()) {
#'   img <- system.file("extdata", "Tangara_fastuosa_LACM60421.png",
#'                      package = "charisma")
#'   result <- charisma(img, interactive = TRUE, threshold = 0.0)
#' }
#'
#' @export
charisma <- function(
  img_path,
  threshold = 0.0,
  auto.drop = TRUE,
  interactive = FALSE,
  plot = FALSE,
  pavo = TRUE,
  logdir = NULL,
  stack_colors = TRUE,
  bins = 4,
  cutoff = 20,
  k.override = NULL,
  clut = charisma::clut
) {
  cur_date_time <- format(Sys.time(), "%m-%d-%Y_%H.%M.%S")
  original_img_path_class <- inherits(img_path, "charisma2")

  # load image with clustered centers (i.e., for the charisma2 function)
  if (inherits(img_path, "recolorize")) {
    # input var "img_path" is not actually a path to an image in this case
    # but rather is an object that inherits class `recolorize`
    # therefore, store original path to image first for later saving out
    PATH_TO_IMG <- tryCatch(
      {
        eval(img_path$path)
      },
      error = function(e) {
        # if eval fails, try to use the path directly
        if (is.character(img_path$path)) {
          img_path$path
        } else {
          # if path is an expression, convert to character
          as.character(img_path$path)
        }
      }
    )

    # ensure PATH_TO_IMG is a single character string
    if (length(PATH_TO_IMG) > 1) {
      PATH_TO_IMG <- PATH_TO_IMG[1]
    }
    PATH_TO_IMG_SET <- generate_filename(PATH_TO_IMG)
    PATH_TO_IMG <- PATH_TO_IMG_SET$new_filename
    if (!is.null(logdir)) {
      check_logdir <- dir.exists(logdir)
      if (!check_logdir) {
        new_logdir <- generate_filename(logdir, check_dir_plus_base = TRUE)
        logdir <- new_logdir$new_filename
      }
    }

    if (interactive) {
      img_interactive <- interactive_session(img_path, is.charisma2 = TRUE)
      img <- img_interactive$final_img
    } else {
      img <- img_path
    }
  } else {
    PATH_TO_IMG <- img_path
    list.img <- load_image(
      img_path,
      interactive = interactive,
      bins = bins,
      cutoff = cutoff
    )
    img <- list.img$final_img
  }

  if (original_img_path_class) {
    RDS_OUT <- file.path(
      logdir,
      "charisma_objects",
      paste0(
        tools::file_path_sans_ext(basename(PATH_TO_IMG)),
        "_charisma2_",
        cur_date_time,
        ".RDS"
      )
    )
    PDF_OUT <- file.path(
      logdir,
      "diagnostic_plots",
      paste0(
        tools::file_path_sans_ext(basename(PATH_TO_IMG)),
        "_charisma2_",
        cur_date_time,
        ".pdf"
      )
    )
  } else {
    RDS_OUT <- file.path(
      logdir,
      "charisma_objects",
      paste0(
        tools::file_path_sans_ext(basename(PATH_TO_IMG)),
        "_charisma_",
        cur_date_time,
        ".RDS"
      )
    )
    PDF_OUT <- file.path(
      logdir,
      "diagnostic_plots",
      paste0(
        tools::file_path_sans_ext(basename(PATH_TO_IMG)),
        "_charisma_",
        cur_date_time,
        ".pdf"
      )
    )
  }

  # get proportion table for cluster centers
  sizes_prop <- prop.table(img$sizes)

  # combine clustered data
  color_data <- as.data.frame(cbind(
    img$centers * 255,
    t(t(img$sizes)),
    t(t(sizes_prop))
  ))
  colnames(color_data) <- c("r", "g", "b", "size", "prop")

  # get discrete color names for clusters
  color_labels <- rep(NA, nrow(color_data))

  for (color in 1:length(color_labels)) {
    color_labels[color] <- color2label(
      c(color_data$r[color], color_data$g[color], color_data$b[color]),
      clut = clut
    )
  }

  # combine label classifications with color data
  color_data <- cbind(color_data, classification = t(t(color_labels)))

  # masked plot
  color_mask_LUT <- color_data %>%
    group_by(classification) %>%
    mutate(r_avg = mean(r), g_avg = mean(g), b_avg = mean(b)) %>%
    ungroup() %>%
    rowwise() %>%
    mutate(hex = rgb(r_avg, g_avg, b_avg, maxColorValue = 255)) %>%
    ungroup() %>%
    mutate(assignment_class = rownames(.)) %>%
    tibble::add_row(
      data.frame(
        r = NA,
        g = NA,
        b = NA,
        size = NA,
        prop = NA,
        classification = NA,
        r_avg = NA,
        g_avg = NA,
        b_avg = NA,
        hex = "#FFFFFF",
        assignment_class = "0"
      ),
      .before = 1
    )

  px_assignments_copy <- img$pixel_assignments

  match_indices <- px_assignments_copy %in% color_mask_LUT$assignment_class

  px_assignments_copy[match_indices] <-
    color_mask_LUT$hex[match(
      px_assignments_copy[match_indices],
      color_mask_LUT$assignment_class
    )]

  # stack by color (if requested)
  if (stack_colors) {
    color_data <- aggregate(
      cbind(size, prop) ~ classification,
      data = color_data,
      FUN = sum
    )
  }

  # filter out colors based on proportion threshold (if set)
  if (threshold > 0) {
    color_data_no_threshold <- color_data
  } else {
    color_data_no_threshold <- NULL
  }

  color_data <- color_data[color_data$prop >= threshold, ]

  # find colors classes that were removed via thresholding
  dropped_colors <-
    color_data_no_threshold$classification[
      !color_data_no_threshold$classification %in% color_data$classification
    ]

  color_mask_LUT_filtered <- NULL

  if (pavo) {
    if (length(get_colors(color_data)) == 0) {
      stop("All colors dropped! Consider re-running with a lower threshold...")
    }

    if (length(dropped_colors) > 0) {
      possible_color_choices <- get_colors(color_data)
      color_mask_LUT_filtered <- color_mask_LUT

      if (auto.drop) {
        if (length(dropped_colors) == 1) {
          drop_str <- " class was "
        } else {
          drop_str <- " classes were "
        }

        message(paste0(
          "\n",
          length(dropped_colors),
          drop_str,
          "dropped based on your threshold of ",
          threshold,
          ".\n\nReplacement colors for these dropped classes are",
          "being automatically selected based on the pairwise",
          "Euclidean distances between colors classes in the RGB",
          "space so that `pavo` will receive a complete image",
          "mask for downstream calculations!"
        ))

        message(
          "\n>> The following color categories will be used for remapping:"
        )

        remappable_colors <- list()

        for (choice in possible_color_choices) {
          message(paste0(" - ", choice))
          row_ids <- color_mask_LUT$classification == choice
          row_ids[1] <- FALSE
          matching_rows <- color_mask_LUT[row_ids, ]
          remappable_colors[[choice]] <- c(
            matching_rows$r_avg[1],
            matching_rows$g_avg[1],
            matching_rows$b_avg[1]
          )
        }

        message(" ")

        for (dropped_color in dropped_colors) {
          dropped.color.matching_rows_ids <-
            color_mask_LUT$classification == dropped_color
          dropped.color.matching_rows_ids[1] <- FALSE
          dropped.color.matching_rows <-
            color_mask_LUT[dropped.color.matching_rows_ids, ]

          get_color_distance <- function(color1, color2) {
            sqrt(sum((color1 - color2)^2))
          }

          dropped_color_rgb <- c(
            dropped.color.matching_rows$r_avg[1],
            dropped.color.matching_rows$g_avg[1],
            dropped.color.matching_rows$b_avg[1]
          )

          # calculate pairwise distances
          distances <- list()
          for (choice in possible_color_choices) {
            distances[[choice]] <- get_color_distance(
              dropped_color_rgb,
              remappable_colors[[choice]]
            )
          }

          sorted_distances <- round(sort(unlist(distances)), 2)

          formatted_distances <- sapply(
            names(sorted_distances),
            function(name) {
              paste0("  * ", name, " => ", sorted_distances[name])
            }
          )

          message(paste("Distances between", dropped_color, "and:"))

          for (comparison in formatted_distances) {
            message(comparison)
          }

          distances <- unlist(distances)
          min_dist <- min(distances)
          n_mins <- sum(distances == min_dist)
          min_dist_names <- names(which(distances == min_dist))

          if (n_mins > 1) {
            warning(paste0("There are > 1 (", n_mins, ") distances minimized:"))

            for (name in min_dist_names) {
              message(paste0(" - ", name))
            }

            message(" ")

            IS_VALID_COLOR <- FALSE
            TMP_REPLACEMENT_COLOR <- readline(paste0(
              " ** replace ",
              dropped_color,
              " with (",
              min_dist_names,
              ") -> "
            ))
            TMP_REPLACEMENT_COLOR <- as.character(TMP_REPLACEMENT_COLOR)

            if (TMP_REPLACEMENT_COLOR %in% possible_color_choices) {
              IS_VALID_COLOR <- TRUE
            }

            while (!IS_VALID_COLOR) {
              if (!TMP_REPLACEMENT_COLOR %in% possible_color_choices) {
                TMP_REPLACEMENT_COLOR <- readline(paste0(
                  " ** TRY AGAIN: replace ",
                  dropped_color,
                  " with (",
                  min_dist_names,
                  ") -> "
                ))
                TMP_REPLACEMENT_COLOR <- as.character(TMP_REPLACEMENT_COLOR)
                if (TMP_REPLACEMENT_COLOR %in% possible_color_choices) {
                  IS_VALID_COLOR <- TRUE
                }
              }
            }
          } else {
            TMP_REPLACEMENT_COLOR <- names(which.min(distances))
          }
          message(paste0(
            "...Replacing ",
            dropped_color,
            " with ",
            TMP_REPLACEMENT_COLOR,
            "\n"
          ))

          new.color.matching_rows_ids <-
            color_mask_LUT$classification == TMP_REPLACEMENT_COLOR
          new.color.matching_rows_ids[1] <- FALSE
          new.color.matching_rows <-
            color_mask_LUT[new.color.matching_rows_ids, ]

          old.color.matching_rows_ids <-
            color_mask_LUT$classification == dropped_color
          old.color.matching_rows_ids[1] <- FALSE
          old.color.matching_rows <- color_mask_LUT[
            old.color.matching_rows_ids,
          ]
          old.color.matching_rows_n <- nrow(old.color.matching_rows)

          # get new values
          new.color.r <- rep(NA, old.color.matching_rows_n)
          new.color.g <- rep(NA, old.color.matching_rows_n)
          new.color.b <- rep(NA, old.color.matching_rows_n)
          new.color.classification <- rep(
            TMP_REPLACEMENT_COLOR,
            old.color.matching_rows_n
          )
          new.color.r_avg <- rep(
            new.color.matching_rows$r_avg[1],
            old.color.matching_rows_n
          )
          new.color.g_avg <- rep(
            new.color.matching_rows$g_avg[1],
            old.color.matching_rows_n
          )
          new.color.b_avg <- rep(
            new.color.matching_rows$b_avg[1],
            old.color.matching_rows_n
          )
          new.color.hex <- rep(
            new.color.matching_rows$hex[1],
            old.color.matching_rows_n
          )

          # set new values
          color_mask_LUT_filtered[
            old.color.matching_rows_ids,
            "r"
          ] <- new.color.r
          color_mask_LUT_filtered[
            old.color.matching_rows_ids,
            "g"
          ] <- new.color.g
          color_mask_LUT_filtered[
            old.color.matching_rows_ids,
            "b"
          ] <- new.color.b
          color_mask_LUT_filtered[
            old.color.matching_rows_ids,
            "classification"
          ] <-
            new.color.classification
          color_mask_LUT_filtered[
            old.color.matching_rows_ids,
            "r_avg"
          ] <- new.color.r_avg
          color_mask_LUT_filtered[
            old.color.matching_rows_ids,
            "g_avg"
          ] <- new.color.g_avg
          color_mask_LUT_filtered[
            old.color.matching_rows_ids,
            "b_avg"
          ] <- new.color.b_avg
          color_mask_LUT_filtered[
            old.color.matching_rows_ids,
            "hex"
          ] <- new.color.hex
        }

        message(" ")
      } else {
        if (length(get_colors(color_data)) == 0) {
          stop(
            "All colors dropped! Consider re-running with a lower threshold..."
          )
        }

        if (length(dropped_colors) == 1) {
          drop_str <- " class was "
        } else {
          drop_str <- " classes were "
        }

        message(paste0(
          "\n",
          length(dropped_colors),
          drop_str,
          "dropped based on your threshold of ",
          threshold,
          ".\n\nYou must manually specify replacement colors for",
          "these dropped classes for `pavo` to receive a complete",
          "image mask for downstream calculations! "
        ))

        message("\n>> Please select from the following color categories:")
        for (choice in possible_color_choices) {
          message(paste0(" - ", choice))
        }

        message(" ")

        for (dropped_color in dropped_colors) {
          IS_VALID_COLOR <- FALSE
          TMP_REPLACEMENT_COLOR <- readline(paste0(
            " ** replace ",
            dropped_color,
            " with -> "
          ))
          TMP_REPLACEMENT_COLOR <- as.character(TMP_REPLACEMENT_COLOR)

          if (TMP_REPLACEMENT_COLOR %in% possible_color_choices) {
            IS_VALID_COLOR <- TRUE
          }

          while (!IS_VALID_COLOR) {
            if (!TMP_REPLACEMENT_COLOR %in% possible_color_choices) {
              TMP_REPLACEMENT_COLOR <- readline(paste0(
                " ** TRY AGAIN: replace ",
                dropped_color,
                " with -> "
              ))
              TMP_REPLACEMENT_COLOR <- as.character(TMP_REPLACEMENT_COLOR)
              if (TMP_REPLACEMENT_COLOR %in% possible_color_choices) {
                IS_VALID_COLOR <- TRUE
              }
            }
          }

          new.color.matching_rows_ids <-
            color_mask_LUT$classification == TMP_REPLACEMENT_COLOR
          new.color.matching_rows_ids[1] <- FALSE
          new.color.matching_rows <-
            color_mask_LUT[new.color.matching_rows_ids, ]

          old.color.matching_rows_ids <-
            color_mask_LUT$classification == dropped_color
          old.color.matching_rows_ids[1] <- FALSE
          old.color.matching_rows <-
            color_mask_LUT[old.color.matching_rows_ids, ]
          old.color.matching_rows_n <- nrow(old.color.matching_rows)

          # get new values
          new.color.r <- rep(NA, old.color.matching_rows_n)
          new.color.g <- rep(NA, old.color.matching_rows_n)
          new.color.b <- rep(NA, old.color.matching_rows_n)
          new.color.classification <- rep(
            TMP_REPLACEMENT_COLOR,
            old.color.matching_rows_n
          )
          new.color.r_avg <- rep(
            new.color.matching_rows$r_avg[1],
            old.color.matching_rows_n
          )
          new.color.g_avg <- rep(
            new.color.matching_rows$g_avg[1],
            old.color.matching_rows_n
          )
          new.color.b_avg <- rep(
            new.color.matching_rows$b_avg[1],
            old.color.matching_rows_n
          )
          new.color.hex <- rep(
            new.color.matching_rows$hex[1],
            old.color.matching_rows_n
          )

          # set new values
          color_mask_LUT_filtered[
            old.color.matching_rows_ids,
            "r"
          ] <- new.color.r
          color_mask_LUT_filtered[
            old.color.matching_rows_ids,
            "g"
          ] <- new.color.g
          color_mask_LUT_filtered[
            old.color.matching_rows_ids,
            "b"
          ] <- new.color.b
          color_mask_LUT_filtered[
            old.color.matching_rows_ids,
            "classification"
          ] <- new.color.classification
          color_mask_LUT_filtered[
            old.color.matching_rows_ids,
            "r_avg"
          ] <- new.color.r_avg
          color_mask_LUT_filtered[
            old.color.matching_rows_ids,
            "g_avg"
          ] <- new.color.g_avg
          color_mask_LUT_filtered[
            old.color.matching_rows_ids,
            "b_avg"
          ] <- new.color.b_avg
          color_mask_LUT_filtered[
            old.color.matching_rows_ids,
            "hex"
          ] <- new.color.hex
        }

        message(" ")
      }
    }
  }
  # sort classifications
  if (threshold > 0) {
    color_data_no_threshold <- color_data_no_threshold[
      order(color_data_no_threshold$prop, decreasing = TRUE),
    ]
  }
  color_data <- color_data[order(color_data$prop, decreasing = TRUE), ]

  output.list <- vector("list", length = 32)
  output.list_names <- c(
    "path",
    "bins",
    "cutoff",
    "colors",
    "k",
    "k_override",
    "prop_threshold",
    "charisma_calls_table_no_threshold",
    "charisma_calls_table",
    "dropped_colors",
    "original_img",
    "pixel_assignments",
    "color_mask",
    "color_mask_LUT",
    "color_mask_LUT_filtered",
    "sizes",
    "centers",
    "pavo",
    "pavo_adj_stats",
    "pavo_adj_class",
    "pavo_adj_class_plot_cols",
    "input2pavo",
    "interactive",
    "replacement_history",
    "replacement_states",
    "merge_history",
    "merge_states",
    "logdir",
    "auto_drop",
    "stack_colors",
    "clut",
    "call"
  )

  message(paste0("Discrete color classes identified: k=", get_k(color_data)))
  message(paste0(
    "(",
    paste(sort(get_colors(color_data)), collapse = ", "),
    ")"
  ))

  names(output.list) <- output.list_names

  output.list$bins <- bins
  output.list$cutoff <- cutoff
  output.list$colors <- get_colors(color_data)
  output.list$k <- get_k(color_data)
  output.list$k_override <- k.override
  output.list$prop_threshold <- threshold
  output.list$charisma_calls_table_no_threshold <- color_data_no_threshold
  output.list$charisma_calls_table <- color_data
  output.list$dropped_colors <- dropped_colors
  output.list$original_img <- img$original_img
  output.list$pixel_assignments <- img$pixel_assignments
  output.list$color_mask <- px_assignments_copy
  output.list$color_mask_LUT <- color_mask_LUT
  output.list$color_mask_LUT_filtered <- color_mask_LUT_filtered
  output.list$sizes <- img$sizes
  output.list$centers <- img$centers
  output.list$pavo <- pavo

  if (inherits(img_path, "recolorize")) {
    if (!interactive) {
      output.list$path <- img$path
      output.list$replacement_history <- img$replacement_history
      output.list$replacement_states <- img$replacement_states
      output.list$merge_history <- img$merge_history
      output.list$merge_states <- img$merge_states
    } else {
      output.list$path <- img_path$path
      output.list$replacement_history <- img_interactive$replacement_history
      output.list$replacement_states <- img_interactive$replacement_states
      output.list$merge_history <- img_interactive$merge_history
      output.list$merge_states <- img_interactive$merge_states
    }
  } else {
    output.list$path <- img_path
    output.list$merge_history <- list.img$merge_history
    output.list$merge_states <- list.img$merge_states
    output.list$replacement_history <- list.img$replacement_history
    output.list$replacement_states <- list.img$replacement_states
  }

  output.list$interactive <- interactive
  output.list$logdir <- logdir
  output.list$stack_colors <- stack_colors
  output.list$auto_drop <- auto.drop
  output.list$clut <- clut
  output.list$call <- match.call()

  class(output.list) <- "charisma"

  if (pavo) {
    tmp_pavo_adj <- pavo_classify_charisma(
      output.list,
      k_override = k.override,
      plot = plot
    )
    output.list$input2pavo <- tmp_pavo_adj$input2pavo
    output.list$pavo_adj_stats <- tmp_pavo_adj$adj_stats
    output.list$pavo_adj_class <- tmp_pavo_adj$adj_class
    output.list$pavo_adj_class_plot_cols <- tmp_pavo_adj$adj_class_plot_cols
  }

  if (!is.null(logdir)) {
    # handle logdir creation with fallback for non-existent paths
    logdir_success <- tryCatch(
      {
        if (!dir.exists(logdir)) {
          dir.create(logdir, recursive = TRUE)
        }
        TRUE
      },
      error = function(e) {
        FALSE
      },
      warning = function(w) {
        FALSE
      }
      TRUE
    }, error = function(e) {
      FALSE
    }, warning = function(w) {
      FALSE
    })

    # if original logdir fails, create fallback directory
    if (!logdir_success || !dir.exists(logdir)) {
      original_logdir <- logdir
      logdir <- file.path(tempdir(), "charisma_outputs")

      message(paste(
        "\nWARNING: Could not create original logdir:",
        original_logdir,
        "\nUsing fallback directory:",
        logdir
      ))

      # update output paths to use new logdir
      if (original_img_path_class) {
        RDS_OUT <- file.path(
          logdir,
          "charisma_objects",
          paste0(
            tools::file_path_sans_ext(basename(PATH_TO_IMG)),
            "_charisma2_",
            cur_date_time,
            ".RDS"
          )
        )
        PDF_OUT <- file.path(
          logdir,
          "diagnostic_plots",
          paste0(
            tools::file_path_sans_ext(basename(PATH_TO_IMG)),
            "_charisma2_",
            cur_date_time,
            ".pdf"
          )
        )
      } else {
        RDS_OUT <- file.path(
          logdir,
          "charisma_objects",
          paste0(
            tools::file_path_sans_ext(basename(PATH_TO_IMG)),
            "_charisma_",
            cur_date_time,
            ".RDS"
          )
        )
        PDF_OUT <- file.path(
          logdir,
          "diagnostic_plots",
          paste0(
            tools::file_path_sans_ext(basename(PATH_TO_IMG)),
            "_charisma_",
            cur_date_time,
            ".pdf"
          )
        )
      }

      # create fallback directory
      dir.create(logdir, recursive = TRUE, showWarnings = FALSE)
    }

    # create subdirs with error handling
    tryCatch({
      if (!dir.exists(file.path(logdir, "charisma_objects"))) {
        dir.create(file.path(logdir, "charisma_objects"), recursive = TRUE)
      }
    }, error = function(e) {
      warning("Could not create charisma_objects directory")
    })

    tryCatch({
      if (!dir.exists(file.path(logdir, "diagnostic_plots"))) {
        dir.create(file.path(logdir, "diagnostic_plots"), recursive = TRUE)
      }
    }, error = function(e) {
      warning("Could not create diagnostic_plots directory")
    })

    # save RDS file with error handling
    tryCatch(
      {
        message(paste("Writing out charisma object to:", RDS_OUT))
        saveRDS(output.list, RDS_OUT)
      },
      error = function(e) {
        warning(paste("Could not save charisma object:", e$message))
      }
    )

    # save PDF file with error handling
    tryCatch(
      {
        message(paste("Writing out charisma plot to:", PDF_OUT))
        pdf(PDF_OUT, width = 12, height = 9)
        plot.charisma(output.list, plot.all = TRUE, props.x.cex = 1)
        dev.off()
      },
      error = function(e) {
        warning(paste("Could not save charisma plot:", e$message))
        # make sure to close any open graphics device
        if (dev.cur() > 1) {
          dev.off()
        }
      }
    )

    # update the logdir in the output object to reflect the actual used directory
    output.list$logdir <- logdir
  }

  return(output.list)
}
