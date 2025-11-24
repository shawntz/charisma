#' Re-analyze and edit saved charisma objects
#'
#' The \code{charisma2} function allows users to step through and edit
#' previously saved \code{charisma} objects. This function enables rewinding
#' to specific merge or replacement states, applying different thresholds, or
#' continuing interactive editing from any saved state, ensuring full
#' reproducibility of the analysis.
#'
#' @param charisma.obj A \code{charisma} object to be re-analyzed. Cannot be a
#'   \code{charisma2} object (attempting to run \code{charisma2} on a
#'   \code{charisma2} object will produce an error).
#' @param interactive Logical. If \code{TRUE}, enters interactive mode for
#'   manual color adjustments. Default is \code{TRUE}.
#' @param new.threshold Numeric value between 0 and 1 to apply a different color
#'   proportion threshold than the original analysis. If \code{NULL}, uses the
#'   original threshold. Default is \code{NULL}.
#' @param which.state Character string specifying which state to revert to.
#'   Options are \code{"none"} (most recent state), \code{"merge"}
#'   (specific merge state), or \code{"replace"} (specific replacement state).
#'   Default is \code{"none"}.
#' @param state.index Integer specifying which state index to revert to when
#'   \code{which.state} is \code{"merge"} or \code{"replace"}. Must be provided
#'   if \code{which.state} is not \code{"none"}. Default is \code{NULL}.
#' @param k.override Integer to force a specific number of color clusters.
#'   Default is \code{NULL}.
#'
#' @return A \code{charisma2} object (also of class \code{charisma}) containing
#'   the same structure as a \code{charisma} object, with updated states based
#'   on the specified reversion point and any new operations performed.
#'
#' @details
#' The \code{charisma2} function provides powerful state management
#' capabilities:
#' \itemize{
#'   \item \strong{State rewinding}: Jump to any previous merge or replacement
#'     state
#'   \item \strong{Re-thresholding}: Apply different color proportion thresholds
#'     without re-running the entire pipeline
#'   \item \strong{Continued editing}: Resume interactive editing from saved
#'     states
#'   \item \strong{Full provenance}: All operations maintain complete history
#'     for reproducibility
#' }
#'
#' Note: Interactive adjustment of merge states is disabled if replacement
#' states exist, as replacement operations depend on post-merge cluster indices.
#'
#' @references
#' Schwartz, S.T., Tsai, W.L.E., Karan, E.A., Juhn, M.S., Shultz, A.J.,
#' McCormack, J.E., Smith, T.B., and Alfaro, M.E. (2025). charisma: An R package
#' to perform reproducible color characterization of digital images for
#' biological studies. (In Review).
#'
#' @seealso
#' \code{\link{charisma}} for initial color classification,
#' \code{\link{plot.charisma}} for visualization
#'
#' @examples
#' \donttest{
#' # Load a previously saved charisma object
#' obj <- readRDS("path/to/charisma_object.RDS")
#'
#' # Apply a different threshold without interactive mode
#' result <- charisma2(obj, interactive = FALSE, new.threshold = 0.10)
#'
#' # Revert to a specific merge state
#' result <- charisma2(obj, which.state = "merge", state.index = 2)
#'
#' # Revert to a specific replacement state
#' result <- charisma2(obj, which.state = "replace", state.index = 1)
#' }
#'
#' # Re-enter interactive mode with original threshold (only runs in interactive sessions)
#' if (interactive()) {
#'   obj <- readRDS("path/to/charisma_object.RDS")
#'   result <- charisma2(obj, interactive = TRUE)
#' }
#'
#' @export
charisma2 <- function(
  charisma.obj,
  interactive = TRUE,
  new.threshold = NULL,
  which.state = c("none", "merge", "replace"),
  state.index = NULL,
  k.override = NULL
) {
  which.state <- tolower(which.state)
  which.state <- match.arg(which.state)

  if (inherits(charisma.obj, "charisma2")) {
    stop(paste0("You cannot re-run `charisma2` on a `charisma2` object!"))
  }

  if (!inherits(charisma.obj, "charisma")) {
    stop(paste0(
      "Input object is of class `",
      class(charisma.obj),
      "` but should be a `charisma` object!"
    ))
  }

  message(charisma.obj$path)

  n_merge_states <- length(charisma.obj$merge_states)
  n_replacement_states <- length(charisma.obj$replacement_states)

  if (interactive && n_merge_states > 0) {
    message(paste(
      "Warning Message:\n",
      "Cannot interactively adjust merge states since there are",
      "replacement states which depend on the modified indicies",
      "post-merge.",
      "Only edits to the replacement state will be allowed."
    ))
  }

  if (which.state != "none") {
    if (is.null(state.index)) {
      stop("`state.index` cannot be null if which.state == `merge`/`replace`!")
    }

    if (which.state == "replace") {
      comp_len <- n_replacement_states
      err_str <- "ment"
    } else if (which.state == "merge") {
      comp_len <- n_merge_states
      err_str <- ""
    }

    if (state.index > comp_len) {
      stop(paste0(
        which.state,
        " state.index exceeds possible number of ",
        which.state,
        err_str,
        " states (",
        comp_len,
        ")!"
      ))
    }

    if (which.state == "replace") {
      if (!is.null(charisma.obj$replacement_states)) {
        new.charisma <- charisma.obj$replacement_states[[state.index]]
        new.charisma$replacement_history <-
          charisma.obj$replacement_history[1:state.index, ]
        new.charisma$replacement_states <-
          charisma.obj$replacement_states[1:state.index]
      } else {
        stop("No replacement history found...")
      }
    } else if (which.state == "merge") {
      if (!is.null(charisma.obj$merge_history)) {
        new.charisma <- charisma.obj$merge_states[[state.index]]
        new.charisma$merge_history <- charisma.obj$merge_history[1:state.index]
        new.charisma$merge_states <- charisma.obj$merge_states[1:state.index]
      } else {
        stop("No merge history found...")
      }
    }
  } else {
    # select the newest possible state
    if (!is.null(charisma.obj$replacement_states)) {
      new.charisma <- charisma.obj$replacement_states[[n_replacement_states]]
    } else if (!is.null(charisma.obj$merge_states)) {
      new.charisma <- charisma.obj$merge_states[[n_merge_states]]
    } else {
      new.charisma <- charisma.obj$path
    }
  }

  if (!is.character(new.charisma)) {
    new.charisma$path <- charisma.obj$path
  }

  if (is.null(new.threshold)) {
    thresh <- charisma.obj$prop_threshold
  } else {
    thresh <- new.threshold
  }

  class(new.charisma) <- c(class(new.charisma), "charisma2")

  reverted_img <- charisma(
    new.charisma,
    interactive = interactive,
    threshold = thresh,
    bins = charisma.obj$bins,
    cutoff = charisma.obj$cutoff,
    plot = FALSE,
    pavo = charisma.obj$pavo,
    logdir = charisma.obj$logdir,
    auto.drop = charisma.obj$auto_drop,
    k.override = k.override,
    clut = charisma.obj$clut,
    stack_colors = charisma.obj$stack_colors
  )

  class(reverted_img) <- c("charisma2", "charisma")

  return(reverted_img)
}
