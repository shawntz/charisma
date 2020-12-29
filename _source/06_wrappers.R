classifyPixelsPipeline <- function(img, classification, all = T)
{
  hits_by_id <- countHitsByID(classification)
  updated_color_table <- updateColorTableWithHits(hits_by_id, all)
  return(updated_color_table)
}

getColorFreqs <- function(classification)
{
  hits_color_freqs <- classification %>% 
    dplyr::count(Color.Name) %>%
    mutate(total.calls = sum(n)) %>%
    rowwise() %>%
    mutate(pct = n/total.calls)
  
  return(hits_color_freqs)
}

trimColorFreqsThresh <- function(classification, thresh)
{
  color_freqs <- getColorFreqs(classification)
  
  color_freqs_trimmed <- data.frame(Color.Name=character(), n=numeric(), total.calls=numeric(), pct=numeric())
  
  for(ii in 1:nrow(color_freqs))
  {
    if(color_freqs$pct[ii] >= thresh)
    {
      color_freqs_trimmed <- color_freqs[ii,] %>%
        rbind(color_freqs_trimmed)
    }
  }
  
  return(color_freqs_trimmed)
}

getDiscreteColors <- function(classification)
{
  return(extractDiscreteColors(classification))
}

plotPixelsPipeline <- function(img, updated_color_table_ALL, updated_color_table_LOCAL, classifications, thresh = thresh)
{
  ##write.csv(updated_color_table_ALL, file.path(wd, "col_table_ALL_demo.csv")) ##for debugging
  ##write.csv(updated_color_table_LOCAL, file.path(wd, "col_table_LOCAL_demo.csv")) ##for debugging
  invisible(ifelse(!dir.exists(plot_output_dir), dir.create(plot_output_dir), FALSE))
  plotHits(updated_color_table_ALL, updated_color_table_LOCAL, classifications, plot_output_dir, img, plotWidth, plotHeight, thresh)
}

sortExtractedColorsPipeline <- function(extracted_colors_list, source_color_table = color_table)
{
  discrete_color_df <- data.frame(matrix(nrow = length(extracted_colors_list), ncol = getNumPossibleColors(source_color_table)))
  color_labels <- getColorLabels(source_color_table)
  colnames(discrete_color_df) <- color_labels
  
  k_values <- rep(NA, length(extracted_colors_list))
  
  for(ii in 1:length(extracted_colors_list))
  {
    k_values[ii] <- length(extracted_colors_list[[ii]])
    
    for(jj in 1:ncol(discrete_color_df))
    {
      if(color_labels[jj] %in% extracted_colors_list[[ii]])
      {
        discrete_color_df[ii,jj] <- 1
      } else
      {
        discrete_color_df[ii,jj] <- 0
      }
    }
  }
  
  color_class_data <- data.frame(matrix(ncol = (2 + getNumPossibleColors(source_color_table)), nrow = length(extracted_colors_list)))
  combo_column_names <- append(c("img", "k"), color_labels)
  colnames(color_class_data) <- combo_column_names
  color_class_data$img <- names(extracted_colors_list)
  color_class_data$k <- k_values
  k_df <- data.frame(img = names(extracted_colors_list), k = k_values)
  color_class_data_merged <- cbind(k_df, discrete_color_df)
  
  return(color_class_data_merged)
}