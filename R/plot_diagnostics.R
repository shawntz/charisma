plot_diagnostics <- function(charisma_obj, pavo = TRUE, use.default.bar.colors = FALSE) {
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
    pavo_classify_charisma(charisma_obj) ## TODO: replace this function with the individual diagnostic plots from this function
  }
}
