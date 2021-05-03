buildColorValidationTool <- function(mapping) {
  
  ##load required text parsing libraries
  library(readtext)
  
  ##get all color names from mapping
  colors <- getMappedColors(mapping)
  
  parsed_conditionals <- rep(NA, length(colors))
  for(color in 1:length(colors)) {
    parsed_mapping <- parseMapping(mapping, colors[color])
    parsed_conditionals[color] <- parseConditional(parsed_mapping, "python")
  }
  
  ##save dynamic python color test function text
  sink(file.path("tools", "color-validator", "parsed_color_functions.txt"))
  cat(paste0("\n\n", "def ", "test_", colors, "(df):", "\n", "\t", "return(", parsed_conditionals, ")", "\n"))
  sink()
  
  ##dynamically build out `validate_colors(colors)` Python function
  ##functions array
  color_functions_text <- paste0(colors, " = ", "test_", colors, "(colors)")
  
  ##pandas dataframe dictionary
  pandas_df_dict_text <- paste0(shQuote(colors), ": ", colors)
  
  ##entire validate_colors function
  sink(file.path("tools", "color-validator", "parsed_pandas_df_function.txt"))
  cat(paste0("\n\n", "## Validator", "\n",
             "def validate_colors(colors):\n",
             "\t", paste(color_functions_text, collapse = "\n\t"), "\n",
             "\n\t", "df = pd.DataFrame({", "\n",
             "\t\t", paste(pandas_df_dict_text, collapse = ",\n\t\t"), "\n",
             "\t", "})", "\n",
             "\n\t", "#check number of True per color", "\n",
             "\t", "counts = df[df == True].count(axis = 1)", "\n",
             "\t", "multiples = counts[counts > 1]", "\n",
             "\n\t", "#get indices of duplicate color rows", "\n",
             "\t", "indices = multiples.index", "\n",
             "\n\t", "#get extracted rows of color calls", "\n",
             "\t", "extractions = df.loc[indices]", "\n",
             "\n\t", "#get length of duplicate calls", "\n",
             "\t", "multiples_length = len(indices)", "\n",
             "\n\t", "return(multiples_length, extractions)", "\n"
             ))
  sink()
  
  ##read in and manipulate boilerplate file
  bp <- readtext::readtext(file.path("tools", "color-validator", "template", "boilerplate.txt"))
  bp <- strsplit(bp$text, "---...---")
  
  ##read in temporary generated feelings
  color_choices <- readtext::readtext(file.path("tools", "color-validator", "parsed_color_functions.txt"))
  color_choices <- color_choices$text
  
  color_validator <- readtext::readtext(file.path("tools", "color-validator", "parsed_pandas_df_function.txt"))
  color_validator <- color_validator$text
  
  ##generate completed file
  sink(file.path("tools", "color-validator", "color-validator-tool.py"))
  cat(paste0(
    bp[[1]][1],
    color_choices,
    color_validator,
    bp[[1]][2]
  ))
  sink()
  
  ##clean up temp directory
  unlink(file.path("tools", "color-validator", "parsed_color_functions.txt"))
  unlink(file.path("tools", "color-validator", "parsed_pandas_df_function.txt"))
  
}