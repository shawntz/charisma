test_that("parse_lut extracts color definitions", {
  parsed <- parse_lut("red")

  expect_type(parsed, "list")
  expect_true("h" %in% names(parsed))
  expect_true("s" %in% names(parsed))
  expect_true("v" %in% names(parsed))

  expect_type(parsed$h, "list")
  expect_type(parsed$s, "list")
  expect_type(parsed$v, "list")
})

test_that("parse_lut validates color names", {
  expect_error(parse_lut("invalid_color_name"), "not defined in CLUT")
})

test_that("construct_conditional generates valid conditionals", {
  parsed <- parse_lut("red")

  cond_getter <- construct_conditional(parsed, destination = "getter")
  cond_pipeline <- construct_conditional(parsed, destination = "pipeline")

  expect_type(cond_getter, "character")
  expect_type(cond_pipeline, "character")

  # Should contain HSV variable references
  expect_true(grepl("h", cond_getter, ignore.case = TRUE))
  expect_true(grepl("s", cond_getter, ignore.case = TRUE))
  expect_true(grepl("v", cond_getter, ignore.case = TRUE))
})

test_that("construct_conditional validates destination parameter", {
  parsed <- parse_lut("blue")

  expect_error(
    construct_conditional(parsed, destination = "invalid"),
    "should be one of"
  )
})
