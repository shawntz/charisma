plot_freqs <- function(charisma_obj, use.default.bar.colors = TRUE) {
  hex <- get_mapped_hex()
  color_summary <- hex %>% rename(classification = color.name) %>% left_join(charisma_obj$charisma_calls_table, by = "classification")

  cluster_specific_hex_vals <- charisma_obj$color_mask_LUT %>% group_by(classification, hex) %>% summarise(mean_prop = mean(prop)) %>% select(-mean_prop) %>% rename(new.hex = hex) %>% right_join(color_summary, by = "classification") %>% arrange(classification)

  # freq_bar <- barplot(height = color_summary$prop, names = color_summary$classification, col = color_summary$default.hex,

  if (use.default.bar.colors) {
    bar_colors = cluster_specific_hex_vals$default.hex
  } else {
    bar_colors = cluster_specific_hex_vals$new.hex
  }

  freq_bar <- barplot(height = cluster_specific_hex_vals$prop, names = cluster_specific_hex_vals$classification, col = bar_colors,
                      main = paste0("freq (k=", charisma_obj$k, ", ", (charisma_obj$prop_threshold*100), "% thresh)"),
                      ylim = c(0,1), ylab = "Proportion of Image", las = 2)
  # text(freq_bar, round(color_summary$prop, 2) + .075, round(color_summary$prop, 2), cex = 1, srt = 90)
  if (charisma_obj$prop_threshold > 0)
    abline(h = charisma_obj$prop_threshold, col = "red", lty = "dashed")
}

