plot_diagnostics <- function(charisma_obj) {
  par(mfrow=c(1,5))
  plot_original(charisma_obj)
  plot_recolored(charisma_obj)
  plot_freqs(charisma_obj)
  pavo_classify_charisma(charisma_obj)
}
