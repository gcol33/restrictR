test_that("require_df() passes for data.frames", {
  v <- restrict("x") |> require_df()
  expect_invisible(v(data.frame(a = 1)))
  expect_invisible(v(mtcars))
})

test_that("require_df() fails for non-data.frames", {
  v <- restrict("x") |> require_df()
  expect_error(v(1:5), "must be a data.frame, got integer")
  expect_error(v(list(a = 1)), "must be a data.frame, got list")
  expect_error(v(matrix(1:4, 2)), "must be a data.frame, got matrix")
})

test_that("require_numeric() passes for numeric", {
  v <- restrict("x") |> require_numeric()
  expect_invisible(v(1:5))
  expect_invisible(v(c(1.0, 2.5)))
  expect_invisible(v(NA_real_))
})

test_that("require_numeric() fails for non-numeric", {
  v <- restrict("x") |> require_numeric()
  expect_error(v("a"), "must be numeric, got character")
  expect_error(v(TRUE), "must be numeric, got logical")
})

test_that("require_numeric(no_na = TRUE) rejects NAs", {
  v <- restrict("x") |> require_numeric(no_na = TRUE)
  expect_invisible(v(c(1, 2, 3)))
  expect_error(v(c(1, NA, 3)), "must not contain NA")
  expect_error(v(c(1, NA, 3)), "At: 2")
})

test_that("require_numeric(finite = TRUE) rejects Inf", {
  v <- restrict("x") |> require_numeric(finite = TRUE)
  expect_invisible(v(c(1, 2, 3)))
  expect_error(v(c(1, Inf)), "must be finite")
  expect_error(v(c(-Inf, 1)), "must be finite")
  expect_error(v(c(1, NaN)), "must be finite")
})

test_that("require_integer() default accepts whole numeric values", {
  v <- restrict("x") |> require_integer()
  expect_invisible(v(1L))
  expect_invisible(v(1:5))
  expect_invisible(v(5))
  expect_invisible(v(c(1, 2, 3)))
  expect_invisible(v(NA_integer_))
  expect_invisible(v(NA_real_))
})

test_that("require_integer() default rejects non-whole values", {
  v <- restrict("x") |> require_integer()
  expect_error(v(1.5), "must be whole number")
  expect_error(v(1.5), "Found: 1.5")
  expect_error(v("a"), "must be numeric or integer, got character")
})

test_that("require_integer() shows At: for vectors with fractional values", {
  v <- restrict("x") |> require_integer()
  expect_error(v(c(1, 2.5, 3, 4.1)), "At: 2, 4")
})

test_that("require_integer(strict = TRUE) requires integer type", {
  v <- restrict("x") |> require_integer(strict = TRUE)
  expect_invisible(v(1L))
  expect_invisible(v(1:5))
  expect_error(v(1.0), "must be integer type, got numeric")
  expect_error(v("a"), "must be integer type, got character")
})

test_that("require_integer(no_na = TRUE) rejects NAs", {
  v <- restrict("x") |> require_integer(no_na = TRUE)
  expect_invisible(v(c(1, 2, 3)))
  expect_invisible(v(1:3))
  expect_error(v(c(1L, NA_integer_, 3L)), "must not contain NA")
  expect_error(v(c(1, NA, 3)), "must not contain NA")
})

test_that("require_integer(strict = TRUE, no_na = TRUE) rejects NAs", {
  v <- restrict("x") |> require_integer(strict = TRUE, no_na = TRUE)
  expect_invisible(v(1:3))
  expect_error(v(c(1L, NA_integer_, 3L)), "must not contain NA")
})

test_that("require_character() passes for character", {
  v <- restrict("x") |> require_character()
  expect_invisible(v(c("a", "b")))
  expect_invisible(v(NA_character_))
})

test_that("require_character() fails for non-character", {
  v <- restrict("x") |> require_character()
  expect_error(v(42), "must be character, got numeric")
})

test_that("require_character(no_na = TRUE) rejects NAs", {
  v <- restrict("x") |> require_character(no_na = TRUE)
  expect_invisible(v(c("a", "b")))
  expect_error(v(c("a", NA)), "must not contain NA")
})

test_that("require_logical() passes for logical", {
  v <- restrict("x") |> require_logical()
  expect_invisible(v(TRUE))
  expect_invisible(v(c(TRUE, FALSE)))
  expect_invisible(v(NA))
})

test_that("require_logical() fails for non-logical", {
  v <- restrict("x") |> require_logical()
  expect_error(v(1), "must be logical, got numeric")
  expect_error(v("TRUE"), "must be logical, got character")
})

test_that("require_logical(no_na = TRUE) rejects NAs", {
  v <- restrict("x") |> require_logical(no_na = TRUE)
  expect_invisible(v(c(TRUE, FALSE)))
  expect_error(v(c(TRUE, NA)), "must not contain NA")
})
