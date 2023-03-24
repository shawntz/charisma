parse_mapping <- function(color.name, mapping = color.map) {
  # check if color.name exists in mapping
  if(!color.name %in% mapping[,1])
    stop("Error: specified color name is not defined in color mapping.
         Please check definitions in color mapping file.")

  # subset color ranges
  mapping <- mapping[which(mapping$color.name == color.name),]
  h <- mapping$h
  s <- mapping$s
  v <- mapping$v

  # check defined mapping lengths
  h <- strsplit(as.character(h), ",")[[1]]
  s <- strsplit(as.character(s), ",")[[1]]
  v <- strsplit(as.character(v), ",")[[1]]
  col_lens <- c(length(h), length(s), length(v))
  if(length(unique(col_lens)) != 1)
    stop("Error: specified color ranges are not of equal length.
         Please check definitions in color mapping file.")

  # parse: split 'or' pipes
  h <- strsplit(as.character(h), "\\|")
  s <- strsplit(as.character(s), "\\|")
  v <- strsplit(as.character(v), "\\|")

  # format output
  output <- list(h, s, v)
  names(output) <- c("h", "s", "v")

  return(output)
}

parse_conditional <- function(parsed_mapping, destination = c("pipeline", "getter", "python")) {
  # check if valid destination
  # `pipeline`: parses output to be used in the `callColors.R` pipeline function
  # `getter`: parses output to be used in the `getColor.R` stand-alone function
  # `python`: parses output to be used in the Python color detector application
  destination <- tolower(destination)
  destination <- match.arg(destination)

  num_ranges <- length(parsed_mapping$h) # (assumes equal lengths for each color variable: h, s, v)
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

    # generate H conditional string
    for(jj in 1:length(h_string)) {
      if(destination == "pipeline")
        h_string[jj] <- paste0("(img$h >= ", h_split[[jj]][1], ".0000", " & img$h < ", h_split[[jj]][2], ".9999", ")")
      else if(destination == "getter")
        h_string[jj] <- paste0("(h >= ", h_split[[jj]][1], ".0000", " & h < ", h_split[[jj]][2], ".9999", ")")
      else if(destination == "python")
        h_string[jj] <- paste0("(df['H'].ge(", h_split[[jj]][1], ".0000", ") & df['H'].lt(", h_split[[jj]][2], ".9999", "))")
    }

    # generate S conditional string
    for(jj in 1:length(s_string)) {
      if(destination == "pipeline")
        s_string[jj] <- paste0("(img$s >= ", s_split[[jj]][1], ".0000", " & img$s < ", s_split[[jj]][2], ".9999", ")")
      else if(destination == "getter")
        s_string[jj] <- paste0("(s >= ", s_split[[jj]][1], ".0000", " & s < ", s_split[[jj]][2], ".9999", ")")
      else if(destination == "python")
        s_string[jj] <- paste0("(df['S'].ge(", s_split[[jj]][1], ".0000", ") & df['S'].lt(", s_split[[jj]][2], ".9999", "))")
    }

    # generate V conditional string
    for(jj in 1:length(v_string)) {
      if(destination == "pipeline")
        v_string[jj] <- paste0("(img$v >= ", v_split[[jj]][1], ".0000", " & img$v < ", v_split[[jj]][2], ".9999", ")")
      else if(destination == "getter")
        v_string[jj] <- paste0("(v >= ", v_split[[jj]][1], ".0000", " & v < ", v_split[[jj]][2], ".9999", ")")
      else if(destination == "python")
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

#' Add together two numbers
#'
#' @param x A number
#' @param y A number
#' @return The sum of \code{x} and \code{y}
#' @examples
#' add(1, 1)
#' add(10, 1)
#'
#' @export
parse_color <- function(color_triplet, hsv = FALSE, verbose = FALSE, mapping = color.map) {
  if(!hsv) {
    # convert color space to hsv
    color_triplet <- as.data.frame(t(rgb2hsv(color_triplet[1], color_triplet[2], color_triplet[3])))
  } else {
    # this is to feed in a single row of h, s, and v values (a la the patch set in long format that whitney sent me)
    color_triplet <- as.data.frame(cbind(h = color_triplet$h[1], s = color_triplet$s[1], v = color_triplet$v[1]))
  }

  #print(color_triplet)

  # check if any NAs in color triplet and return NA if true
  if(is.na(sum(color_triplet[1,])))
    return("NA")
  # if(apply(color_triplet, 0, function(x) is.na(x))) {
  #   return("NA")
  # }

  if(verbose) print(color_triplet)

  # rescale hsv color triplet to match scales used in parsed color mapping
  h <- round(color_triplet[1] * 360, 2)
  s <- round(color_triplet[2] * 100, 2)
  v <- round(color_triplet[3] * 100, 2)

  #print(c(h, s, v))

  # get all color names from color mapping
  color_names <- unique(mapping[,1])

  # evaluate for each color
  calls <- rep(NA, length(color_names))
  names(calls) <- color_names

  for(color in 1:length(color_names)) {
    parsed_mapping <- parse_mapping(color_names[color], mapping)
    parsed_conditional <- parse_conditional(parsed_mapping, destination = "getter")
    calls[color] <- ifelse(eval(parse(text = parsed_conditional)), 1, 0)
  }

  # see which color was matched (should only return 1 match)
  matched_color <- names(calls)[which.max(calls)]

  if(verbose) print(calls)

  if(length(which.max(calls)) > 1)
    warning("More than 1 color matched on color triplet -- overlapping color boundaries.
            Check and update color mapping boundary definitions.")

  return(matched_color)
}
