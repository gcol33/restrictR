test_that("require_between() checks bounds", {
  v <- restrict("x") |> require_between(lower = 0, upper = 1)
  expect_invisible(v(0.5))
  expect_invisible(v(0))
  expect_invisible(v(1))
  expect_error(v(-0.1), "must be in \\[0, 1\\]")
  expect_error(v(-0.1), "Found: -0.1")
  expect_error(v(1.5), "must be in \\[0, 1\\]")
})

test_that("require_between() exclusive bounds", {
  v <- restrict("x") |>
    require_between(lower = 0, upper = 1,
                    exclusive_lower = TRUE, exclusive_upper = TRUE)
  expect_invisible(v(0.5))
  expect_error(v(0), "must be in \\(0, 1\\)")
  expect_error(v(1), "must be in \\(0, 1\\)")
})

test_that("require_between() shows At: for vectors", {
  v <- restrict("x") |> require_between(lower = 0, upper = 10)
  expect_error(v(c(5, -1, 3, -2)), "At: 2, 4")
})

test_that("require_one_of() checks set membership", {
  v <- restrict("method") |>
    require_character() |>
    require_one_of(c("euclidean", "manhattan", "cosine"))

  expect_invisible(v("euclidean"))
  expect_invisible(v("cosine"))
  expect_error(v("chebyshev"), 'must be one of.*"chebyshev"')
})

test_that("require_one_of() shows At: for vectors", {
  v <- restrict("x") |> require_one_of(c("a", "b", "c"))
  expect_error(v(c("a", "d", "b", "e")), "At: 2, 4")
})

test_that("require_positive() default (non-negative) allows zero", {
  v <- restrict("x") |> require_positive()
  expect_invisible(v(0))
  expect_invisible(v(5))
  expect_invisible(v(c(0, 1, 100)))
  expect_error(v(-1), "must be non-negative")
  expect_error(v(-1), "Found: -1")
})

test_that("require_positive(strict = TRUE) rejects zero", {
  v <- restrict("x") |> require_positive(strict = TRUE)
  expect_invisible(v(5))
  expect_error(v(0), "must be positive")
  expect_error(v(-1), "must be positive")
})

test_that("require_positive() shows At: for vectors", {
  v <- restrict("x") |> require_positive()
  expect_error(v(c(1, -2, 3, -4)), "At: 2, 4")
})

test_that("require_positive() omits At: for scalars", {
  v <- restrict("x") |> require_positive()
  err <- tryCatch(v(-1), error = conditionMessage)
  expect_false(grepl("At:", err))
})

test_that("require_negative() default (non-positive) allows zero", {
  v <- restrict("x") |> require_negative()
  expect_invisible(v(0))
  expect_invisible(v(-5))
  expect_invisible(v(c(0, -1, -100)))
  expect_error(v(1), "must be non-positive")
  expect_error(v(1), "Found: 1")
})

test_that("require_negative(strict = TRUE) rejects zero", {
  v <- restrict("x") |> require_negative(strict = TRUE)
  expect_invisible(v(-5))
  expect_error(v(0), "must be negative")
  expect_error(v(1), "must be negative")
})

test_that("require_negative() shows At: for vectors", {
  v <- restrict("x") |> require_negative()
  expect_error(v(c(-1, 2, -3, 4)), "At: 2, 4")
})

test_that("require_no_na() standalone check", {
  v <- restrict("x") |> require_no_na()
  expect_invisible(v(c(1, 2, 3)))
  expect_invisible(v(c("a", "b")))
  expect_error(v(c(1, NA, 3)), "must not contain NA")
  expect_error(v(c(1, NA, 3)), "At: 2")
})

test_that("require_no_na() with many NAs truncates At:", {
  v <- restrict("x") |> require_no_na()
  x <- rep(NA_real_, 10)
  expect_error(v(x), "and 5 more")
})

test_that("require_finite() standalone check", {
  v <- restrict("x") |> require_finite()
  expect_invisible(v(c(1, 2, 3)))
  expect_error(v(c(1, Inf, 3)), "must be finite")
  expect_error(v(c(1, Inf, 3)), "At: 2")
  # NA is not reported by require_finite (use require_no_na for that)
  expect_invisible(v(c(1, NA, 3)))
})

test_that("require_col_numeric() produces path-aware errors", {
  v <- restrict("newdata") |>
    require_df() |>
    require_col_numeric("x2")

  expect_invisible(v(data.frame(x2 = c(1, 2, 3))))
  expect_error(
    v(data.frame(x2 = c("a", "b"))),
    "newdata\\$x2: must be numeric, got character"
  )
})

test_that("require_col_numeric() checks NA and finite", {
  v <- restrict("data") |>
    require_df() |>
    require_col_numeric("val", no_na = TRUE, finite = TRUE)

  expect_invisible(v(data.frame(val = c(1, 2, 3))))
  expect_error(v(data.frame(val = c(1, NA, 3))),
               "data\\$val: must not contain NA")
  expect_error(v(data.frame(val = c(1, Inf, 3))),
               "data\\$val: must be finite")
})

test_that("require_col_character() produces path-aware errors", {
  v <- restrict("df") |>
    require_df() |>
    require_col_character("name", no_na = TRUE)

  expect_invisible(v(data.frame(name = c("a", "b"))))
  expect_error(
    v(data.frame(name = c("a", NA))),
    "df\\$name: must not contain NA"
  )
})

test_that("require_col_between() checks column value bounds", {
  v <- restrict("df") |>
    require_df() |>
    require_col_between("count", lower = 0)

  expect_invisible(v(data.frame(count = c(0, 5, 10))))
  expect_error(v(data.frame(count = c(5, -3, 10))),
               "df\\$count: must be >= 0")
  expect_error(v(data.frame(count = c(5, -3, 10))),
               "At: 2")
})

test_that("require_col_one_of() checks column set membership", {
  v <- restrict("df") |>
    require_df() |>
    require_col_one_of("status", c("active", "inactive"))

  expect_invisible(v(data.frame(status = c("active", "inactive"))))
  expect_error(
    v(data.frame(status = c("active", "unknown"))),
    'df\\$status: must be one of'
  )
  expect_error(
    v(data.frame(status = c("active", "unknown"))),
    'At: 2'
  )
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
    "newdata\\$x1: must be numeric"
  )
})

test_that("dependent validation end-to-end", {
  require_pred <- restrict("pred") |>
    require_numeric(no_na = TRUE, finite = TRUE) |>
    require_length_matches(~ nrow(newdata))

  newdata <- data.frame(x1 = 1:5, x2 = 6:10)
  expect_invisible(require_pred(1:5, newdata = newdata))
  expect_error(require_pred(1:3, newdata = newdata), "Found: length 3")
})
