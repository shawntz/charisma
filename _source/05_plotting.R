countHitsByColor <- function(hits_output)
{
  hits_id_color <- with(hits_output, table(Color.ID, Color.Name))
  return(hits_id_color)
}

countHitsByID <- function(hits_output)
{
  hits_id_color <- countHitsByColor(hits_output)
  total_hits_by_id <- apply(hits_id_color, 1, sum)
  return(total_hits_by_id)
}

updateColorTableWithHits <- function(hits, all = T, source_color_table = color_table)
{
  mx_ht <- max(hits)
  
  hits <- as.data.frame(hits)
  hits$id <- rownames(hits)
  source_color_table <- merge(source_color_table, hits, by = "id", all = all)
  source_color_table <- replace(source_color_table, is.na(source_color_table), 0)
  
  source_color_table <- source_color_table %>%
    add_column(height = mx_ht) %>%
    rowwise() %>%
    mutate(hexcolors = rgb2hex(r, g, b)) %>%
    arrange(color)
  
  return(source_color_table)
}

extractDiscreteColorNamesPlot <- function(classification, source_color_table = color_table)
{
  extracted_colors <- getDiscreteColors(classification)
  return(sort(extracted_colors))
}

plotHits <- function(hex_color_data_all, hex_color_data_local, classification, loc, img, w = plotWidth, h = plotHeight)
{
  extracted_discrete_colors <- extractDiscreteColorNamesPlot(classification)
  
  #Plot Panel 1
  ref_img <- magick::image_ggplot(magick::image_read(file.path(images_masked_path, basename(img)))) + ggtitle(label = basename(img), subtitle = paste0(toString(extracted_discrete_colors), "\n(k=", length(extracted_discrete_colors), ")"))
  
  #Plot Panel 2
  p_all <- ggplot(hex_color_data_all, aes(x=nickname, y=height, fill=nickname)) +
    geom_bar(stat = "identity", alpha = 0.1) +
    geom_bar(aes(x=nickname, y=hits, fill=nickname), stat = "identity") +
    scale_fill_manual(values = hex_color_data_all$hexcolors) +
    theme(axis.text.x=element_blank()) + 
    ggtitle("Global Distribution") + 
    xlab("Reference Color") +
    ylab("Color Frequency") +
    theme(legend.position = "none")
  
  #Plot Panel 3
  p_local <- ggplot(hex_color_data_local, aes(x=nickname, y=height, fill=nickname)) +
    geom_bar(stat = "identity", alpha = 0.1) +
    geom_bar(aes(x=nickname, y=hits, fill=nickname), stat = "identity") +
    scale_fill_manual(values = hex_color_data_local$hexcolors) +
    theme(axis.text.x=element_blank()) + 
    ggtitle("Local Distribution") +
    xlab("Reference Color") +
    ylab("Color Frequency") +
    theme(legend.position = "none")
  
  #Stitch Plots Together
  p_grid <- gridExtra::grid.arrange(ref_img, p_all, p_local, nrow = 1)
  ggplot2::ggsave(file.path(loc, paste0("diagnostic_", basename(img))), p_grid, width = w, height = h, units = "in")
}