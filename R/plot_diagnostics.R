plot_diagnostics <- function(charisma_obj, pavo = TRUE) {
  par(mfrow=c(1,5))
  plot_original(charisma_obj)
  plot_recolored(charisma_obj)
  plot_freqs(charisma_obj)
  if (pavo) {
    pavo_classify_charisma(charisma_obj) ## TODO: replace this function with the individual diagnostic plots from this function
  }
}
