#' Add together two numbers
#'
#' @param x A number
#' @param y A number
#' @return The sum of \code{x} and \code{y}
#' @examples
#' add(1, 1)
#' add(10, 1)
#'
#' @export
charisma <- function(img_path, threshold = 0.0, auto.drop = T,
                     interactive = F, plot = F, pavo = T, logdir = NULL,
                     stack_colors = T, bins = 4, cutoff = 20, lut = color.lut) {
  cur_date_time <- format(Sys.time(), "%m-%d-%Y_%H.%M.%S")
  original_img_path_class <- inherits(img_path, "charisma2")

  # load image with clustered centers (i.e., for the charisma2 function)
  if (inherits(img_path, "recolorize")) {
    # input var "img_path" is not actually a path to an image in this case
    # but rather is an object that inherits class `recolorize`
    # therefore, store original path to image first for later saving out
    PATH_TO_IMG <- img_path$path
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
    list.img <- load_image(img_path, interactive = interactive,
                           bins = bins, cutoff = cutoff)
    img <- list.img$final_img
  }

  if (original_img_path_class) {
    RDS_OUT <- file.path(logdir, "charisma_objects", paste0(tools::file_path_sans_ext(basename(PATH_TO_IMG)),
                                                            "_charisma2_",
                                                            cur_date_time, ".RDS"))
    PDF_OUT <- file.path(logdir, "diagnostic_plots",
                         paste0(tools::file_path_sans_ext(basename(PATH_TO_IMG)),
                                "_charisma2_", cur_date_time, ".pdf"))

  } else {
    RDS_OUT <- file.path(logdir, "charisma_objects", paste0(tools::file_path_sans_ext(basename(PATH_TO_IMG)),
                                                            "_charisma_",
                                                            cur_date_time, ".RDS"))
    PDF_OUT <- file.path(logdir, "diagnostic_plots",
                         paste0(tools::file_path_sans_ext(basename(PATH_TO_IMG)),
                                "_charisma_", cur_date_time, ".pdf"))
  }

  # get proportion table for cluster centers
  sizes_prop <- prop.table(img$sizes)

  # combine clustered data
  color_data <- as.data.frame(cbind(img$centers*255,
                                    t(t(img$sizes)),
                                    t(t(sizes_prop))))
  colnames(color_data) <- c("r", "g", "b", "size", "prop")

  # get discrete color names for clusters
  color_labels <- rep(NA, nrow(color_data))

  for (color in 1:length(color_labels)) {
    color_labels[color] <- color2label(c(color_data$r[color],
                                         color_data$g[color],
                                         color_data$b[color]),
                                       lut = lut)
  }

  # combine label classifications with color data
  color_data <- cbind(color_data, classification = t(t(color_labels)))

  # masked plot
  color_mask_LUT <- color_data %>%
    group_by(classification) %>%
    mutate(r_avg = mean(r),
           g_avg = mean(g),
           b_avg = mean(b)) %>%
    ungroup() %>%
    rowwise() %>%
    mutate(hex = rgb(r_avg, g_avg, b_avg, maxColorValue = 255)) %>%
    ungroup() %>%
    mutate(assignment_class = rownames(.)) %>%
    add_row(data.frame(
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
      assignment_class = '0'
    ), .before = 1)

  px_assignments_copy <- img$pixel_assignments

  match_indices <- px_assignments_copy %in% color_mask_LUT$assignment_class

  px_assignments_copy[match_indices] <-
    color_mask_LUT$hex[match(px_assignments_copy[match_indices],
                             color_mask_LUT$assignment_class)]

  # stack by color (if requested)
  if (stack_colors) {
    color_data <- aggregate(cbind(size, prop) ~ classification,
                            data = color_data, FUN = sum)
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

        message(paste0("\n", length(dropped_colors), drop_str,
                       "dropped based on your threshold of ",
                       threshold,
                       ".\n\nReplacement colors for these dropped classes are",
                       "being automatically selected based on the pairwise",
                       "Euclidean distances between colors classes in the RGB",
                       "space so that `pavo` will receive a complete image",
                       "mask for downstream calculations!"))

        message("\n>> The following color categories will be used for remapping:")

        remappable_colors <- list()

        for (choice in possible_color_choices) {
          message(paste0(" - ", choice))
          row_ids <- color_mask_LUT$classification == choice
          row_ids[1] <- FALSE
          matching_rows <- color_mask_LUT[row_ids,]
          remappable_colors[[choice]] <- c(matching_rows$r_avg[1],
                                        matching_rows$g_avg[1],
                                        matching_rows$b_avg[1])
        }

        message(" ")

        for (dropped_color in dropped_colors) {
          dropped.color.matching_rows_ids <-
            color_mask_LUT$classification == dropped_color
          dropped.color.matching_rows_ids[1] <- FALSE
          dropped.color.matching_rows <-
            color_mask_LUT[dropped.color.matching_rows_ids,]

          get_color_distance <- function(color1, color2) {
            sqrt(sum((color1 - color2)^2))
          }

          dropped_color_rgb <- c(dropped.color.matching_rows$r_avg[1],
                                 dropped.color.matching_rows$g_avg[1],
                                 dropped.color.matching_rows$b_avg[1])

          # calculate pairwise distances
          distances <- list()
          for (choice in possible_color_choices) {
            distances[[choice]] <- get_color_distance(dropped_color_rgb,
                                                      remappable_colors[[choice]])
          }

          sorted_distances <- round(sort(unlist(distances)), 2)

          formatted_distances <- sapply(names(sorted_distances), function(name) {
            paste0("  * ", name, " => ", sorted_distances[name])
          })

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
            TMP_REPLACEMENT_COLOR <- readline(paste0(" ** replace ",
                                                     dropped_color,
                                                     " with (",
                                                     min_dist_names,
                                                     ") -> "))
            TMP_REPLACEMENT_COLOR <- as.character(TMP_REPLACEMENT_COLOR)

            if (TMP_REPLACEMENT_COLOR %in% possible_color_choices) {
              IS_VALID_COLOR <- TRUE
            }

            while (!IS_VALID_COLOR) {
              if (!TMP_REPLACEMENT_COLOR %in% possible_color_choices) {
                TMP_REPLACEMENT_COLOR <- readline(paste0(" ** TRY AGAIN: replace ",
                                                         dropped_color,
                                                         " with (",
                                                         min_dist_names,
                                                         ") -> "))
                TMP_REPLACEMENT_COLOR <- as.character(TMP_REPLACEMENT_COLOR)
                if (TMP_REPLACEMENT_COLOR %in% possible_color_choices) {
                  IS_VALID_COLOR <- TRUE
                }
              }
            }
          } else {
            TMP_REPLACEMENT_COLOR <- names(which.min(distances))
          }
          message(paste0("...Replacing ", dropped_color,
                         " with ", TMP_REPLACEMENT_COLOR, "\n"))

          new.color.matching_rows_ids <-
            color_mask_LUT$classification == TMP_REPLACEMENT_COLOR
          new.color.matching_rows_ids[1] <- FALSE
          new.color.matching_rows <-
            color_mask_LUT[new.color.matching_rows_ids,]

          old.color.matching_rows_ids <-
            color_mask_LUT$classification == dropped_color
          old.color.matching_rows_ids[1] <- FALSE
          old.color.matching_rows <- color_mask_LUT[old.color.matching_rows_ids,]
          old.color.matching_rows_n <- nrow(old.color.matching_rows)

          # get new values
          new.color.r <- rep(NA, old.color.matching_rows_n)
          new.color.g <- rep(NA, old.color.matching_rows_n)
          new.color.b <- rep(NA, old.color.matching_rows_n)
          new.color.classification <- rep(TMP_REPLACEMENT_COLOR, old.color.matching_rows_n)
          new.color.r_avg <- rep(new.color.matching_rows$r_avg[1], old.color.matching_rows_n)
          new.color.g_avg <- rep(new.color.matching_rows$g_avg[1], old.color.matching_rows_n)
          new.color.b_avg <- rep(new.color.matching_rows$b_avg[1], old.color.matching_rows_n)
          new.color.hex <- rep(new.color.matching_rows$hex[1], old.color.matching_rows_n)

          # set new values
          color_mask_LUT_filtered[old.color.matching_rows_ids, "r"] <- new.color.r
          color_mask_LUT_filtered[old.color.matching_rows_ids, "g"] <- new.color.g
          color_mask_LUT_filtered[old.color.matching_rows_ids, "b"] <- new.color.b
          color_mask_LUT_filtered[old.color.matching_rows_ids, "classification"] <-
            new.color.classification
          color_mask_LUT_filtered[old.color.matching_rows_ids, "r_avg"] <- new.color.r_avg
          color_mask_LUT_filtered[old.color.matching_rows_ids, "g_avg"] <- new.color.g_avg
          color_mask_LUT_filtered[old.color.matching_rows_ids, "b_avg"] <- new.color.b_avg
          color_mask_LUT_filtered[old.color.matching_rows_ids, "hex"] <- new.color.hex
        }

        message(" ")
      } else {
        if (length(get_colors(color_data)) == 0) {
            stop("All colors dropped! Consider re-running with a lower threshold...")
          }

          if (length(dropped_colors) == 1) {
            drop_str <- " class was "
          } else {
            drop_str <- " classes were "
          }

          message(paste0("\n", length(dropped_colors), drop_str,
                         "dropped based on your threshold of ",
                         threshold,
                         ".\n\nYou must manually specify replacement colors for",
                         "these dropped classes for `pavo` to receive a complete",
                         "image mask for downstream calculations! "))

          message("\n>> Please select from the following color categories:")
          for (choice in possible_color_choices) {
            message(paste0(" - ", choice))
          }

          message(" ")

          for (dropped_color in dropped_colors) {
            IS_VALID_COLOR <- FALSE
            TMP_REPLACEMENT_COLOR <- readline(paste0(" ** replace ",
                                                     dropped_color,
                                                     " with -> "))
            TMP_REPLACEMENT_COLOR <- as.character(TMP_REPLACEMENT_COLOR)

            if (TMP_REPLACEMENT_COLOR %in% possible_color_choices) {
              IS_VALID_COLOR <- TRUE
            }

            while (!IS_VALID_COLOR) {
              if (!TMP_REPLACEMENT_COLOR %in% possible_color_choices) {
                TMP_REPLACEMENT_COLOR <- readline(paste0(" ** TRY AGAIN: replace ",
                                                         dropped_color,
                                                         " with -> "))
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
              color_mask_LUT[new.color.matching_rows_ids,]

            old.color.matching_rows_ids <-
              color_mask_LUT$classification == dropped_color
            old.color.matching_rows_ids[1] <- FALSE
            old.color.matching_rows <-
              color_mask_LUT[old.color.matching_rows_ids,]
            old.color.matching_rows_n <- nrow(old.color.matching_rows)

            # get new values
            new.color.r <- rep(NA, old.color.matching_rows_n)
            new.color.g <- rep(NA, old.color.matching_rows_n)
            new.color.b <- rep(NA, old.color.matching_rows_n)
            new.color.classification <- rep(TMP_REPLACEMENT_COLOR,
                                            old.color.matching_rows_n)
            new.color.r_avg <- rep(new.color.matching_rows$r_avg[1],
                                   old.color.matching_rows_n)
            new.color.g_avg <- rep(new.color.matching_rows$g_avg[1],
                                   old.color.matching_rows_n)
            new.color.b_avg <- rep(new.color.matching_rows$b_avg[1],
                                   old.color.matching_rows_n)
            new.color.hex <- rep(new.color.matching_rows$hex[1],
                                 old.color.matching_rows_n)

            # set new values
            color_mask_LUT_filtered[old.color.matching_rows_ids, "r"] <- new.color.r
            color_mask_LUT_filtered[old.color.matching_rows_ids, "g"] <- new.color.g
            color_mask_LUT_filtered[old.color.matching_rows_ids, "b"] <- new.color.b
            color_mask_LUT_filtered[old.color.matching_rows_ids, "classification"] <- new.color.classification
            color_mask_LUT_filtered[old.color.matching_rows_ids, "r_avg"] <- new.color.r_avg
            color_mask_LUT_filtered[old.color.matching_rows_ids, "g_avg"] <- new.color.g_avg
            color_mask_LUT_filtered[old.color.matching_rows_ids, "b_avg"] <- new.color.b_avg
            color_mask_LUT_filtered[old.color.matching_rows_ids, "hex"] <- new.color.hex
          }

          message(" ")
      }
    }
  }
  # sort classifications
  if (threshold > 0) {
    color_data_no_threshold <- color_data_no_threshold[order(color_data_no_threshold$prop,
                                                             decreasing = TRUE),]
  }
  color_data <- color_data[order(color_data$prop, decreasing = TRUE),]



  output.list <- vector("list", length = 31)
  output.list_names <- c("path",
                         "bins",
                         "cutoff",
                         "colors",
                         "k",
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
                         "LUT",
                         "call")

  message(paste0("Discrete color classes identified: k=", get_k(color_data)))
  message(paste0("(", paste(sort(get_colors(color_data)), collapse = ", "), ")"))

  names(output.list) <- output.list_names

  output.list$bins <- bins
  output.list$cutoff <- cutoff
  output.list$colors <- get_colors(color_data)
  output.list$k <- get_k(color_data)
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
  output.list$LUT <- lut
  output.list$call <- match.call()

  class(output.list) <- "charisma"

  if (pavo) {
    tmp_pavo_adj <- pavo_classify_charisma(output.list, plot = plot)
    output.list$input2pavo <- tmp_pavo_adj$input2pavo
    output.list$pavo_adj_stats <- tmp_pavo_adj$adj_stats
    output.list$pavo_adj_class <- tmp_pavo_adj$adj_class
    output.list$pavo_adj_class_plot_cols <- tmp_pavo_adj$adj_class_plot_cols
  }

  if (!is.null(logdir)) {
    if (!dir.exists(logdir))
      dir.create(logdir)

    # create subdirs
    if (!dir.exists(file.path(logdir, "charisma_objects"))) {
      dir.create(file.path(logdir, "charisma_objects"))
    }

    if (!dir.exists(file.path(logdir, "diagnostic_plots"))) {
      dir.create(file.path(logdir, "diagnostic_plots"))
    }

    message(paste("Writing out charisma object to:", RDS_OUT))
    saveRDS(output.list, RDS_OUT)

    message(paste("Writing out charisma plot to:", PDF_OUT))
    pdf(PDF_OUT, width = 12, height = 9)
    plot.charisma(output.list, plot.all = TRUE)
    dev.off()
  }

  return(output.list)
}
