summarizeCalledColorsPipeline <- function(calls, mapping, threshold = .05) {
  
  summaries <- list()
  
  for(i in 1:length(calls)) {
    summaries[[i]] <- summarizeCalledColors(calls[[i]], mapping, threshold = threshold)
  }
  
  combo_summary <- as.data.frame(do.call(rbind, summaries))
  rownames(combo_summary) <- names(calls)
  
  combo_summary <- combo_summary %>%
    mutate(k = rowSums(.))
  
  return(combo_summary)
  
}