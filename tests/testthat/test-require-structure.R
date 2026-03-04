test_that("require_length() checks exact length", {
  v <- restrict("x") |> require_length(3L)
  expect_invisible(v(1:3))
  expect_error(v(1:2), "must have length 3")
  expect_error(v(1:2), "Found: length 2")
  expect_error(v(1:5), "Found: length 5")
})

test_that("require_length(1L) for scalar check", {
  v <- restrict("lr") |> require_numeric() |> require_length(1L)
  expect_invisible(v(0.01))
  expect_error(v(c(0.01, 0.02)), "must have length 1")
})

test_that("require_length_min() checks minimum length", {
  v <- restrict("x") |> require_length_min(3L)
  expect_invisible(v(1:3))
  expect_invisible(v(1:10))
  expect_error(v(1:2), "must have length >= 3")
  expect_error(v(1:2), "Found: length 2")
})

test_that("require_length_max() checks maximum length", {
  v <- restrict("x") |> require_length_max(3L)
  expect_invisible(v(1:3))
  expect_invisible(v(1L))
  expect_error(v(1:5), "must have length <= 3")
  expect_error(v(1:5), "Found: length 5")
})

test_that("require_nrow_min() checks minimum rows", {
  v <- restrict("data") |> require_df() |> require_nrow_min(5)
  expect_invisible(v(data.frame(x = 1:10)))
  expect_error(v(data.frame(x = 1:3)), "must have at least 5 rows")
  expect_error(v(data.frame(x = 1:3)), "Found: 3 rows")
})

test_that("require_nrow_matches() checks row count against formula", {
  v <- restrict("newdata") |>
    require_df() |>
    require_nrow_matches(~ nrow(reference))

  ref <- data.frame(x = 1:5)
  expect_invisible(v(data.frame(y = 1:5), reference = ref))
  expect_error(
    v(data.frame(y = 1:3), reference = ref),
    "nrow must match nrow\\(reference\\) \\(5\\)"
  )
  expect_error(
    v(data.frame(y = 1:3), reference = ref),
    "Found: 3 rows"
  )
})

test_that("require_nrow_matches() fails when context missing", {
  v <- restrict("newdata") |>
    require_df() |>
    require_nrow_matches(~ nrow(reference))

  expect_error(v(data.frame(x = 1)), "depends on: reference")
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
    "length must match nrow\\(newdata\\) \\(5\\)"
  )
  expect_error(
    v(1:3, newdata = df),
    "Found: length 3"
  )
})

test_that("require_length_matches() fails when context missing", {
  v <- restrict("pred") |>
    require_length_matches(~ nrow(newdata))

  expect_error(v(1:5), "depends on: newdata")
  expect_error(v(1:5), "Pass newdata = ")
})

test_that(".ctx argument works and merges with ...", {
  v <- restrict("pred") |>
    require_numeric() |>
    require_length_matches(~ nrow(newdata))

  df <- data.frame(x = 1:5)

  # via .ctx
  expect_invisible(v(1:5, .ctx = list(newdata = df)))

  # via ...
  expect_invisible(v(1:5, newdata = df))

  # ... takes precedence over .ctx
  df3 <- data.frame(x = 1:3)
  expect_invisible(v(1:5, newdata = df, .ctx = list(newdata = df3)))
})

test_that("require_length_matches() rejects two-sided formulas", {
  expect_error(
    restrict("x") |> require_length_matches(y ~ nrow(z)),
    "one-sided formula"
  )
})
