#' Launch CLUT Editor Web Application
#'
#' Opens the Color Look-Up Table (CLUT) editor web application in your default
#' browser. The CLUT editor is an interactive tool for creating and customizing
#' color boundaries in HSV color space for specialized color classification needs.
#'
#' @param url Character. URL of the CLUT editor web application. Default is the
#'   official charisma CLUT editor hosted on Vercel.
#'
#' @return Invisibly returns \code{TRUE} if the browser was successfully opened,
#'   \code{FALSE} otherwise.
#'
#' @details
#' The CLUT editor provides a visual interface for:
#' \itemize{
#'   \item Viewing and editing HSV color boundaries for each color category
#'   \item Testing color classifications in real-time
#'   \item Exporting custom CLUT definitions for use with \code{\link{charisma}}
#'   \item Validating CLUT completeness and coverage
#' }
#'
#' While the default CLUT provided by \code{charisma} works well for most
#' biological specimens (birds, fish, etc.), you may need custom color boundaries
#' for specific image datasets. The CLUT editor makes it easy to create and test
#' custom color definitions without writing R code.
#'
#' @seealso
#' \code{\link{charisma}} for using custom CLUTs,
#' \code{\link{validate}} for validating CLUT completeness,
#' \code{\link{clut}} for the default CLUT
#'
#' @examples
#' \dontrun{
#' # Launch the CLUT editor
#' launch_clut_editor()
#'
#' # After creating a custom CLUT in the editor and saving it:
#' my_clut <- read.csv("path/to/exported_clut.csv")
#' validate(clut = my_clut)
#' result <- charisma(img_path, clut = my_clut)
#' }
#'
#' @export
launch_clut_editor <- function(url = "https://charisma-clut-editor.vercel.app") {
  # Validate URL
  if (!is.character(url) || length(url) != 1) {
    stop("url must be a single character string")
  }

  # Check if URL has valid HTTP(S) format (basic validation)
  if (!grepl("^https?://", url)) {
    warning("URL does not appear to be a valid HTTP(S) URL")
  }

  message(paste0(
    "\n",
    "Opening CLUT Editor in your default browser...\n",
    "URL: ", url, "\n",
    "\n",
    "The CLUT editor allows you to:\n",
    "  - Create custom color boundaries for specialized image datasets\n",
    "  - Visualize HSV color space partitions\n",
    "  - Test and validate color classifications\n",
    "  - Export custom CLUTs for use with charisma\n"
  ))

  # Open URL in default browser
  result <- tryCatch(
    {
      utils::browseURL(url)
      TRUE
    },
    error = function(e) {
      warning(paste("Failed to open browser:", e$message))
      message(paste0(
        "\n",
        "Please manually open this URL in your browser:\n",
        url
      ))
      FALSE
    }
  )

  invisible(result)
}
