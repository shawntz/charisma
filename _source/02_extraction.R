extractColorClasses <- function(hist, mode = "lower", thresh = .05, method = "GE")
{
  #modes => 
    #"lower": looks for any color class bins that surpass the lower bound threshold (e.g., beyond 5%)
    #"upper": takes all color classes that cumulatively explain at least the upper bound threshold (e.g., up to 95%)
  #methods => "GE": "greater than or equal to", "G": "greather than only"

  if(mode == "lower")
  {
    extracted_colors <- lowerThreshMode(hist = hist, thresh = thresh, method = method)
  }
  else if(mode == "upper")
  {
    extracted_colors <- upperCumulativeDiversityMode(hist = hist, thresh = thresh)
  }
  else
  {
    stop("Invalid mode value: Mode must be set to either 'lower' or 'upper'.")
  }

  return(extracted_colors)
}

lowerThreshMode <- function(hist, thresh = .05, method = "GE")
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

upperCumulativeDiversityMode <- function(hist, thresh = .95)
{
  col_classes <- data.frame(r=numeric(), g=numeric(), b=numeric(), Pct=numeric())

  hist_sorted <- hist %>%
    arrange(desc(Pct))

  cum_sum <- 0
  counter <- 1

  while(cum_sum <= thresh)
  {
    cum_sum <- cum_sum + hist_sorted$Pct[counter]
    col_classes <- hist_sorted[counter,] %>%
      rbind(col_classes)
    counter <- counter + 1
  }
  return(col_classes)
}

getNumColorClasses <- function(extracted_colors)
{
  return(nrow(extracted_colors))
}