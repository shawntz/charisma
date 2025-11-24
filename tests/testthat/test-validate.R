test_that("validate returns 0 when CLUT validation passes with no issues", {
  # Validate the default CLUT
  # This test may take a few minutes to run
  result <- validate(simple = TRUE)

  # When validation passes with no issues, should return 0 (numeric)
  expect_type(result, "double")
  expect_equal(result, 0)
  expect_false(is.data.frame(result))
})

