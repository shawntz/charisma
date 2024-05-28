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
validate_lut <- function(lut = color.lut, simple = T) {
  # get all color names from color look up table (LUT)
  color_names <- get_lut_colors(lut)

  # create empty list to hold color calls in
  calls <- list()

  # generate HSV color space
  if (simple) {
    h <- rep(0:360)
    s <- rep(0:100)
    v <- rep(0:100)
  } else {
    # this will take a long time to run, best to run on a cluster
    h <- seq(0, 360, length.out = (361*2))
    s <- seq(0, 100, length.out = (101*2))
    v <- s
  }

  img <- data.frame(expand.grid(h, s, v))
  colnames(img) <- c("h", "s", "v")

  eval_colors <- function(conditional, row) {
    h <- row[1]
    s <- row[2]
    v <- row[3]
    ifelse(eval(parse(text = conditional)), 1, 0)
  }

  check_colors <- function(color) {
    parsed_lut <- parse_lut(color, lut)
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
  n_cores <- parallel::detectCores() - 1
  message(paste("Parallelizing color LUT validation with",
                n_cores, "cores for", dim(img)[1],
                "HSV color coordinates..."))
  Sys.sleep(1)
  message("This may take a while, feel free to go grab a latte!")
  cl <- parallel::makeCluster(n_cores)
  res <- parallel::parLapply(cl, color_names, check_colors)
  names(res) <- color_names
  res_df <- as.data.frame(res)
  parallel::stopCluster(cl)
  end_time <- Sys.time()

  elapsed_time <- format_timer((end_time - start_time))
  message(paste("Total elapsed time for parallelization:",
                elapsed_time, "\n"))

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
  invalid <- calls[calls$total != 1,]

  err_msg <- paste("Error: missing color classifications for",
                   nrow(invalid),
                   "HSV color coordinates ==> Color LUT validation failed ⛔️",
                   "See returned output for the HSV coordinates that failed.")

  passed_msg <- paste("All HSV color coordinates classified!",
                      "==> Color LUT validation passed ✅")

  if (nrow(invalid) > 0) {
    message(strwrap(err_msg,
                    width = 0.95 * getOption("width"),
                    prefix = "\n"))
    return(invalid)
  } else {
    message(strwrap(passed_msg,
                    width = 0.95 * getOption("width"),
                    prefix = "\n"))
    return(0)
  }
}
