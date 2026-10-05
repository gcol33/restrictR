test_that("require_scalar() accepts length-1 values", {
  v <- restrict("x") |> require_scalar()
  expect_invisible(v(42))
  expect_invisible(v("hello"))
  expect_invisible(v(TRUE))
  expect_invisible(v(NA))
})

test_that("require_scalar() rejects non-scalar values", {
  v <- restrict("x") |> require_scalar()
  expect_error(v(1:5), "must be scalar")
  expect_error(v(1:5), "Found: length 5")
  expect_error(v(NULL), "must be scalar")
  expect_error(v(NULL), "Found: length 0")
  expect_error(v(character(0)), "must be scalar")
})

test_that("require_named() accepts named values", {
  v <- restrict("x") |> require_named()
  expect_invisible(v(c(a = 1, b = 2)))
  expect_invisible(v(list(x = 1, y = 2)))
})

test_that("require_named() rejects unnamed values", {
  v <- restrict("x") |> require_named()
  expect_error(v(1:3), "must be named")
  expect_error(v(list(1, 2)), "must be named")
})

test_that("require_named() rejects partially-named values", {
  v <- restrict("x") |> require_named()
  expect_error(v(c(a = 1, 2)), "must be named \\(all elements\\)")
  expect_error(v(c(a = 1, 2)), "At: 2")
  expect_error(v(c(a = 1, b = 2, 3)), "At: 3")
  expect_error(v(list(x = 1, 2)), "must be named \\(all elements\\)")
})

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

test_that("formula steps resolve non-base functions (#7)", {
  v <- restrict("x") |>
    require_length_matches(~ as.integer(median(reference)))

  expect_invisible(v(1:3, reference = c(3, 3, 3)))
  expect_error(
    v(1:4, reference = c(3, 3, 3)),
    "length must match"
  )
})

test_that("formula data names still come only from explicit context", {
  v <- restrict("x") |> require_length_matches(~ length(reference))
  reference <- 1:99  # must be ignored; not passed as context
  expect_error(v(1:3), "depends on: reference")
})

test_that("row-count steps reject non-data.frame input through fail()", {
  nmin <- restrict("df") |> require_nrow_min(2)
  nmatch <- restrict("df") |> require_nrow_matches(~ nrow(ref))
  ref <- data.frame(a = 1:2)
  for (bad in list(1:3, list(1, 2), NULL)) {
    expect_error(nmin(bad), "df: must be a data.frame or matrix to check row count",
                 class = "restrictR_failure")
    expect_error(nmatch(bad, ref = ref),
                 "df: must be a data.frame or matrix to check row count",
                 class = "restrictR_failure")
  }
  expect_error(nmin(1:3), "got integer")
})

test_that("length/nrow formulas must evaluate to a single non-NA number", {
  df <- data.frame(a = 1:2)
  nrow_v <- restrict("df") |> require_nrow_matches(~ ref)
  len_v <- restrict("x") |> require_length_matches(~ ref)
  expect_error(nrow_v(df, ref = c(2, 2)), "must evaluate to a single non-NA number",
               class = "restrictR_failure")
  expect_error(nrow_v(df, ref = NA_real_), "single non-NA number")
  expect_error(len_v(1:2, ref = c(2, 2)), "single non-NA number")
  expect_error(len_v(1:2, ref = NULL), "single non-NA number")
  expect_silent(len_v(1:2, ref = 2))
})

test_that("formula deps are the variables read, not members or built-in names", {
  expect_equal(formula_vars(quote(nrow(ref$id))), "ref")
  expect_equal(formula_vars(quote(length(a) + length(b$x$y))), c("a", "b"))
  expect_equal(formula_vars(quote(x[, 1])), "x")
  expect_equal(formula_deps(~ length(.value) + length(ref)), "ref")

  v <- restrict("x") |> require_length_matches(~ nrow(ref$tbl))
  expect_identical(environment(v)$all_deps, "ref")
  expect_invisible(v(1:2, ref = list(tbl = data.frame(a = 1:2))))

  w <- restrict("x") |> require_length_matches(~ length(.value))
  expect_invisible(w(1:3))
})
