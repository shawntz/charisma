classifyPixels <- function(img)
{
  if(transparency == F)
  {
    pic <- suppressMessages(colordistance::loadImage(img, lower = c(lowerR,lowerG,lowerB),
                                    upper = c(upperR,upperG,upperB), hsv = F, alpha.channel = F, alpha.message = F))
  } else
  {
    pic <- suppressMessages(colordistance::loadImage(img, lower = NULL, upper = NULL, hsv = F, alpha.channel = T, alpha.message = F))
  }
  
  pic <- pic$filtered.rgb.2d
  
  pb <- progress::progress_bar$new(total = nrow(pic), format = paste0("    Analyzing ", basename(img), " [:bar] :percent eta: :eta"), clear = F)
  output <- data.frame()
  for(i in 1:nrow(pic))
  {
    output <- rbind(output, getColorLabel(pic[i,]))
    pb$tick()
  }
  return(as.data.frame(output))
}

getColorLabel <- function(rgb_triplet, lookup_ref = color_table)
{
  minimum <- 10000
  r <- rgb_triplet[1] * 255
  g <- rgb_triplet[2] * 255
  b <- rgb_triplet[3] * 255
  
  for(i in 1:nrow(lookup_ref))
  {
    dist_calc <- abs(r - as.integer(lookup_ref$r[i])) + abs(g - as.integer(lookup_ref$g[i])) + abs(b - as.integer(lookup_ref$b[i]))
    if(dist_calc <= minimum)
    {
      minimum <- dist_calc
      color_name <- lookup_ref[i,]$color
      color_id <- lookup_ref[i,]$id
      hex_value <- rgb2hex(lookup_ref[i,]$r, lookup_ref[i,]$g, lookup_ref[i,]$b)
      delta <- as.integer(dist_calc)
    }
  }
  
  output <- data.frame("Color.ID" = color_id, "Color.Name" = color_name, "HEX" = hex_value, "delta" = delta)
  
  return(output)
}

getNumPossibleColors <- function(source_color_table = color_table)
{
  return(length(unique(source_color_table$color)))
}

getColorLabels <- function(source_color_table = color_table)
{
  return(sort(unique(source_color_table$color)))
}

extractDiscreteColors <- function(hits_output, source_color_table = color_table)
{
  extracted_colors <- NULL
  matched_ids_idx <- match(hits_output$Color.ID, source_color_table$id)
  
  for(hit in 1:length(matched_ids_idx))
  {
    extracted_colors <- append(extracted_colors, source_color_table[matched_ids_idx[hit],]$color)
  }
  return(unique(extracted_colors))
}