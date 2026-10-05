test_that("expect_valid() passes for a valid value and returns it", {
  v <- restrict("x") |> require_numeric()
  expect_success(expect_valid(v, 1:3))
  expect_identical(expect_valid(v, 1:3), 1:3)
})

test_that("expect_valid() reports the validator's messages", {
  v <- restrict("newdata") |> require_df() |> require_has_cols("x")
  expect_failure(expect_valid(v, 1:3), "`newdata` is invalid")
  expect_failure(expect_valid(v, data.frame(y = 1)), 'missing required column: "x"')
})

test_that("expect_valid() passes context through", {
  v <- restrict("pred") |> require_length_matches(~ nrow(newdata))
  df <- data.frame(a = 1:2)
  expect_success(expect_valid(v, 1:2, newdata = df))
  expect_failure(expect_valid(v, 1:3, newdata = df), "length must match")
})

test_that("expect_invalid() requires a failure", {
  v <- restrict("x") |> require_numeric()
  expect_success(expect_invalid(v, "a"))
  expect_failure(expect_invalid(v, 1), "accepted the value")
})

test_that("expect_invalid() matches regexp against the messages", {
  v <- restrict("x") |> require_numeric() |> require_positive(strict = TRUE)
  expect_success(expect_invalid(v, -1, regexp = "must be positive"))
  expect_success(expect_invalid(v, -1, regexp = "Found: -1"))
  expect_failure(expect_invalid(v, -1, regexp = "must be finite"),
                 "no message matches")
})

test_that("expect_invalid() passes context through and lets usage errors propagate", {
  v <- restrict("pred") |> require_length_matches(~ nrow(newdata))
  expect_success(expect_invalid(v, 1:3, newdata = data.frame(a = 1:2)))
  expect_error(expect_invalid(v, 1:3), "depends on: newdata")
})

test_that("expectations require a validator", {
  expect_error(expect_valid(1, 1), "restriction object")
  expect_error(expect_invalid(function(x) x, 1), "restriction object")
})
