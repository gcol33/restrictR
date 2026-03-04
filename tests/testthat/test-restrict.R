test_that("restrict() creates a restriction object", {
  v <- restrict("x")
  expect_s3_class(v, "restriction")
  expect_true(is.function(v))
  expect_equal(environment(v)$name, "x")
  expect_equal(environment(v)$steps, list())
})

test_that("restrict() validates name argument", {
  expect_error(restrict(42), "single non-NA character string")
  expect_error(restrict(NA_character_), "single non-NA character string")
  expect_error(restrict(c("a", "b")), "single non-NA character string")
})

test_that("restriction with no steps passes anything", {
  v <- restrict("x")
  expect_invisible(v(42))
  expect_invisible(v("hello"))
  expect_invisible(v(NULL))
})

test_that("print.restriction works with no steps", {
  v <- restrict("x")
  expect_output(print(v), "<restriction: x>")
  expect_output(print(v), "no validation steps")
})

test_that("print.restriction shows steps", {
  v <- restrict("x") |>
    require_numeric() |>
    require_length(1L)
  expect_output(print(v), "1\\. must be numeric")
  expect_output(print(v), "2\\. must have length 1")
})

test_that("print.restriction shows dependencies", {
  v <- restrict("x") |>
    require_numeric() |>
    require_length_matches(~ nrow(newdata))
  expect_output(print(v), "Depends on: newdata")
})

test_that("as_contract_text() produces plain text", {
  v <- restrict("x") |>
    require_numeric(no_na = TRUE) |>
    require_length(1L)
  txt <- as_contract_text(v)
  expect_type(txt, "character")
  expect_length(txt, 1L)
  expect_match(txt, "Must be numeric")
  expect_match(txt, "must have length 1")
})

test_that("as_contract_text() handles empty restriction", {
  v <- restrict("x")
  expect_equal(as_contract_text(v), "No validation constraints.")
})

test_that("pipe steps are immutable (branching is safe)", {
  base <- restrict("x") |> require_numeric()
  v1 <- base |> require_length(1L)
  v2 <- base |> require_range(lower = 0)

  # base is unchanged: still has 1 step

  expect_length(environment(base)$steps, 1L)

  # v1 and v2 are independent: each has 2 steps
  expect_length(environment(v1)$steps, 2L)
  expect_length(environment(v2)$steps, 2L)

  # v1 rejects length > 1, v2 doesn't
  expect_error(v1(c(1, 2)), "must have length 1")
  expect_invisible(v2(c(1, 2)))

  # v2 rejects negatives, v1 doesn't
  expect_error(v2(-1), "must be in")
  expect_invisible(v1(-1))
})
