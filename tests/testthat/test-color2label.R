test_that("color2label correctly classifies RGB colors", {
  # Test basic color classifications
  expect_equal(color2label(c(0, 0, 0)), "black")
  expect_equal(color2label(c(255, 255, 255)), "white")
  expect_equal(color2label(c(255, 0, 0)), "red")
  expect_equal(color2label(c(0, 255, 0)), "green")
  expect_equal(color2label(c(0, 0, 255)), "blue")
  expect_equal(color2label(c(255, 255, 0)), "yellow")
  expect_equal(color2label(c(255, 140, 0)), "orange")
})

test_that("color2label handles NA values", {
  expect_equal(color2label(c(NA, 0, 0)), "NA")
  expect_equal(color2label(c(0, NA, 0)), "NA")
  expect_equal(color2label(c(0, 0, NA)), "NA")
})

test_that("color2label works with custom CLUT", {
  # This should work with the default CLUT
  expect_type(color2label(c(128, 128, 128)), "character")
  expect_true(color2label(c(128, 128, 128)) %in% get_lut_colors())
})
