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
  
  pb <- progress::progress_bar$new(total = nrow(pic), format = " [:bar] :percent eta: :eta", clear = F)
  
  ### SHORT WAY ###
  #output <- as.data.frame(matrix(NA, nrow = nrow(pic), ncol = 4))
  #colnames(output) <- c("Color.ID", "Color.Name", "HEX", "delta")
  #for(i in 1:nrow(pic))
  #{
  #  tmp_out <- getColorLabel(pic[i,])
  #  output[ii,] <- tmp_out
  #  pb$tick()
  #}
  
  ### LONG WAY ###
  output <- data.frame()
  for(i in 1:nrow(pic))
  {
  #  output <- rbind(output, getColorLabel(pic[i,]))
    output <- dplyr::bind_rows(output, getColorLabel(pic[i,]))
    pb$tick()
  }
  return(as.data.frame(output))
}

get_dist <- function(x, y)
{
  return(abs(x-y))
}

getColorLabel <- function(rgb_triplet, lookup_ref = color_table, minimum = 10000)
{
  R <- rgb_triplet[1] * 255
  G <- rgb_triplet[2] * 255
  B <- rgb_triplet[3] * 255
  
  index <- which.min(sapply(R,get_dist,y=lookup_ref$r) + sapply(G,get_dist,y=lookup_ref$g) + sapply(B,get_dist,y=lookup_ref$b))
  combination <- sapply(R,get_dist,y=lookup_ref$r) + sapply(G,get_dist,y=lookup_ref$g) + sapply(B,get_dist,y=lookup_ref$b)
  
  if(combination[index] <= minimum)
  {
    minimum <- combination[index]
    color_name <- lookup_ref[index,]$color
    color_id <- lookup_ref[index,]$id
    hex_value <- rgb2hex(lookup_ref[index,]$r, lookup_ref[index,]$g, lookup_ref[index,]$b)
    delta <- as.integer(combination[index])
  }
  
  output <- data.frame("Color.ID" = color_id, "Color.Name" = color_name, "HEX" = hex_value, "delta" = delta)
  return(output)
}

getColorLabelVec <- function(rgb_triplet, lookup_ref = color_table)
{
  minimum <- 10000
  R <- rgb_triplet[1] * 255
  G <- rgb_triplet[2] * 255
  B <- rgb_triplet[3] * 255
  distr<-function(x){
    distance<-abs(x-R)
    return(distance)
  }
  distg<-function(x){
    distance<-abs(x-G)
    return(distance)
  }
  distb<-function(x){
    distance<-abs(x-B)
    return(distance)
  }
  index<-which.min(sapply(lookup_ref$r,distr)+sapply(lookup_ref$g,distg)+sapply(lookup_ref$b,distb))
  combination<-sapply(lookup_ref$r,distr)+sapply(lookup_ref$g,distg)+sapply(lookup_ref$b,distb)
  if(combination[index] <= minimum)
    {
     minimum <- combination[index]
      color_name <- lookup_ref[index,]$color
      color_id <- lookup_ref[index,]$id
      hex_value <- rgb2hex(lookup_ref[index,]$r, lookup_ref[index,]$g, lookup_ref[index,]$b)
      delta <- as.integer(combination[index])
   }
  
  output <- data.frame("Color.ID" = color_id, "Color.Name" = color_name, "HEX" = hex_value, "delta" = delta)
  print(output)
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
  #print(unique(extracted_colors))
  return(unique(extracted_colors))
}