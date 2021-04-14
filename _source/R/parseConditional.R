parseConditional <- function(parsed_mapping, destination = c("pipeline", "getter", "python"), round = F) {
  
  ##check if valid destination
  ###`pipeline`: parses output to be used in the `callColors.R` pipeline function
  ###`getter`: parses output to be used in the `getColor.R` singular function
  ###`python`: parses output to be used in the Python color detector application
  destination <- match.arg(destination)
  
  num_ranges <- length(parsed_mapping$h) #(assumes equal lengths for each color variable: h, s, v)
  separate_cond_strings <- rep(NA, num_ranges)
  
  for(ii in 1:num_ranges) {
    num_ors_h <- length(parsed_mapping$h[[ii]]) - 1
    num_ors_s <- length(parsed_mapping$s[[ii]]) - 1
    num_ors_v <- length(parsed_mapping$v[[ii]]) - 1
    
    h_split <- strsplit(as.character(parsed_mapping$h[[ii]]), "::")
    s_split <- strsplit(as.character(parsed_mapping$s[[ii]]), "::")
    v_split <- strsplit(as.character(parsed_mapping$v[[ii]]), "::")
    
    h_string <- rep(NA, num_ors_h + 1)
    s_string <- rep(NA, num_ors_s + 1)
    v_string <- rep(NA, num_ors_v + 1)
    
    #generate H conditional string
    for(jj in 1:length(h_string)) {
      if(destination == "pipeline")
        if(h_split[[jj]][2] != "360")
          h_string[jj] <- paste0("(img$h >= ", h_split[[jj]][1], if(!round) ".00", " & img$h < ", h_split[[jj]][2], if(!round) ".99", ")")
        else
          h_string[jj] <- paste0("(img$h >= ", h_split[[jj]][1], if(!round) ".00", " & img$h <= ", h_split[[jj]][2], if(!round) ".00", ")")
      else if(destination == "getter")
        if(h_split[[jj]][2] != "360")
          h_string[jj] <- paste0("(h >= ", h_split[[jj]][1], if(!round) ".00", " & h < ", h_split[[jj]][2], if(!round) ".99", ")")
        else
          h_string[jj] <- paste0("(h >= ", h_split[[jj]][1], if(!round) ".00", " & h <= ", h_split[[jj]][2], if(!round) ".00", ")")
      else if(destination == "python")
        if(h_split[[jj]][2] != "360")
          h_string[jj] <- paste0("(df['H'].ge(", h_split[[jj]][1], if(!round) ".00", ") & df['H'].lt(", h_split[[jj]][2], if(!round) ".99", "))")
        else
          h_string[jj] <- paste0("(df['H'].ge(", h_split[[jj]][1], if(!round) ".00", ") & df['H'].le(", h_split[[jj]][2], if(!round) ".00", "))")
    }
    
    #generate S conditional string
    for(jj in 1:length(s_string)) {
      if(destination == "pipeline")
        if(s_split[[jj]][2] != "100")
          s_string[jj] <- paste0("(img$s >= ", s_split[[jj]][1], if(!round) ".00", " & img$s < ", s_split[[jj]][2], if(!round) ".99", ")")
        else
          s_string[jj] <- paste0("(img$s >= ", s_split[[jj]][1], if(!round) ".00", " & img$s <= ", s_split[[jj]][2], if(!round) ".00", ")")
      else if(destination == "getter")
        if(s_split[[jj]][2] != "100")
          s_string[jj] <- paste0("(s >= ", s_split[[jj]][1], if(!round) ".00", " & s < ", s_split[[jj]][2], if(!round) ".99", ")")
        else
          s_string[jj] <- paste0("(s >= ", s_split[[jj]][1], if(!round) ".00", " & s <= ", s_split[[jj]][2], if(!round) ".00", ")")
      else if(destination == "python")
        if(s_split[[jj]][2] != "100")
          s_string[jj] <- paste0("(df['S'].ge(", s_split[[jj]][1], if(!round) ".00", ") & df['S'].lt(", s_split[[jj]][2], if(!round) ".99", "))")
        else
          s_string[jj] <- paste0("(df['S'].ge(", s_split[[jj]][1], if(!round) ".00", ") & df['S'].le(", s_split[[jj]][2], if(!round) ".00", "))")
    }
    
    #generate V conditional string
    for(jj in 1:length(v_string)) {
      if(destination == "pipeline")
        if(v_split[[jj]][2] != "100")
          v_string[jj] <- paste0("(img$v >= ", v_split[[jj]][1], if(!round) ".00", " & img$v < ", v_split[[jj]][2], if(!round) ".99", ")")
        else
          v_string[jj] <- paste0("(img$v >= ", v_split[[jj]][1], if(!round) ".00", " & img$v <= ", v_split[[jj]][2], if(!round) ".00", ")")
      else if(destination == "getter")
        if(v_split[[jj]][2] != "100")
          v_string[jj] <- paste0("(v >= ", v_split[[jj]][1], if(!round) ".00", " & v < ", v_split[[jj]][2], if(!round) ".99", ")")
        else
          v_string[jj] <- paste0("(v >= ", v_split[[jj]][1], if(!round) ".00", " & v <= ", v_split[[jj]][2], if(!round) ".00", ")")
      else if(destination == "python")
        if(v_split[[jj]][2] != "100")
          v_string[jj] <- paste0("(df['V'].ge(", v_split[[jj]][1], if(!round) ".00", ") & df['V'].lt(", v_split[[jj]][2], if(!round) ".99", "))")
        else
          v_string[jj] <- paste0("(df['V'].ge(", v_split[[jj]][1], if(!round) ".00", ") & df['V'].le(", v_split[[jj]][2], if(!round) ".00", "))")
    }
    
    ##collapse strings with 'or' pipe
    h_string <- paste(h_string, collapse = " | ")
    s_string <- paste(s_string, collapse = " | ")
    v_string <- paste(v_string, collapse = " | ")
    
    ##nest each conditional
    separate_cond_strings[ii] <- paste0("((", h_string, ") & (", s_string, ") & (", v_string, "))")
  }
  
  ##collapse all separated conditionals into 1 piped set
  combo_string <- paste(separate_cond_strings, collapse = " | ")
  
  return(combo_string)
  
}
