#' Default Color (Labels) Look Up Table (CLUT)
#'
#' This LUT contains all color boundaries which cut up the continuous HSV
#' color space into 10 discrete color labels (i.e., black, white, grey, brown,
#' red, orange, yellow, green, blue, and purple).
#'
#' @details
#' These color boundaries were determined by forming consensus across three
#' experts in the biology of color. Color boundaries were intentionally tuned
#' to reflect accurate color label classifications for images of various
#' bird and fish museum specimens.
#'
#' Although we attempted to determine color boundaries in an object fashion,
#' there are of course perceptual biases and variability across computer models/
#' displays that can influence whether any given color at the boundary of the
#' continuous color space is ultimately called one color over another.
#'
#' Accordingly, we gladly welcome further optimization of the default color LUT
#' and/or submissions of color LUTS specifically tuned to any given organism or
#' stimulus. Leveraging contributions from the community will only help
#' `charisma` be more useful for everybody who would like to use it!
#'
#' @docType data
#'
#' @usage charisma::clut
#'
#' @format An object of class \code{"data.frame"} to be passed into
#' [charisma::charisma()] functions.
#'
#' @keywords charisma, color look up table, CLUT
"clut"
