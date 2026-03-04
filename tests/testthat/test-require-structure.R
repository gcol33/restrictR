test_that("require_length() checks exact length", {
  v <- restrict("x") |> require_length(3L)
  expect_invisible(v(1:3))
  expect_error(v(1:2), "must have length 3, got 2")
  expect_error(v(1:5), "must have length 3, got 5")
})

test_that("require_length(1L) for scalar check", {
  v <- restrict("lr") |> require_numeric() |> require_length(1L)
  expect_invisible(v(0.01))
  expect_error(v(c(0.01, 0.02)), "must have length 1, got 2")
})

test_that("require_nrow_min() checks minimum rows", {
  v <- restrict("data") |> require_df() |> require_nrow_min(5)
  expect_invisible(v(data.frame(x = 1:10)))
  expect_error(v(data.frame(x = 1:3)), "must have at least 5 rows, got 3")
})

test_that("require_has_cols() checks column existence", {
  v <- restrict("df") |> require_df() |> require_has_cols(c("a", "b"))
  expect_invisible(v(data.frame(a = 1, b = 2, c = 3)))
  expect_error(v(data.frame(a = 1)), 'missing required column: "b"')
  expect_error(v(data.frame(z = 1)), 'missing required columns: "a", "b"')
})

test_that("require_length_matches() with explicit context", {
  v <- restrict("pred") |>
    require_numeric() |>
    require_length_matches(~ nrow(newdata))

  df <- data.frame(x = 1:5)
  expect_invisible(v(1:5, newdata = df))
  expect_error(
    v(1:3, newdata = df),
    "length must match nrow\\(newdata\\) \\(5\\), got 3"
  )
})

test_that("require_length_matches() fails when context missing", {
  v <- restrict("pred") |>
    require_length_matches(~ nrow(newdata))

  expect_error(v(1:5), "cannot evaluate")
  expect_error(v(1:5), "pass `newdata` as a named argument")
})

test_that("require_length_matches() rejects two-sided formulas", {
  expect_error(
    restrict("x") |> require_length_matches(y ~ nrow(z)),
    "one-sided formula"
  )
})
