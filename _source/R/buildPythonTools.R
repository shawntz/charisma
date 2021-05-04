buildPythonTools <- function() {
  
  ## Get most up-to-date color mapping
  mapping <- readMapping("_source/data/mapping.csv")
  
  buildColorDetectorTool(mapping)
  
  buildColorValidationTool(mapping)
  
  cat(paste0("\n", ".py scripts successfully generated in `tools/` directory!\n\n"))
  
}