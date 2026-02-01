#' Launch the CLUT Editor
#'
#' Opens the interactive Color Lookup Table (CLUT) Editor in your web browser.
#' The CLUT Editor allows you to visually design and customize HSV color space
#' partitions for color classification, with 3D visualizations and coverage
#' statistics.
#'
#' @param online Logical. If \code{TRUE} (default), opens the hosted version at
#'   \url{https://charisma.shawnschwartz.com/app}. If \code{FALSE}, opens the
#'   local version bundled with the package.
#'
#' @return Invisibly returns the URL that was opened. Called primarily for its
#'   side effect of opening the CLUT Editor in the default web browser.
#'
#' @details
#' The CLUT Editor provides:
#' \itemize{
#'   \item Visual editing of HSV color space boundaries for each color category
#'   \item Real-time coverage statistics showing gaps and overlaps
#'   \item Multiple visualization modes: hue slices, 3D cone, 3D scatter, hue wheel
#'   \item Export to R code or JSON for use with \code{charisma()}
#'   \item Import/export functionality for sharing custom CLUTs
#' }
#'
#' Custom CLUTs created with the editor can be validated using \code{validate()}
#' and then used in \code{charisma()} analyses via the \code{clut} parameter.
#'
#' @seealso
#' \code{\link{validate}} for validating custom CLUTs,
#' \code{\link{charisma}} for using custom CLUTs in analyses,
#' \code{\link{clut}} for the default Color Look-Up Table
#'
#' @examples
#' \dontrun{
#' # Open the online CLUT Editor (recommended)
#' launch_clut_editor()
#'
#' # Open the local version bundled with the package
#' launch_clut_editor(online = FALSE)
#' }
#'
#' @export
launch_clut_editor <- function(online = TRUE) {
  if (online) {
    url <- "https://charisma.shawnschwartz.com/app"
  } else {
    app_path <- system.file("app", "index.html", package = "charisma")
    if (app_path == "") {
      stop(
        "CLUT Editor not found. ",
        "Try reinstalling the package or use online = TRUE.",
        call. = FALSE
      )
    }
    url <- paste0("file://", normalizePath(app_path))
  }

  message("Opening CLUT Editor in your default browser...")
  utils::browseURL(url)
  invisible(url)
}
