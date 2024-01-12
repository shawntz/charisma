plot_freqs <- function(charisma_obj) {
  hex <- get_mapped_hex()
  color_summary <- hex %>% rename(classification = color.name) %>% left_join(charisma_obj$charisma_calls_table, by = "classification")
  freq_bar <- barplot(height = color_summary$prop, names = color_summary$classification, col = color_summary$default.hex,
                      main = paste0("freq (k=", charisma_obj$k, ", ", (charisma_obj$prop_threshold*100), "% thresh)"),
                      ylim = c(0,1), ylab = "Proportion of Image", las = 2)
  # text(freq_bar, round(color_summary$prop, 2) + .075, round(color_summary$prop, 2), cex = 1, srt = 90)
  if (charisma_obj$prop_threshold > 0)
    abline(h = charisma_obj$prop_threshold, col = "red", lty = "dashed")
}

