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
parseMapping <- function(color.name, mapping = color.map) {

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
