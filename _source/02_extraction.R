extractColorClasses <- function(hist, thresh = .05, method = "GE")
  #methods => "GE": "greater than or equal to", "G": "greather than only"
{
  col_classes <- data.frame(r=numeric(), g=numeric(), b=numeric(), Pct=numeric())
  for(bin in nrow(hist):1)
  {
    if(method == "GE")
    {
      if(hist$Pct[bin] >= thresh)
      {
        col_classes <- hist[bin,] %>%
          rbind(col_classes)
      }
    }
    else if(method == "G")
    {
      if(hist$Pct[bin] > thresh)
      {
        col_classes <- hist[bin,] %>%
          rbind(col_classes)
      }
    }
  }
  return(col_classes)
}

getNumColorClasses <- function(extracted_colors)
{
  return(nrow(extracted_colors))
}