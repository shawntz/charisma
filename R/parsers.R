parse_lut <- function(color.name, lut = color.lut) {
  # check if color.name exists in LUT
  if (!color.name %in% lut[,1])
    stop("Error: specified color name is not defined in color lut.
         Please check definitions in color LUT file.")

  # subset color ranges
  lut <- lut[which(lut$color.name == color.name),]
  h <- lut$h
  s <- lut$s
  v <- lut$v

  # check defined LUT lengths
  h <- strsplit(as.character(h), ",")[[1]]
  s <- strsplit(as.character(s), ",")[[1]]
  v <- strsplit(as.character(v), ",")[[1]]
  col_lens <- c(length(h), length(s), length(v))
  if (length(unique(col_lens)) != 1)
    stop("Error: specified color ranges are not of equal length.
         Please check definitions in color LUT file.")

  # parse: split 'or' pipes
  h <- strsplit(as.character(h), "\\|")
  s <- strsplit(as.character(s), "\\|")
  v <- strsplit(as.character(v), "\\|")

  # format output
  output <- list(h, s, v)
  names(output) <- c("h", "s", "v")

  return(output)
}

construct_conditional <- function(parsed_lut, destination = c("pipeline", "getter", "python")) {
  # check if valid destination
  # `pipeline`: parses output to be used in the `callColors.R` pipeline function
  # `getter`: parses output to be used in the `getColor.R` stand-alone function
  # `python`: parses output to be used in the Python color detector application
  destination <- tolower(destination)
  destination <- match.arg(destination)

  num_ranges <- length(parsed_lut$h) # (assumes equal lengths for each color variable: h, s, v)
  separate_cond_strings <- rep(NA, num_ranges)

  for(ii in 1:num_ranges) {
    num_ors_h <- length(parsed_lut$h[[ii]]) - 1
    num_ors_s <- length(parsed_lut$s[[ii]]) - 1
    num_ors_v <- length(parsed_lut$v[[ii]]) - 1

    h_split <- strsplit(as.character(parsed_lut$h[[ii]]), "::")
    s_split <- strsplit(as.character(parsed_lut$s[[ii]]), "::")
    v_split <- strsplit(as.character(parsed_lut$v[[ii]]), "::")

    h_string <- rep(NA, num_ors_h + 1)
    s_string <- rep(NA, num_ors_s + 1)
    v_string <- rep(NA, num_ors_v + 1)

    # generate H conditional string
    for (jj in 1:length(h_string)) {
      if (destination == "pipeline")
        h_string[jj] <- paste0("(img$h >= ", h_split[[jj]][1], ".0000", " & img$h < ", h_split[[jj]][2], ".9999", ")")
      else if (destination == "getter")
        h_string[jj] <- paste0("(h >= ", h_split[[jj]][1], ".0000", " & h < ", h_split[[jj]][2], ".9999", ")")
      else if (destination == "python")
        h_string[jj] <- paste0("(df['H'].ge(", h_split[[jj]][1], ".0000", ") & df['H'].lt(", h_split[[jj]][2], ".9999", "))")
    }

    # generate S conditional string
    for (jj in 1:length(s_string)) {
      if (destination == "pipeline")
        s_string[jj] <- paste0("(img$s >= ", s_split[[jj]][1], ".0000", " & img$s < ", s_split[[jj]][2], ".9999", ")")
      else if (destination == "getter")
        s_string[jj] <- paste0("(s >= ", s_split[[jj]][1], ".0000", " & s < ", s_split[[jj]][2], ".9999", ")")
      else if (destination == "python")
        s_string[jj] <- paste0("(df['S'].ge(", s_split[[jj]][1], ".0000", ") & df['S'].lt(", s_split[[jj]][2], ".9999", "))")
    }

    # generate V conditional string
    for (jj in 1:length(v_string)) {
      if (destination == "pipeline")
        v_string[jj] <- paste0("(img$v >= ", v_split[[jj]][1], ".0000", " & img$v < ", v_split[[jj]][2], ".9999", ")")
      else if (destination == "getter")
        v_string[jj] <- paste0("(v >= ", v_split[[jj]][1], ".0000", " & v < ", v_split[[jj]][2], ".9999", ")")
      else if (destination == "python")
        v_string[jj] <- paste0("(df['V'].ge(", v_split[[jj]][1], ".0000", ") & df['V'].lt(", v_split[[jj]][2], ".9999", "))")
    }

    # collapse strings with 'or' pipe
    h_string <- paste(h_string, collapse = " | ")
    s_string <- paste(s_string, collapse = " | ")
    v_string <- paste(v_string, collapse = " | ")

    # nest each conditional
    separate_cond_strings[ii] <- paste0("((", h_string, ") & (", s_string, ") & (", v_string, "))")
  }

  # collapse all separated conditionals into 1 piped set
  combo_string <- paste(separate_cond_strings, collapse = " | ")

  return(combo_string)
}
