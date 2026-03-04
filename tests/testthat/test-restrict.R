test_that("restrict() creates a restriction object", {
  v <- restrict("x")
  expect_s3_class(v, "restriction")
  expect_true(is.function(v))
  expect_equal(attr(v, "restriction_name"), "x")
  expect_equal(attr(v, "steps"), list())
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
