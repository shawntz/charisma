#' Validate Color Look-Up Table completeness
#'
#' This function validates that a Color Look-Up Table (CLUT) provides complete
#' and non-overlapping coverage of the HSV color space by testing every HSV
#' coordinate against the CLUT definitions. Validation ensures each color maps
#' to exactly one color class.
#'
#' @param clut Data frame containing the Color Look-Up Table with HSV boundaries
#'   for each color class. Default is \code{charisma::clut}.
#' @param simple Logical. If \code{TRUE} (default), tests a reduced HSV space
#'   with 1-degree increments (361 x 101 x 101 = 3,682,561 coordinates). If
#'   \code{FALSE}, uses finer 0.5-degree increments, which is more thorough but
#'   significantly slower and best suited for cluster computing.
#'
#' @return If validation passes, returns 0 and prints a success message. If
#'   validation fails, returns a data frame containing all HSV coordinates that
#'   either: (1) were not classified to any color, or (2) were classified to
#'   multiple colors (indicating overlap).
#'
#' @details
#' The validation process:
#' \enumerate{
#'   \item Generates a complete grid of HSV color space coordinates
#'   \item Uses parallel processing (all available cores - 1) to classify each
#'     coordinate using the CLUT definitions
#'   \item Checks that each coordinate maps to exactly one color class
#'   \item Reports any missing or duplicate classifications
#' }
#'
#' Validation is essential when modifying the CLUT or creating custom CLUTs for
#' different image datasets. The process can take several minutes even with
#' \code{simple = TRUE}.
#'
#' @references
#' Schwartz, S.T., Tsai, W.L.E., Karan, E.A., Juhn, M.S., Shultz, A.J.,
#' McCormack, J.E., Smith, T.B., and Alfaro, M.E. (2025). charisma: An R package
#' to perform reproducible color characterization of digital images for
#' biological studies. (In Review).
#'
#' @seealso
#' \code{\link{charisma}} for using validated CLUTs,
#' \code{\link{color2label}} for color classification
#'
#' @examples
#' \dontrun{
#' # Validate the default CLUT (takes several minutes with parallel processing)
#'
#' # Note: These examples are not run during R CMD check due to CRAN build
#' # limitations. With only 2 cores available during CRAN checks, validation
#' # can exceed 20 minutes.
#'
#' result <- validate()
#'
#' # Validate a custom CLUT
#' my_clut <- charisma::clut  # Start with default
#' # ... modify my_clut ...
#' result <- validate(clut = my_clut)
#'
#' # More thorough validation (much slower, recommended for cluster computing)
#' result <- validate(simple = FALSE)
#' }
#'
#' @export
validate <- function(clut = charisma::clut, simple = TRUE) {
  # get all color names from color look up table (CLUT)
  color_names <- get_lut_colors(clut)

  # create empty list to hold color calls in
  calls <- list()

  # generate HSV color space
  if (simple) {
    h <- rep(0:360)
    s <- rep(0:100)
    v <- rep(0:100)
  } else {
    # this will take a long time to run, best to run on a cluster
    h <- seq(0, 360, length.out = (361 * 2))
    s <- seq(0, 100, length.out = (101 * 2))
    v <- s
  }

  img <- data.frame(expand.grid(h, s, v))
  colnames(img) <- c("h", "s", "v")

  # Calculate total number of coordinates
  n_coords <- nrow(img)
  simple_text <- if (simple) " (simple = TRUE)" else " (simple = FALSE)"
  message(paste0(
    "\n",
    "Validating entire HSV color space with ",
    format(n_coords, big.mark = ","),
    " coordinates",
    simple_text,
    "...\n",
    "This will take a while to run - please wait.\n"
  ))

  eval_colors <- function(conditional, row) {
    h <- row[1]
    s <- row[2]
    v <- row[3]
    ifelse(eval(parse(text = conditional)), 1, 0)
  }

  check_colors <- function(color) {
    parsed_lut <- parse_lut(color, clut)
    conditional <- construct_conditional(parsed_lut, destination = "getter")
    apply(img, 1, function(row) eval_colors(conditional, row))
  }

  format_timer <- function(elapsed_time) {
    elapsed_secs <- as.numeric(elapsed_time, units = "secs")

    # secs
    if (elapsed_secs < 60) {
      return(paste(round(elapsed_secs, 2), "seconds"))
    }

    # mins
    elapsed_mins <- elapsed_secs / 60
    if (elapsed_mins < 60) {
      return(paste(round(elapsed_mins, 2), "minutes"))
    }

    # hours
    elapsed_hours <- elapsed_mins / 60
    return(paste(round(elapsed_hours, 2), "hours"))
  }

  start_time <- Sys.time()
  # Respect R CMD check limits (max 2 cores)
  # Check for R_CHECK_NCPUS environment variable first
  check_ncpus <- Sys.getenv("R_CHECK_NCPUS", "")
  if (check_ncpus != "") {
    n_cores <- as.integer(check_ncpus)
  } else {
    # Default: use detectCores() - 1, but cap at 2 during R CMD check
    n_cores <- min(parallel::detectCores() - 1, 2L)
  }
  n_cores <- max(1L, n_cores) # Ensure at least 1 core
  message(paste(
    "Parallelizing CLUT validation with",
    n_cores,
    "cores for",
    dim(img)[1],
    "HSV color coordinates..."
  ))
  Sys.sleep(1)
  message("This may take a while, feel free to go grab a latte!")
  cl <- parallel::makeCluster(n_cores)
  res <- parallel::parLapply(cl, color_names, check_colors)
  names(res) <- color_names
  res_df <- as.data.frame(res)
  parallel::stopCluster(cl)
  end_time <- Sys.time()

  elapsed_time <- format_timer((end_time - start_time))
  message(paste("Total elapsed time for parallelization:", elapsed_time, "\n"))

  # sum counts per pixel and add column
  h <- img$h
  s <- img$s
  v <- img$v

  calls <- res_df %>%
    dplyr::mutate(total = rowSums(.)) %>%
    tibble::add_column(h, .before = as.character(color_names[1])) %>%
    tibble::add_column(s, .after = "h") %>%
    tibble::add_column(v, .after = "s")

  # extract missing or duplicate pixels in HSV space
  invalid <- calls[calls$total != 1, ]

  err_msg <- paste(
    "Error: missing color classifications for",
    nrow(invalid),
    "HSV color coordinates ==> CLUT validation failed",
    "See returned output for the HSV coordinates that failed."
  )

  passed_msg <- paste(
    "All HSV color coordinates classified!",
    "==> CLUT validation passed"
  )

  if (nrow(invalid) > 0) {
    message(strwrap(err_msg, width = 0.95 * getOption("width"), prefix = "\n"))
    return(invalid)
  } else {
    message(strwrap(
      passed_msg,
      width = 0.95 * getOption("width"),
      prefix = "\n"
    ))
    return(0)
  }
}
