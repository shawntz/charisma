############################################################################
############################################################################
###                                                                      ###
###                        MAIN WRAPPER FUNCTIONS                        ###
###                                                                      ###
############################################################################
############################################################################
autoComputeKPipeline <- function(path, bins = 3, diagnosticMode = FALSE, 
                     lowerR = 0.0, lowerG = 1.0, lowerB = 0.0,
                     upperR = 0.0, upperG = 1.0, upperB = 0.0,
                     mode = "lower", thresh = .05, method = "GE", colOut = FALSE, colOutPath = "./",
                     saveDiagnosticPlots = FALSE, diagnosticPlotsOutputDir = "diagnostic_outputs", width = 750, height = 500, 
                     colorspace = "rgb", colorwheel = FALSE)
{
  images <- getImages(path)
  images_names <- rep(NA, length(images))
  hist_list <- list()
  color_classes_list <- list()
  k_values <- rep(NA, length(images))
  
  for(ii in 1:length(images))
  {
    hist_list[[ii]] <- getHist(images[ii], bins = bins, plotting = FALSE,
                          lowerR = lowerR, lowerG = lowerG, lowerB = lowerB,
                          upperR = upperR, upperG = upperG, upperB = upperB, colorspace = colorspace)
    if(Sys.info()['sysname'] != "Windows")
    {
      images_names[ii] <- tail(strsplit(images[ii], "/")[[1]], 1)
    }
    else
    {
      images_names[ii] <- tail(strsplit(images[ii], "\\\\")[[1]], 1)
    }
  }
  
  for(ii in 1:length(hist_list))
  {
    color_classes_list[[ii]] <- extractColorClasses(hist_list[[ii]], mode = mode, thresh = thresh, method = method)
  }
  names(color_classes_list) <- images_names
  
  for(ii in 1:length(color_classes_list))
  {
    k_values[ii] <- getNumColorClasses(color_classes_list[[ii]])
  }
  
  if(diagnosticMode == TRUE)
  {
    for(ii in 1:length(images))
    {
      diagnosticPlot(images[ii], color_classes_list[[ii]], lowerR = lowerR, lowerG = lowerG, lowerB = lowerB,
                upperR = upperR, upperG = upperG, upperB = upperB, mode = mode, thresh = thresh, method = method, 
                savePlots = saveDiagnosticPlots, plotOutputDir = diagnosticPlotsOutputDir, width = width, height = height, colorspace = colorspace, colorwheel = colorwheel)
    }
  }
  
  color_class_data <- data.frame(img = images, k = k_values)
  
  if(colOut == TRUE)
  {
    cat(paste0("\n\nSaving k ", toupper(colorspace), " values to RDS file..."))
    saveRDS(color_classes_list, paste0(colOutPath, colorspace, "_values_output.RDS"))
    cat(paste0("Successfully saved k ", toupper(colorspace), " values to RDS file for ", length(images), " images!\n"))
  }
  
  return(color_class_data)
}

classifyColorPipeline <- function(path, kdf)
{
  classifications <- classifyByUniqueK(path, kdf)
  classified_k_dists <- suppressWarnings(getImgClassKDists(classifications, calcEucLumDists))
  adj_stats_raw <- suppressWarnings(getAdjStats(classifications, classified_k_dists, 100, 100))
  adj_stats <- suppressWarnings(getCleanedupStats(adj_stats_raw))
  
  image_paths <- kdf$img
  images_list <- rep(NA, length(image_paths))
  for(image in 1:length(images_list))
  {
    if(Sys.info()['sysname'] != "Windows")
    {
      images_list[image] <- tail(strsplit(image_paths[image], "/")[[1]], 1)
    }
    else
    {
      images_list[image] <- tail(strsplit(as.character(image_paths[image]), "\\\\")[[1]], 1)
    }
  }
  
  adj_stats <- adj_stats %>%
    mutate(name = images_list)
  
  return(adj_stats)
}

runColorPCA <- function(adj_stats)
{
  pca_input <- select(adj_stats, name, m, m_r, m_c, Sc, St, A, m_dS,m_dL) %>% as.data.frame %>%
    column_to_rownames("name")
  pca_res <- prcomp(pca_input, center = T, scale = T)
  return(pca_res)
}

getColorPCASummary <- function(pca_res)
{
  return(summary(pca_res))
}