merge_colors <- function(img, color.list) {
  parsed_expression <- eval(parse(text = paste0("list(", color.list, ")")))
  merged <- recolorize::mergeLayers(recolorize_obj = img, merge_list = parsed_expression)
  return(merged)
}
