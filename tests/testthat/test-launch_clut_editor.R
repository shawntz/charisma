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
  # Mock browseURL to avoid opening browser
  local_mocked_bindings(
    browseURL = function(url) invisible(NULL),
    .package = "utils"
  )
  
  # Test non-HTTP URL - should warn but not error
  expect_warning(
    suppressMessages(launch_clut_editor(url = "not-a-url")),
    "URL does not appear to be a valid HTTP\\(S\\) URL"
  )
})

test_that("launch_clut_editor uses default URL", {
  # Track which URL was passed to browseURL
  url_passed <- NULL
  local_mocked_bindings(
    browseURL = function(url) {
      url_passed <<- url
      invisible(NULL)
    },
    .package = "utils"
  )
  
  # Test that default URL is set correctly
  expect_message(
    launch_clut_editor(),
    "Opening CLUT Editor in your default browser"
  )
  
  # Verify the correct URL was passed to browseURL
  expect_equal(url_passed, "https://charisma-clut-editor.vercel.app")
})

test_that("launch_clut_editor accepts custom URL", {
  # Track which URL was passed to browseURL
  url_passed <- NULL
  local_mocked_bindings(
    browseURL = function(url) {
      url_passed <<- url
      invisible(NULL)
    },
    .package = "utils"
  )
  
  # Test with custom URL
  custom_url <- "https://custom-clut-editor.example.com"
  
  expect_message(
    launch_clut_editor(url = custom_url),
    custom_url
  )
  
  # Verify the correct URL was passed to browseURL
  expect_equal(url_passed, custom_url)
})

test_that("launch_clut_editor returns TRUE on success", {
  # Mock successful browseURL
  local_mocked_bindings(
    browseURL = function(url) invisible(NULL),
    .package = "utils"
  )
  
  result <- suppressMessages(launch_clut_editor())
  expect_true(result)
})

test_that("launch_clut_editor handles browseURL errors gracefully", {
  # Mock browseURL to throw an error
  local_mocked_bindings(
    browseURL = function(url) stop("Browser not available"),
    .package = "utils"
  )
  
  # Should warn but not error
  expect_warning(
    result <- suppressMessages(launch_clut_editor()),
    "Failed to open browser"
  )
  
  # Should return FALSE on failure
  expect_false(result)
  
  # Should provide helpful message with URL
  expect_message(
    suppressWarnings(launch_clut_editor()),
    "Please manually open this URL in your browser"
  )
})
