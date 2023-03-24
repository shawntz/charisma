swap_color <- function(img, color_from, color_to) {
  history.list <- list()

  # PREV_px_assignment <- img$pixel_assignments
  # PREV_centers <- img$centers

  ORIGINAL_IMG <- img

  img$pixel_assignments[which(img$pixel_assignments == as.numeric(color_from))] <- as.numeric(color_to)
  img$centers[as.numeric(color_from), ] <- img$centers[as.numeric(color_to), ]

  # NEW_px_assignment <- img$pixel_assignments
  # NEW_centers <- img$centers

  plot(img)

  history.list$img <- img
  history.list$undo_state <- ORIGINAL_IMG

  # if (!undo) {
  #   # history.list$PREV_px_assignment <- PREV_px_assignment
  #   # history.list$PREV_centers <- PREV_centers
  #   # history.list$NEW_px_assignment <- NEW_px_assignment
  #   # history.list$NEW_centers <- NEW_centers
  #   # history.list$img <- img
  #   history.lis
  # } else {
  #
  # }

  # return(img)
  return(history.list)
}
