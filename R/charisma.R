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
charisma <- function(img_path, stack_colors = TRUE, threshold = 0.0, verbose = TRUE, plot = FALSE, pavo = TRUE) {
  # load image with clustered centers
  img <- load_image(img_path, verbose = verbose, plot = plot)

  # get proportion table for cluster centers
  sizes_prop <- prop.table(img$sizes)

  # combine clustered data
  color_data <- as.data.frame(cbind(img$centers*255, t(t(img$sizes)), t(t(sizes_prop))))
  colnames(color_data) <- c("r", "g", "b", "size", "prop")

  # get discrete color names for clusters
  color_labels <- rep(NA, nrow(color_data))

  for (color in 1:length(color_labels)) {
    color_labels[color] <- parse_color(c(color_data$r[color], color_data$g[color], color_data$b[color]))
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

  px_assignments_copy[match_indices] <- color_mask_LUT$hex[match(px_assignments_copy[match_indices], color_mask_LUT$assignment_class)]

  # stack by color (if requested)
  if (stack_colors) color_data <- aggregate(cbind(size, prop) ~ classification, data = color_data, FUN = sum)

  # filter out colors based on proportion threshold (if set)
  if (threshold > 0) {
    color_data_no_threshold <- color_data
  } else {
    color_data_no_threshold <- NULL
  }
  color_data <- color_data[color_data$prop >= threshold, ]

  # find colors classes that were removed via thresholding
  dropped_colors <- color_data_no_threshold$classification[!color_data_no_threshold$classification %in% color_data$classification]

  color_mask_LUT_filtered <- NULL

  if (pavo) {
    if (length(dropped_colors) > 0) {
      message(paste0(length(dropped_colors), " color classes were dropped based on your threshold of ", threshold, ".\n\nYou must specify replacement colors for these dropped classes for `pavo` to receive a complete image mask for downstream calculations! "))

      possible_color_choices <- get_colors(color_data)
      message("\n>> Please select from the following color categories:")
      for (choice in possible_color_choices) {
        message(paste0(" - ", choice))
      }

      message(" ")

      color_mask_LUT_filtered <- color_mask_LUT

      for (dropped_color in dropped_colors) {
        IS_VALID_COLOR <- FALSE
        TMP_REPLACEMENT_COLOR <- readline(paste0(" ** replace ", dropped_color, " with -> "))
        TMP_REPLACEMENT_COLOR <- as.character(TMP_REPLACEMENT_COLOR)

        if (TMP_REPLACEMENT_COLOR %in% possible_color_choices) {
          IS_VALID_COLOR <- TRUE
        }

        while (!IS_VALID_COLOR) {
          if (!TMP_REPLACEMENT_COLOR %in% possible_color_choices) {
            TMP_REPLACEMENT_COLOR <- readline(paste0(" ** TRY AGAIN: replace ", dropped_color, " with -> "))
            TMP_REPLACEMENT_COLOR <- as.character(TMP_REPLACEMENT_COLOR)
            if (TMP_REPLACEMENT_COLOR %in% possible_color_choices) {
              IS_VALID_COLOR <- TRUE
            }
          }
        }

        new.color.matching_rows_ids <- color_mask_LUT$classification == TMP_REPLACEMENT_COLOR
        new.color.matching_rows_ids[1] <- FALSE
        new.color.matching_rows <- color_mask_LUT[new.color.matching_rows_ids,]

        old.color.matching_rows_ids <- color_mask_LUT$classification == dropped_color
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
        color_mask_LUT_filtered[old.color.matching_rows_ids, "classification"] <- new.color.classification
        color_mask_LUT_filtered[old.color.matching_rows_ids, "r_avg"] <- new.color.r_avg
        color_mask_LUT_filtered[old.color.matching_rows_ids, "g_avg"] <- new.color.g_avg
        color_mask_LUT_filtered[old.color.matching_rows_ids, "b_avg"] <- new.color.b_avg
        color_mask_LUT_filtered[old.color.matching_rows_ids, "hex"] <- new.color.hex
      }
    }
  }

  # sort classifications
  if (threshold > 0) {
    color_data_no_threshold <- color_data_no_threshold[order(color_data_no_threshold$prop, decreasing = TRUE), ]
  }
  color_data <- color_data[order(color_data$prop, decreasing = TRUE), ]

  output.list <- vector("list", length = 19)
  output.list_names <- c("path",
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
                         "pavo_adj_stats",
                         "pavo_adj_class",
                         "pavo_adj_class_plot_cols",
                         "input2pavo",
                         "call")

  names(output.list) <- output.list_names

  output.list$path <- img_path
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
  output.list$call <- match.call()

  class(output.list) <- "charisma"

  if (pavo) {
    tmp_pavo_adj <- charisma::pavo_classify_charisma(output.list, plot = plot)
    output.list$input2pavo <- tmp_pavo_adj$input2pavo
    output.list$pavo_adj_stats <- tmp_pavo_adj$adj_stats
    output.list$pavo_adj_class <- tmp_pavo_adj$adj_class
    output.list$pavo_adj_class_plot_cols <- tmp_pavo_adj$adj_class_plot_cols
  }

  return(output.list)
}
