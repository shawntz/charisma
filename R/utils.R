merge_colors <- function(img, color.list) {
  if (!is.null(color.list)) {
    parsed_expression <- eval(parse(text = paste0("list(", color.list, ")")))
  } else {
    parsed_expression <- NULL
  }

  merged <- recolorize::mergeLayers(recolorize_obj = img,
                                    merge_list = parsed_expression,
                                    plotting = TRUE)
  out.list <- list()
  out.list$img <- merged
  return(out.list)
}


interactive_merge_session <- function(rc, is.charisma2 = FALSE) {
  plot(rc)

  show_init_message <- FALSE
  undo_prev_merge <- FALSE

  replacement_objs_history <- rc$replacement_states
  replacement_from_ids_history <- rc$replacement_history$from
  replacement_to_ids_history <- rc$replacement_history$to

  if (is.null(rc$merge_states)) {
    merge_objs_history <- list()
    merge_pairs_history <- c(NULL)
    current_merge_index <- 1

    # for undoing: first entry == original
    merge_objs_history[[current_merge_index]] <- rc
  } else {
    message(paste0("\nPrevious merge found: ", rc$merge_history))
    show_init_message <- TRUE
    merge_objs_history <- rc$merge_states
    merge_pairs_history <- rc$merge_history
    current_merge_index <- length(rc$merge_states)
  }

  if (is.charisma2) {
    show_init_message <- TRUE
  }

  continue_merging <- TRUE
  merge_input_str <- " * Enter each color pair to merge as follows [e.g., c(2,3), c(4,7), c(9,10)] or 'None': "

  if (!show_init_message) {
    merge_input <- readline(
      "Merge any colors? [Yes/No] "
    )
    mg_inpt <- tolower(merge_input)
  } else {
    message("Skipping merge...")
    undo_prev_merge <- TRUE
    continue_merging <- FALSE
  }

  if (!undo_prev_merge) {
    if (mg_inpt == "y" || mg_inpt == "yes") {
      colors_to_merge <- readline(merge_input_str)

      if (tolower(colors_to_merge) == 'none' || tolower(colors_to_merge) == 'n') {
        continue_merging <- FALSE
        new_img <- merge_colors(rc, color.list = NULL)
        merge_objs_history[[current_merge_index]] <- new_img$img
        rc <- merge_objs_history[[current_merge_index]]
      } else {
        new_img <- merge_colors(rc, colors_to_merge)
        current_merge_index <- current_merge_index + 1
        merge_objs_history[[current_merge_index]] <- new_img$img

        merge_pairs_history <- append(merge_pairs_history,
                                      colors_to_merge)

        rc <- merge_objs_history[[current_merge_index]]
      }
    }
  }

  while (continue_merging) {
    if (length(merge_objs_history) > 1) {
      merge_input <- readline(
        "Undo merge? [Yes/No] "
      )
    }

    mg_inpt <- tolower(merge_input)

    if (mg_inpt == "y" || mg_inpt == "yes") {
      plot(merge_objs_history[[1]])

      merge_objs_history <- merge_objs_history[
        -length(merge_objs_history)
      ]

      merge_pairs_history <- merge_pairs_history[
        -length(merge_pairs_history)
      ]

      current_merge_index <- current_merge_index - 1
      rc <- merge_objs_history[[current_merge_index]]

      colors_to_merge <- readline(merge_input_str)

      if (tolower(colors_to_merge) == 'none' || tolower(colors_to_merge) == 'n') {
        continue_merging <- FALSE
      } else {
        new_img <- merge_colors(rc, colors_to_merge)

        current_merge_index <- current_merge_index + 1
        merge_objs_history[[current_merge_index]] <- new_img$img

        merge_pairs_history <- append(merge_pairs_history,
                                      colors_to_merge)
      }
    } else {
      continue_merging <- FALSE
    }

    rc <- merge_objs_history[[current_merge_index]]
  }

  if (length(merge_pairs_history) == 0) {
    merge_pairs_history <- NULL
    merge_objs_history <- NULL
  }

  out.list <- list(
    final_img = rc,
    merge_history = merge_pairs_history,
    merge_states = merge_objs_history,
    replacement_from_history = replacement_from_ids_history,
    replacement_to_history = replacement_to_ids_history,
    replacement_states = replacement_objs_history
  )

  return(out.list)
}


replace_color <- function(img, color_from, color_to) {
  if (!is.null(color_from) & !is.null(color_to)) {
    img$pixel_assignments[
      which(img$pixel_assignments == as.numeric(color_from))
    ] <- as.numeric(color_to)

    img$centers[as.numeric(color_from), ] <- img$centers[as.numeric(color_to), ]
  }

  out.list <- list()
  out.list$img <- img
  return(out.list)
}


interactive_replacement_session <- function(rc) {
  show_init_message <- FALSE

  if (is.null(rc$replacement_states)) {
    replacement_objs_history <- list()
    replacement_from_ids_history <- c(NULL)
    replacement_to_ids_history <- c(NULL)
    current_replacement_index <- 1

    # for undoing: first entry == original
    replacement_objs_history[[current_replacement_index]] <- rc$final_img
  } else {
    show_init_message <- TRUE
    replacement_objs_history <- rc$replacement_states
    replacement_from_ids_history <- rc$replacement_from_history
    replacement_to_ids_history <- rc$replacement_to_history
    current_replacement_index <- length(rc$replacement_states)
  }

  rc <- rc$final_img
  continue_replacing <- TRUE
  undo_step_one <- FALSE

  if (!show_init_message) {
    replacement_input <- readline(
      "Replace any colors? [Yes/No/Undo] "
    )
  } else {
    message(paste0("\n", length(replacement_objs_history) - 1, " previous replacement(s) found (from the provided starting `state.index`)."))
    print(data.frame(list(from = replacement_from_ids_history,
                          to = replacement_to_ids_history)) %>% tidyr::drop_na())
    undo_step_one <- TRUE
    message(" ")
  }

  while (continue_replacing) {
    if (length(replacement_objs_history) > 1 || undo_step_one) {
      replacement_input <- readline(
        "Replace any additional colors? [Yes/No/Undo] "
      )
    }

    rp_inpt <- tolower(replacement_input)

    if (rp_inpt == "y" || rp_inpt == "yes") {
      color_to_replace <- readline(" * ID of the color to replace: ")
      replacement_color <- readline(paste(" * ID of the color to replace",
                                          color_to_replace,
                                          "with: "))

      new_img <- replace_color(rc, color_to_replace, replacement_color)

      current_replacement_index <- current_replacement_index + 1

      replacement_objs_history[[current_replacement_index]] <- new_img$img

      replacement_from_ids_history <- append(replacement_from_ids_history,
                                             color_to_replace)

      replacement_to_ids_history <- append(replacement_to_ids_history,
                                           replacement_color)

      rc <- replacement_objs_history[[current_replacement_index]]
      saveRDS(rc, "INTERMEDIATE_RC.rds")
      plot(rc)
    } else if (rp_inpt == "u" || rp_inpt == "undo") {
      undo_step_one <- TRUE

        replacement_objs_history <- replacement_objs_history[
          -length(replacement_objs_history)
        ]

        replacement_from_ids_history <- replacement_from_ids_history[
          -length(replacement_from_ids_history)
        ]

        replacement_to_ids_history <- replacement_to_ids_history[
          -length(replacement_to_ids_history)
        ]

        current_replacement_index <- current_replacement_index - 1

        if (current_replacement_index < 1) {
          stop("nothing to undo!")
        }

        rc <- replacement_objs_history[[length(replacement_objs_history)]]
        plot(rc)
    } else {
      continue_replacing <- FALSE
      new_img <- replace_color(rc, color_from = NULL, color_to = NULL)
      replacement_objs_history[[current_replacement_index]] <- new_img$img
      rc <- replacement_objs_history[[current_replacement_index]]
    }
  }

  if (length(replacement_from_ids_history) > 0) {
    replacement_history_df <- data.frame(list(from = replacement_from_ids_history,
                                              to = replacement_to_ids_history))

  } else {
    replacement_history_df <- NULL
    replacement_objs_history <- NULL
  }

  out.list <- list(
    final_img = rc,
    replacement_history = replacement_history_df,
    replacement_states = replacement_objs_history
  )

  return(out.list)
}


interactive_session <- function(rc, is.charisma2 = FALSE) {
  merge.out <- interactive_merge_session(rc, is.charisma2)
  replacement.out <- interactive_replacement_session(merge.out)

  out.list <- list(
    final_img = replacement.out$final_img,
    replacement_history = replacement.out$replacement_history,
    replacement_states = replacement.out$replacement_states,
    merge_history = merge.out$merge_history,
    merge_states = merge.out$merge_states
  )

  return(out.list)
}
