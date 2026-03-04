test_that("require_range() checks bounds", {
  v <- restrict("x") |> require_range(lower = 0, upper = 1)
  expect_invisible(v(0.5))
  expect_invisible(v(0))
  expect_invisible(v(1))
  expect_error(v(-0.1), "must be in \\[0, 1\\]")
  expect_error(v(1.5), "must be in \\[0, 1\\]")
})

test_that("require_range() exclusive bounds", {
  v <- restrict("x") |>
    require_range(lower = 0, upper = 1,
                  exclusive_lower = TRUE, exclusive_upper = TRUE)
  expect_invisible(v(0.5))
  expect_error(v(0), "must be in \\(0, 1\\)")
  expect_error(v(1), "must be in \\(0, 1\\)")
})

test_that("require_one_of() checks set membership", {
  v <- restrict("method") |>
    require_character() |>
    require_one_of(c("euclidean", "manhattan", "cosine"))

  expect_invisible(v("euclidean"))
  expect_invisible(v("cosine"))
  expect_error(v("chebyshev"), 'must be one of.*got "chebyshev"')
})

test_that("require_col_numeric() produces path-aware errors", {
  v <- restrict("newdata") |>
    require_df() |>
    require_col_numeric("x2")

  expect_invisible(v(data.frame(x2 = c(1, 2, 3))))
  expect_error(
    v(data.frame(x2 = c("a", "b"))),
    "newdata\\$x2 must be numeric, got character"
  )
})

test_that("require_col_numeric() checks NA and finite", {
  v <- restrict("data") |>
    require_df() |>
    require_col_numeric("val", no_na = TRUE, finite = TRUE)

  expect_invisible(v(data.frame(val = c(1, 2, 3))))
  expect_error(v(data.frame(val = c(1, NA, 3))),
               "data\\$val must not contain NA")
  expect_error(v(data.frame(val = c(1, Inf, 3))),
               "data\\$val must be finite")
})

test_that("require_col_character() produces path-aware errors", {
  v <- restrict("df") |>
    require_df() |>
    require_col_character("name", no_na = TRUE)

  expect_invisible(v(data.frame(name = c("a", "b"))))
  expect_error(
    v(data.frame(name = c("a", NA))),
    "df\\$name must not contain NA"
  )
})

test_that("require_col_range() checks column value bounds", {
  v <- restrict("df") |>
    require_df() |>
    require_col_range("count", lower = 0)

  expect_invisible(v(data.frame(count = c(0, 5, 10))))
  expect_error(v(data.frame(count = c(5, -3, 10))),
               "df\\$count must be >= 0")
})

test_that("full schema validation works end-to-end", {
  require_newdata <- restrict("newdata") |>
    require_df() |>
    require_has_cols(c("x1", "x2")) |>
    require_col_numeric("x1", no_na = TRUE, finite = TRUE) |>
    require_col_numeric("x2", no_na = TRUE, finite = TRUE) |>
    require_nrow_min(1)

  good <- data.frame(x1 = c(1, 2, 3), x2 = c(4, 5, 6))
  expect_invisible(require_newdata(good))

  expect_error(require_newdata(42), "must be a data.frame")
  expect_error(require_newdata(data.frame(x1 = 1)), 'missing required column')
  expect_error(
    require_newdata(data.frame(x1 = "a", x2 = 1)),
    "newdata\\$x1 must be numeric"
  )
})

test_that("dependent validation end-to-end", {
  require_pred <- restrict("pred") |>
    require_numeric(no_na = TRUE, finite = TRUE) |>
    require_length_matches(~ nrow(newdata))

  newdata <- data.frame(x1 = 1:5, x2 = 6:10)
  expect_invisible(require_pred(1:5, newdata = newdata))
  expect_error(require_pred(1:3, newdata = newdata), "got 3")
})
