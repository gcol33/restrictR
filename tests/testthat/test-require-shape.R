test_that("require_ncol_min() checks columns of data.frames and matrices", {
  v <- restrict("X") |> require_ncol_min(3)
  expect_valid(v, data.frame(a = 1, b = 2, c = 3))
  expect_valid(v, matrix(0, 2, 4))
  expect_invalid(v, data.frame(a = 1), regexp = "X: must have at least 3 columns")
  expect_match(validation_errors(v, matrix(0, 2, 1)), "Found: 1 column",
               fixed = TRUE)
  expect_equal(steps(restrict("X") |> require_ncol_min(1))$label,
               "must have at least 1 column")
})

test_that("require_ncol_matches() compares with a formula", {
  v <- restrict("X") |> require_ncol_matches(~ ncol(reference))
  ref <- matrix(0, 2, 3)
  expect_valid(v, data.frame(a = 1, b = 2, c = 3), reference = ref)
  err <- validation_errors(v, matrix(0, 4, 2), reference = ref)
  expect_match(err, "ncol must match ncol(reference) (3)", fixed = TRUE)
  expect_match(err, "Found: 2 columns", fixed = TRUE)
  expect_error(v(matrix(0, 1, 1)), "depends on: reference")
  expect_error(restrict("X") |> require_ncol_matches(y ~ z), "one-sided formula")
})

test_that("row and column steps accept matrices and reject other input", {
  expect_valid(restrict("m") |> require_nrow_min(2), matrix(0, 2, 2))
  expect_valid(restrict("m") |> require_nrow_matches(~ 2), matrix(0, 2, 5))
  for (v in list(restrict("x") |> require_ncol_min(1),
                 restrict("x") |> require_ncol_matches(~ 1))) {
    expect_error(v(1:3), "x: must be a data.frame or matrix to check column count",
                 class = "restrictR_precondition")
  }
})

test_that("require_dim() checks exact dimensions with NA wildcards", {
  v <- restrict("X") |> require_dim(c(NA, 3))
  expect_valid(v, matrix(0, 10, 3))
  expect_valid(v, data.frame(a = 1:2, b = 1:2, c = 1:2))
  err <- validation_errors(v, matrix(0, 10, 2))
  expect_match(err, "X: must have dim (any, 3)", fixed = TRUE)
  expect_match(err, "Found: dim (10, 2)", fixed = TRUE)
  expect_invalid(v, array(0, c(2, 3, 4)))
  expect_valid(restrict("X") |> require_dim(c(2, 3, 4)), array(0, c(2, 3, 4)))
})

test_that("require_dim() rejects input without dimensions", {
  v <- restrict("X") |> require_dim(c(1, 1))
  expect_error(v(1:3), "X: must be a data.frame, matrix or array to check dim, got integer",
               class = "restrictR_precondition")
})

test_that("require_dim() checks dims when built", {
  expect_error(restrict("x") |> require_dim("a"), "non-negative whole numbers")
  expect_error(restrict("x") |> require_dim(c(-1, 2)), "non-negative whole numbers")
  expect_error(restrict("x") |> require_dim(numeric(0)), "non-negative whole numbers")
})

test_that("require_class('matrix') covers matrices without a dedicated step", {
  v <- restrict("m") |> require_class("matrix")
  expect_valid(v, matrix(1:4, 2))
  expect_invalid(v, data.frame(a = 1), regexp = 'must be of class "matrix", got data.frame')
  expect_invalid(v, 1:4)
})

test_that("require_sorted() accepts ordered values", {
  expect_valid(restrict("x") |> require_sorted(), c(1, 2, 2, 5))
  expect_valid(restrict("x") |> require_sorted(), c(1))
  expect_valid(restrict("x") |> require_sorted(), numeric(0))
  expect_valid(restrict("x") |> require_sorted(decreasing = TRUE), c(5, 2, 2, 1))
  expect_valid(restrict("x") |> require_sorted(strict = TRUE), c(1, 2, 5))
  expect_valid(restrict("x") |> require_sorted(), c("a", "b", "c"))
  expect_valid(restrict("x") |> require_sorted(), as.Date(c("2020-01-01", "2020-06-01")))
  expect_valid(restrict("x") |> require_sorted(),
               factor(c("lo", "hi"), levels = c("lo", "hi"), ordered = TRUE))
})

test_that("require_sorted() reports the first out-of-order position", {
  v <- restrict("t") |> require_sorted()
  err <- validation_errors(v, c(1, 3, 2, 1))
  expect_match(err, "t: must be increasing order", fixed = TRUE)
  expect_match(err, "Found: 2 after 3", fixed = TRUE)
  expect_match(err, "At: 3", fixed = TRUE)
})

test_that("require_sorted() strict and decreasing variants", {
  expect_invalid(restrict("x") |> require_sorted(strict = TRUE), c(1, 2, 2),
                 regexp = "must be strictly increasing order")
  expect_invalid(restrict("x") |> require_sorted(decreasing = TRUE), c(3, 1, 2),
                 regexp = "must be decreasing order")
  expect_invalid(restrict("x") |> require_sorted(decreasing = TRUE, strict = TRUE),
                 c(3, 3), regexp = "must be strictly decreasing order")
})

test_that("require_sorted() skips NA and keeps original positions", {
  v <- restrict("x") |> require_sorted()
  expect_valid(v, c(1, NA, 2))
  err <- validation_errors(v, c(1, NA, 0))
  expect_match(err, "At: 3", fixed = TRUE)
})

test_that("require_sorted() rejects values without an order", {
  v <- restrict("x") |> require_sorted()
  expect_error(v(factor(c("a", "b"))), "must be orderable to check order, got factor",
               class = "restrictR_precondition")
  expect_error(v(list(1, 2)), "got list")
})

test_that("require_length_min() and friends keep their wording", {
  expect_equal(steps(restrict("x") |> require_scalar())$label, "must be scalar")
  expect_equal(steps(restrict("x") |> require_length(2L))$label, "must have length 2")
})
