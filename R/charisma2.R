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
charisma2 <- function(charisma.obj, interactive = T, new.threshold = NULL,
                      which.state = c("none", "merge", "replace"),
                      state.index = NULL) {
  which.state <- tolower(which.state)
  which.state <- match.arg(which.state)

  if (!inherits(charisma.obj, "charisma")) {
    stop(paste0("Input object is of class `",
                class(charisma.obj),
                "` but should be a `charisma` object!"))
  }

  message(charisma.obj$path)

  n_merge_states <- length(charisma.obj$merge_states)
  n_replacement_states <- length(charisma.obj$replacement_states)

  if (interactive & n_merge_states > 0) {
    message(paste("Warning Message:\n",
                  "Cannot interactively adjust merge states since there are",
                  "replacement states which depend on the modified indicies",
                  "post-merge.",
                  "Only edits to the replacement state will be allowed."))
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
      stop(paste0(which.state,
                  " state.index exceeds possible number of ",
                  which.state, err_str, " states (", comp_len, ")!"))
    }

    if (which.state == "replace") {
      if (!is.null(charisma.obj$replacement_states)) {
        new.charisma <- charisma.obj$replacement_states[[state.index]]
        new.charisma$replacement_history <-
          charisma.obj$replacement_history[1:state.index,]
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
    } else {
      new.charisma <- charisma.obj$merge_states[[n_merge_states]]
    }
  }

  new.charisma$path <- charisma.obj$path

  if (is.null(new.threshold)) {
    thresh <- charisma.obj$prop_threshold
  } else {
    thresh <- new.threshold
  }

  reverted_img <- charisma(new.charisma,
                           interactive = interactive,
                           threshold = thresh,
                           bins = charisma.obj$bins,
                           cutoff = charisma.obj$cutoff,
                           plot = FALSE,
                           pavo = charisma.obj$pavo,
                           logdir = charisma.obj$logdir,
                           auto.drop = charisma.obj$auto_drop,
                           lut = charisma.obj$LUT,
                           stack_colors = charisma.obj$stack_colors)

  return(reverted_img)
}
