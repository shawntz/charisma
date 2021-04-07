parseConditional <- function(parsed_mapping, python = F) {
  
  num_ranges <- length(parsed_mapping$h) #(assumes equal lengths for each color variable: h, s, v)
  separate_cond_strings <- rep(NA, num_ranges)
  
  for(ii in 1:num_ranges) {
    num_ors_h <- length(parsed_mapping$h[[ii]]) - 1
    num_ors_s <- length(parsed_mapping$s[[ii]]) - 1
    num_ors_v <- length(parsed_mapping$v[[ii]]) - 1
    
    h_split <- strsplit(parsed_mapping$h[[ii]], "::")
    s_split <- strsplit(parsed_mapping$s[[ii]], "::")
    v_split <- strsplit(parsed_mapping$v[[ii]], "::")
    
    h_string <- rep(NA, num_ors_h + 1)
    s_string <- rep(NA, num_ors_s + 1)
    v_string <- rep(NA, num_ors_v + 1)
    
    #generate h conditional string
    for(jj in 1:length(h_string)) {
      #h_string[jj] <- paste0("(h >= ", h_split[[jj]][1], " & h <= ", h_split[[jj]][2], ")")
      h_string[jj] <- paste0("(img$h >= ", h_split[[jj]][1], " & img$h <= ", h_split[[jj]][2], ")")
      #h_string[jj] <- paste0("(df['H'] >= ", h_split[[jj]][1], " & df['H'] <= ", h_split[[jj]][2], ")")
      #h_string[jj] <- paste0("(df['H'].ge(", h_split[[jj]][1], ") & df['H'].le(", h_split[[jj]][2], "))")
    }
    
    #generate s conditional string
    for(jj in 1:length(s_string)) {
      #s_string[jj] <- paste0("(s >= ", s_split[[jj]][1], " & s <= ", s_split[[jj]][2], ")")
      s_string[jj] <- paste0("(img$s >= ", s_split[[jj]][1], " & img$s <= ", s_split[[jj]][2], ")")
      #s_string[jj] <- paste0("(df['S'] >= ", s_split[[jj]][1], " & df['S'] <= ", s_split[[jj]][2], ")")
      #s_string[jj] <- paste0("(df['S'].ge(", s_split[[jj]][1], ") & df['S'].le(", s_split[[jj]][2], "))")
    }
    
    #generate v conditional string
    for(jj in 1:length(v_string)) {
      #v_string[jj] <- paste0("(v >= ", v_split[[jj]][1], " & v <= ", v_split[[jj]][2], ")")
      v_string[jj] <- paste0("(img$v >= ", v_split[[jj]][1], " & img$v <= ", v_split[[jj]][2], ")")
      #v_string[jj] <- paste0("(df['V'] >= ", v_split[[jj]][1], " & df['V'] <= ", v_split[[jj]][2], ")")
      #v_string[jj] <- paste0("(df['V'].ge(", v_split[[jj]][1], ") & df['V'].le(", v_split[[jj]][2], "))")
    }
    
    ##collapse strings with 'or' pipe
    h_string <- paste(h_string, collapse = " | ")
    s_string <- paste(s_string, collapse = " | ")
    v_string <- paste(v_string, collapse = " | ")
    
    separate_cond_strings[ii] <- paste0("((", h_string, ") & (", s_string, ") & (", v_string, "))")
  }
  
  ##collapse all separated conditionals into 1 piped set
  ##TODO: output each test conditional case on a separate line for testing
  ##TODO: generate new outputs with sprite plots and hists (output as single image)
  ##TODO: get unit testing done as soon as possible (loop through all hsv space)
  combo_string <- paste(separate_cond_strings, collapse = " | ")
  
  return(combo_string)
  
}
