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

plotHits <- function(hex_color_data_all, hex_color_data_local, classification, loc, img, w = plotWidth, h = plotHeight, thresh = thresh)
{
  extracted_discrete_colors <- extractDiscreteColorNamesPlot(classification)
  
  extracted_color_freqs <- getColorFreqs(classification)
  extracted_color_freqs_trimmed_by_thresh <- trimColorFreqsThresh(classification, thresh)
  
  #Plot Panel 1
  ref_img <- magick::image_ggplot(magick::image_read(file.path(images_masked_path, basename(img)))) + ggtitle(basename(img)) + labs(subtitle = str_wrap(paste0(toString(extracted_color_freqs_trimmed_by_thresh$Color.Name), "\n(k=", length(extracted_color_freqs_trimmed_by_thresh$Color.Name), ")"), 10)) + theme(plot.title = element_text(size=12, vjust=100, hjust=.10), plot.subtitle = element_text(hjust=.10, vjust=-10))
  
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
  
  #Plot Panel 4
  #print(head(extracted_color_freqs))
  p_freq <- ggplot(extracted_color_freqs, aes(x=Color.Name, y=pct, fill=Color.Name)) +
    geom_bar(stat = "identity", alpha = 0.1) +
    geom_bar(aes(x=Color.Name, y=pct, fill=Color.Name), stat = "identity") +
    scale_fill_manual(values = extracted_color_freqs$Color.Name) +
    scale_y_continuous(expand = c(0, 0), limits = c(0,1)) +
    geom_text(aes(label=n), vjust=0) +
    geom_hline(yintercept=thresh, linetype="dashed", color = "red") +
    ggtitle("Color Frequency") +
    xlab("Discrete Color Class") +
    ylab("Color Proportion") +
    theme(legend.position = "none")
  
  #Stitch Plots Together
  p_grid <- gridExtra::grid.arrange(ref_img, p_all, p_local, p_freq, nrow = 1)
  #p_grid <- gridExtra::grid.arrange(p_all, p_local, ref_img, p_freq, nrow = 2)
  ggplot2::ggsave(file.path(loc, paste0("diagnostic_", basename(img))), p_grid, width = w, height = h, units = "in")
}