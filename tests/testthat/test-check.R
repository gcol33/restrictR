# ---- .on_fail = "all": report every failure (#5) ----

test_that("default mode is fail-fast (first failure only)", {
  v <- restrict("x") |> require_positive() |> require_length(5L)
  err <- tryCatch(v(c(-1, -2)), error = conditionMessage)
  expect_match(err, "must be non-negative")
  expect_false(grepl("must have length 5", err))
})

test_that(".on_fail = 'all' aggregates every failing step", {
  v <- restrict("x") |> require_positive() |> require_length(5L)
  err <- tryCatch(v(c(-1, -2), .on_fail = "all"), error = conditionMessage)
  expect_match(err, "2 validation failures")
  expect_match(err, "must be non-negative")
  expect_match(err, "must have length 5")
})

test_that(".on_fail = 'all' passes clean values silently", {
  v <- restrict("x") |> require_numeric() |> require_positive()
  expect_invisible(v(c(1, 2, 3), .on_fail = "all"))
})

test_that(".on_fail = 'all' surfaces both a frame and a column problem", {
  require_survey <- restrict("survey") |>
    require_df() |>
    require_has_cols(c("age", "status")) |>
    require_col_between("age", lower = 0, upper = 150) |>
    require_col_one_of("status", c("active", "inactive"))

  bad <- data.frame(age = c(25, -5, 200), status = "unknown")

  err_all <- tryCatch(require_survey(bad, .on_fail = "all"),
                      error = conditionMessage)
  expect_match(err_all, "survey\\$age")
  expect_match(err_all, "survey\\$status")

  err_first <- tryCatch(require_survey(bad), error = conditionMessage)
  expect_match(err_first, "survey\\$age")
  expect_false(grepl("survey\\$status", err_first))
})

# ---- is_valid() / validation_errors() (#6) ----

test_that("validation_errors() returns character(0) for valid input", {
  v <- restrict("x") |> require_numeric() |> require_positive()
  expect_identical(validation_errors(v, c(1, 2, 3)), character(0))
})

test_that("validation_errors() returns one message per failing step", {
  v <- restrict("x") |> require_positive() |> require_length(5L)
  errs <- validation_errors(v, c(-1, -2))
  expect_length(errs, 2L)
  expect_true(any(grepl("must be non-negative", errs)))
  expect_true(any(grepl("must have length 5", errs)))
})

test_that("is_valid() is a logical predicate", {
  v <- restrict("x") |> require_numeric(no_na = TRUE)
  expect_true(is_valid(v, 1:5))
  expect_false(is_valid(v, c(1, NA)))
  expect_false(is_valid(v, "a"))
})

test_that("non-throwing helpers thread context arguments", {
  v <- restrict("pred") |> require_length_matches(~ nrow(newdata))
  df <- data.frame(x = 1:5)
  expect_true(is_valid(v, 1:5, newdata = df))
  expect_false(is_valid(v, 1:3, newdata = df))
  expect_length(validation_errors(v, 1:3, newdata = df), 1L)
})

test_that("non-throwing helpers let usage errors propagate", {
  v <- restrict("pred") |> require_length_matches(~ nrow(newdata))
  expect_error(is_valid(v, 1:5), "depends on: newdata")
  expect_error(validation_errors(v, 1:5), "depends on: newdata")
})

test_that("non-throwing helpers reject non-restriction input", {
  expect_error(is_valid(42, 1), "must be a restriction object")
  expect_error(validation_errors(function(x) x, 1),
               "must be a restriction object")
})

test_that(".on_fail = 'all' reports a type failure once per path (#11)", {
  w <- restrict("x") |> require_numeric() |> require_between(0, 1)
  expect_equal(validation_errors(w, "a"), "x: must be numeric, got character")
})

test_that(".on_fail = 'all' dedupes column type failures per column path", {
  v <- restrict("df") |>
    require_df() |>
    require_col_numeric("x") |>
    require_col_between("x", 0, 1)
  errs <- validation_errors(v, data.frame(x = "a"))
  expect_length(errs, 1L)
  expect_match(errs, "df[$]x: must be numeric")
})

test_that(".on_fail = 'all' still reports independent value failures", {
  v <- restrict("x") |> require_numeric(no_na = TRUE) |> require_between(0, 1)
  expect_length(validation_errors(v, c(NA, 5)), 2L)
})
