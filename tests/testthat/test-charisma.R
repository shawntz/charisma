test_that("charisma respects threshold parameter", {
  skip_if_not_installed("recolorize")
  skip_if_not_installed("imager")

  img <- system.file(
    "extdata",
    "Tangara_fastuosa_LACM60421.png",
    package = "charisma"
  )

  skip_if(img == "", "Example image not found")

  result_0 <- charisma(
    img,
    threshold = 0.0,
    interactive = FALSE,
    plot = FALSE,
    pavo = FALSE
  )
  result_10 <- charisma(
    img,
    threshold = 0.10,
    interactive = FALSE,
    plot = FALSE,
    pavo = FALSE
  )

  # Higher threshold should result in fewer or equal colors
  k_0 <- length(unique(result_0$classification))
  k_10 <- length(unique(result_10$classification))

  expect_lte(k_10, k_0)
})

test_that("charisma2 rejects charisma2 objects", {
  skip_if_not_installed("recolorize")
  skip_if_not_installed("imager")

  img <- system.file(
    "extdata",
    "Tangara_fastuosa_LACM60421.png",
    package = "charisma"
  )

  skip_if(img == "", "Example image not found")

  result <- charisma(
    img,
    threshold = 0.05,
    interactive = FALSE,
    plot = FALSE,
    pavo = FALSE
  )

  result2 <- charisma2(result, interactive = FALSE)
  class(result2) <- c("charisma2", "charisma")

  expect_error(charisma2(result2), "cannot re-run")
})

test_that("charisma2 rejects non-charisma objects", {
  not_charisma <- list(a = 1, b = 2)
  expect_error(charisma2(not_charisma), "should be a `charisma` object")
})
