test_that("require_function() accepts functions and rejects other input", {
  v <- restrict("fn") |> require_function()
  expect_valid(v, function(x) x)
  expect_valid(v, sum)
  expect_error(v("mean"), "fn: must be a function, got character",
               class = "restrictR_precondition")
  expect_error(v(NULL), "got NULL")
})

test_that("require_function(args =) needs the named formals", {
  v <- restrict("fn") |> require_function(args = c("value", "name"))
  expect_valid(v, function(value, name, extra = 1) NULL)
  err <- validation_errors(v, function(value) NULL)
  expect_match(err, 'fn: must be a function with arguments "value", "name"',
               fixed = TRUE)
  expect_match(err, "Found: function(value)", fixed = TRUE)
  expect_invalid(v, function(...) NULL)
})

test_that("require_function(nargs =) means callable with that many positional arguments", {
  v <- restrict("fn") |> require_function(nargs = 2L)
  expect_valid(v, function(a, b) NULL)
  expect_valid(v, function(a, b, c = 1) NULL)
  expect_valid(v, function(a, ...) NULL)
  expect_valid(v, function(...) NULL)
  expect_valid(v, `+`)
  expect_invalid(v, function(a) NULL, regexp = "callable with 2 positional arguments")
  expect_invalid(v, function(a, b, c) NULL)
  expect_invalid(v, function() NULL)
  expect_valid(restrict("fn") |> require_function(nargs = 0L), function() NULL)
  expect_valid(restrict("fn") |> require_function(nargs = 0L), function(a = 1) NULL)
})

test_that("require_function() combines args and nargs in the label", {
  v <- restrict("fn") |> require_function(args = "x", nargs = 1L)
  expect_equal(steps(v)$label,
               'must be a function with arguments "x", callable with 1 positional argument')
  expect_valid(v, function(x) x)
})

test_that("require_function() checks its arguments when built", {
  expect_error(restrict("f") |> require_function(args = 1), "unique argument names")
  expect_error(restrict("f") |> require_function(args = c("a", "a")), "unique")
  expect_error(restrict("f") |> require_function(nargs = -1), "non-negative whole number")
  expect_error(restrict("f") |> require_function(nargs = 1.5), "whole number")
})

test_that("require_custom() requires a three-argument function", {
  expect_error(restrict("x") |> require_custom("l", function(value) NULL),
               "fn: must be a function callable with 3 positional arguments")
  expect_error(restrict("x") |> require_custom("l", function(value, name, ctx, z) NULL),
               "callable with 3")
  expect_no_error(restrict("x") |> require_custom("l", function(...) NULL))
})
