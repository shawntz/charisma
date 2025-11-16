test_that("get_lut_colors returns all expected colors", {
  colors <- get_lut_colors()

  expect_type(colors, "character")
  expect_length(colors, 10)

  expected_colors <- c(
    "black",
    "blue",
    "brown",
    "green",
    "grey",
    "orange",
    "purple",
    "red",
    "white",
    "yellow"
  )
  expect_setequal(colors, expected_colors)
})

test_that("get_lut_hex returns color names and hex codes", {
  lut_hex <- get_lut_hex()

  expect_s3_class(lut_hex, "data.frame")
  expect_true("color.name" %in% names(lut_hex))
  expect_true("default.hex" %in% names(lut_hex))
})

test_that("summarise_colors creates binary presence/absence data", {
  test_colors <- c("red", "blue", "green")
  result <- summarise_colors(test_colors)

  expect_s3_class(result, "data.frame")
  expect_true("k" %in% names(result))
  expect_equal(result$k, 3)

  # Check that present colors are marked as 1
  expect_equal(result$red, 1)
  expect_equal(result$blue, 1)
  expect_equal(result$green, 1)

  # Check that absent colors are marked as 0
  expect_equal(result$black, 0)
  expect_equal(result$white, 0)
})
