plot_original <- function(charisma_obj, mar = c(0, 0, 5, 0)) {
  par(mar = mar)
  asp <- dim(charisma_obj$original_img)[1] / dim(charisma_obj$original_img)[2]
  plot(0:1, 0:1, type = "n", axes = FALSE, asp = asp, main = "Original",
       xlab = "", ylab = "")
  graphics::rasterImage(charisma_obj$original_img, 0, 0, 1, 1)
}

plot_recolored <- function(img, mar = c(0, 0, 5, 0)) {
  par(mar = mar)
  asp <- dim(img$original_img)[1] / dim(img$original_img)[2]
  plot(0:1, 0:1, type = "n", axes = FALSE, asp = asp, main = "Recolored",
       xlab = "", ylab = "")
  graphics::rasterImage(recolorize::recoloredImage(img), 0, 0, 1, 1)
}

plot_masked <- function(img, mar = c(0, 0, 5, 0)) {
  par(mar = mar)
  asp <- dim(img$original_img)[1] / dim(img$original_img)[2]
  plot(0:1, 0:1, type = "n", axes = FALSE, asp = asp, main = "Charisma Mask",
       xlab = "", ylab = "")
  graphics::rasterImage(img$color_mask, 0, 0, 1, 1)
}

plot_props <- function(charisma_obj, use.default.bar.colors = T,
                       mar = c(5.5, 8, 5, 0)) {
  par(mar = mar)

  if (length(charisma_obj$dropped_colors) > 0) {
    color_table <- charisma_obj$charisma_calls_table_no_threshold
  } else {
    color_table <- charisma_obj$charisma_calls_table
  }

  hex <- get_lut_hex()

  color_summary <- hex %>%
    rename(classification = color.name) %>%
    left_join(color_table, by = "classification")

  cluster_specific_hex_vals <- charisma_obj$color_mask_LUT %>%
    group_by(classification, hex) %>%
    summarise(mean_prop = mean(prop)) %>%
    select(-mean_prop) %>%
    rename(new.hex = hex) %>%
    right_join(color_summary, by = "classification") %>%
    arrange(classification)

  if (use.default.bar.colors) {
    bar_colors = cluster_specific_hex_vals$default.hex
  } else {
    bar_colors = cluster_specific_hex_vals$new.hex
  }

  spacer <- "                   "

  freq_bar <- barplot(height = cluster_specific_hex_vals$prop,
                      names = cluster_specific_hex_vals$classification,
                      col = bar_colors,
                      main = paste0("(k = ", charisma_obj$k, ", ",
                                    (charisma_obj$prop_threshold*100), "%)",
                                    spacer),
                      ylim = c(0,1), ylab = "Proportion of Image\n", las = 2)

  if (charisma_obj$prop_threshold > 0) {
    abline(h = charisma_obj$prop_threshold, col = "red",
           lty = "dashed", lwd = 2)
  }
}

plot_pavo_input <- function(charisma_obj, imgdat = NULL, mar = c(0, 0, 5, 0)) {
  par(mar = mar)
  asp <- dim(charisma_obj$original_img)[1] / dim(charisma_obj$original_img)[2]
  plot(0:1, 0:1, type = "n", axes = FALSE, asp = asp, main = "Pavo",
       xlab = "", ylab = "")
  if (is.null(imgdat)) {
    graphics::rasterImage(charisma_obj$input2pavo, 0, 0, 1, 1)
  } else {
    graphics::rasterImage(imgdat, 0, 0, 1, 1)
  }
}

plot_pavo_pal <- function(charisma_obj, k = NULL, pal = NULL,
                          mar = c(0, 5, 5, 5)) {
  par(mar = mar)
  asp <- dim(charisma_obj$original_img)[1] / dim(charisma_obj$original_img)[2]

  if (is.null(pal)) {
    col_palette <- charisma_obj$pavo_adj_class_plot_cols
  } else {
    col_palette <- pal
  }

  if (is.null(k)) {
    k_col <- charisma_obj$k
  } else {
    k_col <- k
  }

  image(seq_along(col_palette), 1, as.matrix(seq_along(col_palette)),
        col = col_palette,
        main = paste0("Pavo Classes (k = ", k_col, ")"),
        xlab = "",
        ylab = "",
        xaxt = "n",
        yaxt = "n",
        asp = asp)
}
