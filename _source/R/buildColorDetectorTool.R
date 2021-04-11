buildColorDetectorTool <- function(mapping) {
  
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
  sink(file.path("tools", "color-detector", "parsed_color_functions.txt"))
  cat(paste0("\n\n", "def ", "test_", colors, "(df):", "\n", "\t", "return(", parsed_conditionals, ")", "\n"))
  sink()
  
  ##dynamically build out `colorID(h,s,v)` Python function
  ###choices array
  color_choices_text <- paste(shQuote(colors), collapse=", ")
  color_choices_text <- paste0("choices = [", color_choices_text, "]")
  ###conditions array
  conditions_array_text <- paste0("test_", colors, "(df)", collapse = ", ")
  conditions_array_text <- paste0("conditions = [", conditions_array_text, "]")
  ###entire identify color function
  sink(file.path("tools", "color-detector", "parsed_colorID_function.txt"))
  cat(paste0("\n\n", "##identify color", "\n",
             "def colorID(h,s,v):\n",
             "\t", "color = None", "\n",
             "\t", "d = {'H': [round(h, 2)], 'S': [round(s, 2)], 'V': [round(v, 2)]}", "\n",
             "\t", "df = pd.DataFrame(data=d)", "\n",
             "\t", color_choices_text, "\n",
             "\t", conditions_array_text, "\n",
             "\t", "color = np.select(conditions, choices, default=None)", "\n",
             "\t", "print('the color is {}'.format(color[0]))", "\n",
             "\t", "return(color)", "\n"))
  sink()
  
  ##read in and manipulate boilerplate file
  bp <- readtext::readtext(file.path("tools", "color-detector", "template", "boilerplate.txt"))
  bp <- strsplit(bp$text, "---...---")
  
  ##read in temporary generated feelings
  color_choices <- readtext::readtext(file.path("tools", "color-detector", "parsed_color_functions.txt"))
  color_choices <- color_choices$text
  
  color_id <- readtext::readtext(file.path("tools", "color-detector", "parsed_colorID_function.txt"))
  color_id <- color_id$text
  
  ##generate completed file
  sink(file.path("tools", "color-detector", "color-detector-tool.py"))
  cat(paste0(
    bp[[1]][1],
    color_choices,
    color_id,
    bp[[1]][2]
  ))
  sink()
  
  ##clean up temp directory
  unlink(file.path("tools", "color-detector", "parsed_color_functions.txt"))
  unlink(file.path("tools", "color-detector", "parsed_colorID_function.txt"))
  
}