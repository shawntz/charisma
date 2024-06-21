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

plot_props <- function(charisma_obj, use.default.bar.colors = T, cex = 1.5,
                       mar = c(5.5, 8, 5, 0)) {
  par(mar = mar)

  if (length(charisma_obj$dropped_colors) > 0) {
    color_table <- charisma_obj$charisma_calls_table_no_threshold
  } else {
    color_table <- charisma_obj$charisma_calls_table
  }

  hex <- get_lut_hex()

  color_summary <- hex %>%
    dplyr::rename(classification = color.name) %>%
    dplyr::left_join(color_table, by = "classification")

  cluster_specific_hex_vals <- charisma_obj$color_mask_LUT %>%
    dplyr::group_by(classification, hex) %>%
    dplyr::summarise(mean_prop = mean(prop)) %>%
    dplyr::select(-mean_prop) %>%
    dplyr::rename(new.hex = hex) %>%
    dplyr::right_join(color_summary, by = "classification") %>%
    dplyr::arrange(classification)

  if (use.default.bar.colors) {
    bar_colors = cluster_specific_hex_vals$default.hex
  } else {
    bar_colors = cluster_specific_hex_vals$new.hex
  }

  freq_bar <- barplot(height = cluster_specific_hex_vals$prop,
                      xaxt = "n",
                      col = bar_colors,
                      main = paste0("Color Profile (k = ", charisma_obj$k, ", ",
                                    (charisma_obj$prop_threshold*100), "%)"),
                      ylim = c(0,1), ylab = "Proportion of Image\n", las = 2)

  labels <- cluster_specific_hex_vals$classification
  axis(1, at = freq_bar, tick = FALSE, labels = FALSE)

  for (i in 1:length(labels)) {
    if (!is.na(cluster_specific_hex_vals$prop[i])) {
      if (cluster_specific_hex_vals$prop[i] > charisma_obj$prop_threshold) {
        mtext(labels[i], side = 1, at = freq_bar[i], line = 1,
              cex = cex, col = "black", srt = 45, font = 2, las = 2) # bold
      } else {
        mtext(labels[i], side = 1, at = freq_bar[i], line = 1, cex = cex,
              col = "gray50", srt = 45, font = 3, las = 2) # italicized
      }
    } else {
      mtext(labels[i], side = 1, at = freq_bar[i], line = 1, cex = cex, col = "gray85", srt = 45, font = 1, las = 2)
    }
  }

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
