test_that("require_pattern() accepts matching strings and skips NA", {
  v <- restrict("code") |> require_pattern("^[A-Z]{3}$")
  expect_valid(v, c("ABC", "XYZ"))
  expect_valid(v, c("ABC", NA))
  expect_valid(v, NA_character_)
  expect_valid(v, character(0))
})

test_that("require_pattern() reports the first offender and every position", {
  v <- restrict("code") |> require_pattern("^[A-Z]{3}$")
  err <- validation_errors(v, c("ABC", "xy", "q", "DEF"))
  expect_match(err, 'code: must match pattern "^[A-Z]{3}$"', fixed = TRUE)
  expect_match(err, 'Found: "xy"', fixed = TRUE)
  expect_match(err, "At: 2, 3", fixed = TRUE)
})

test_that("require_pattern() omits At: for a scalar", {
  v <- restrict("code") |> require_pattern("^a")
  expect_false(grepl("At:", validation_errors(v, "b")))
})

test_that("require_pattern() supports fixed and ignore_case", {
  fixed_v <- restrict("x") |> require_pattern("a.b", fixed = TRUE)
  expect_valid(fixed_v, "xa.by")
  expect_invalid(fixed_v, "xaXby", regexp = 'must contain "a.b"')

  ci <- restrict("x") |> require_pattern("^abc$", ignore_case = TRUE)
  expect_valid(ci, c("ABC", "abc"))
  expect_invalid(ci, "abd", regexp = "ignoring case")
})

test_that("require_pattern() checks its arguments when built", {
  expect_error(restrict("x") |> require_pattern(c("a", "b")), "single non-NA")
  expect_error(restrict("x") |> require_pattern(NA_character_), "single non-NA")
  expect_error(restrict("x") |> require_pattern("a", fixed = NA), "TRUE or FALSE")
  expect_error(restrict("x") |> require_pattern("a", fixed = TRUE, ignore_case = TRUE),
               "cannot be combined")
  expect_error(restrict("x") |> require_pattern("(unclosed"),
               "not a valid regular expression")
})

test_that("character steps reject non-character input with a type error", {
  for (v in list(restrict("x") |> require_pattern("a"),
                 restrict("x") |> require_nchar(max = 3),
                 restrict("x") |> require_nonempty())) {
    expect_error(v(1:3), "x: must be character, got integer",
                 class = "restrictR_precondition")
  }
})

test_that("character steps skip NA and no_na rejects it", {
  v <- restrict("x") |> require_nonempty() |> require_nchar(max = 2) |>
    require_no_na()
  expect_error(v(c("a", NA)), "must not contain NA")
  w <- restrict("x") |> require_nonempty() |> require_nchar(max = 2)
  expect_valid(w, c("a", NA))
})

test_that("require_nchar() bounds the number of characters", {
  v <- restrict("x") |> require_nchar(min = 2, max = 4)
  expect_valid(v, c("ab", "abcd"))
  err <- validation_errors(v, c("ab", "a", "abcde"))
  expect_match(err, "must have between 2 and 4 characters", fixed = TRUE)
  expect_match(err, 'Found: "a" (1 character)', fixed = TRUE)
  expect_match(err, "At: 2, 3", fixed = TRUE)
})

test_that("require_nchar() labels the one-sided and exact forms", {
  expect_equal(steps(restrict("x") |> require_nchar(min = 3))$label,
               "must have at least 3 characters")
  expect_equal(steps(restrict("x") |> require_nchar(max = 1))$label,
               "must have at most 1 character")
  expect_equal(steps(restrict("x") |> require_nchar(min = 5, max = 5))$label,
               "must have exactly 5 characters")
})

test_that("require_nchar() counts characters, not bytes", {
  v <- restrict("x") |> require_nchar(max = 2)
  expect_valid(v, "éè")
  expect_invalid(v, "éèà")
})

test_that("require_nchar() checks its bounds when built", {
  expect_error(restrict("x") |> require_nchar(min = 3, max = 2), "0 <= min <= max")
  expect_error(restrict("x") |> require_nchar(min = -1), "0 <= min <= max")
  expect_error(restrict("x") |> require_nchar(min = 1.5), "whole numbers")
  expect_error(restrict("x") |> require_nchar(min = "a"), "whole numbers")
})

test_that("require_nonempty() rejects empty and whitespace-only strings", {
  v <- restrict("label") |> require_nonempty()
  expect_valid(v, c("a", " b "))
  err <- validation_errors(v, c("a", "", "  ", "\t", "b"))
  expect_match(err, "label: must not contain blank strings", fixed = TRUE)
  expect_match(err, 'Found: ""', fixed = TRUE)
  expect_match(err, "At: 2, 3, 4", fixed = TRUE)
})
