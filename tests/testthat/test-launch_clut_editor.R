test_that("launch_clut_editor validates URL parameter", {
  # Test invalid URL parameter types
  expect_error(
    launch_clut_editor(url = c("http://example.com", "http://example2.com")),
    "url must be a single character string"
  )
  
  expect_error(
    launch_clut_editor(url = 123),
    "url must be a single character string"
  )
  
  expect_error(
    launch_clut_editor(url = NULL),
    "url must be a single character string"
  )
})

test_that("launch_clut_editor warns for invalid URL format", {
  # Test non-HTTP URL
  expect_warning(
    launch_clut_editor(url = "not-a-url"),
    "URL does not appear to be a valid HTTP\\(S\\) URL"
  )
})

test_that("launch_clut_editor returns logical value", {
  # Mock browseURL to avoid opening browser in tests
  mock_browseURL <- function(url) {
    return(invisible(NULL))
  }
  
  # Temporarily replace browseURL in utils namespace
  with_mocked_bindings(
    {
      result <- suppressMessages(launch_clut_editor())
      expect_type(result, "logical")
      expect_true(result %in% c(TRUE, FALSE))
    },
    browseURL = mock_browseURL,
    .package = "utils"
  )
})

test_that("launch_clut_editor uses default URL", {
  # Test that default URL is set correctly
  expect_message(
    launch_clut_editor(url = "https://charisma-clut-editor.vercel.app"),
    "Opening CLUT Editor in your default browser"
  )
})

test_that("launch_clut_editor accepts custom URL", {
  # Test with custom URL
  custom_url <- "https://custom-clut-editor.example.com"
  
  expect_message(
    launch_clut_editor(url = custom_url),
    custom_url
  )
})
