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
charisma <- function(img_path, stack_colors = TRUE, threshold = 0.0, verbose = TRUE, plot = TRUE, pavo = TRUE) {
  # load image with clustered centers
  img <- load_image(img_path, verbose = verbose, plot = plot)

  # plot final product
  #plot_recolored(img)

  # get proportion table for cluster centers
  sizes_prop <- prop.table(img$sizes)

  # combine clustered data
  color_data <- as.data.frame(cbind(img$centers*255, t(t(img$sizes)), t(t(sizes_prop))))
  colnames(color_data) <- c("r", "g", "b", "size", "prop")

  # get discrete color names for clusters
  color_labels <- rep(NA, nrow(color_data))

  for(color in 1:length(color_labels)) {
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
  color_data <- color_data[color_data$prop >= threshold, ]

  # sort classifications
  color_data <- color_data[order(color_data$prop, decreasing = TRUE), ]

  output.list <- vector("list", length = 15)
  output.list_names <- c("path",
                         "colors",
                         "k",
                         "charisma_calls_table",
                         "prop_threshold",
                         "original_img",
                         "pixel_assignments",
                         "color_mask",
                         "color_mask_LUT",
                         "sizes",
                         "centers",
                         "scaled_color_clusters",
                         "pavo_adj_stats",
                         "pav_adj_class",
                         "pavo_adj_class_plot_cols")

  names(output.list) <- output.list_names

  output.list$path <- img_path
  output.list$colors <- get_colors(color_data)
  output.list$k <- get_k(color_data)
  output.list$charisma_calls_table <- color_data
  output.list$prop_threshold <- threshold
  output.list$original_img <- img$original_img
  output.list$pixel_assignments <- img$pixel_assignments
  output.list$color_mask <- px_assignments_copy
  output.list$color_mask_LUT <- color_mask_LUT
  output.list$sizes <- img$sizes
  output.list$centers <- img$centers
  output.list$scaled_color_clusters <- NULL #TODO

  class(output.list) <- "charisma"

  if (pavo) {
    tmp_pavo_adj <- charisma::pavo_classify_charisma(output.list, plot = plot)
    output.list$pavo_adj_stats <- tmp_pavo_adj$adj_stats
    output.list$pav_adj_class <- tmp_pavo_adj$adj_class
    output.list$pavo_adj_class_plot_cols <- tmp_pavo_adj$adj_class_plot_cols
  }

  return(output.list)


  # unique colors classified
  # print(unique(color_data$classification))

  # TODO: add in a setting to automatically bypass the color swap/merge steps (to run fully automatically)
  # TODO: run the already recolorized pngs through charisma + BEFORE THAT, modify the data output so that... (with 0% threshold)
    # TODO: the `$centers` output is customized so that it has the 255 scaled RGBs with the charisma color call in a separate column for each category
    # TODO: add a save image feature for the tiled original/recolored/palette output to go along with each charisma call
  # TODO: build in a history of all swapped / merged changes so that you can reproduce the manual workflow later
  # TODO: we want to make it so that the threshold for color classes and k is applied post hoc editing so that it can be changed w/o having to repreprocess thew whole image

  # TODO: color replacement function (over the merging function) [DONE, in BETA]
  # TODO: add in a function to just spit out the k-value per image [DONE]

  # TODO: add in proportion threshold and filter out zero-prop colors (and also add same color classes together) [DONE]
  # TODO: add in mediated setting to that is synchronously swaps colors in recolorized sample + the palette (e.g., change_color(from = 2, to = 4)) [DONE]
  #  ... and make it have a 1-step back undo feature (bird_obj_copy$pixel_assignments[which(bird_obj_copy$pixel_assignments == 4)] <- 2) [DONE]
  # TODO: make it easy to save recolorized output pngs through a setting so that the output 'k' classifications matches the output recolorized image [DONE]
  # return(color_data)
}
