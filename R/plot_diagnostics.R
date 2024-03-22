plot_diagnostics <- function(charisma_obj, pavo = TRUE, use.default.bar.colors = FALSE) {
  # check if pavo was run in original call -- reject pavo == TRUE if it wasn't

  tryCatch({
    if (
      is.null(charisma_obj$input2pavo) ||
      is.null(charisma_obj$pavo_adj_stats) ||
      is.null(charisma_obj$pavo_adj_class) ||
      is.null(charisma_obj$pavo_adj_class_plot_cols)
    ) {
      pavo <- FALSE
    }

    if (pavo) {
      par(mfrow=c(1,6))
    } else {
      par(mfrow=c(1,4))
    }
    plot_original(charisma_obj)
    plot_recolored(charisma_obj)
    plot_mask(charisma_obj)
    plot_freqs(charisma_obj, use.default.bar.colors)
    if (pavo) {
      asp <- dim(charisma_obj$original_img)[1] / dim(charisma_obj$original_img)[2]

      plot(0:1, 0:1, type = "n", axes = FALSE, asp = asp, main = "input2pavo", xlab = "", ylab = "")
      graphics::rasterImage(charisma_obj$input2pavo, 0, 0, 1, 1)

      palette <- charisma_obj$pavo_adj_class_plot_cols
      image(seq_along(palette), 1, as.matrix(seq_along(palette)),
            col = palette,
            main = paste0("pavo class (k=", charisma_obj$k, ")"),
            xlab = paste("Color class IDs: 1 -", length(palette)),
            ylab = "",
            xaxt = "n",
            yaxt = "n",
            asp = asp)
      # pavo_classify_charisma(charisma_obj) ## TODO: replace this function with the individual diagnostic plots from this function
    }
  }, error = function(e) {
    if (grepl("figure margins too large", e$message)) {
      message("Error: Issue with figure margins. Please make your RStudio's 'Plots' window wider to fit the charisma diagnostic plots. Then, re-run the same plot_diagnostics(...) code you just attempted to run!")
    } else {
      # throw any other error
      stop(e)
    }
  })

}
