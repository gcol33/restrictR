test_that("require_names() modes", {
  ident <- restrict("cfg") |> require_names(c("a", "b"))
  expect_valid(ident, list(a = 1, b = 2))
  expect_invalid(ident, list(b = 1, a = 2), regexp = "names are in a different order")
  expect_match(validation_errors(ident, list(b = 1, a = 2)),
               'Found: "b", "a"', fixed = TRUE)

  sub <- restrict("cfg") |> require_names(c("a", "b"), mode = "subset")
  expect_valid(sub, list(a = 1))
  expect_valid(sub, list(b = 1, a = 2))
  expect_valid(sub, list())
  expect_invalid(sub, list(a = 1, z = 2), regexp = 'unexpected name: "z"')

  sup <- restrict("cfg") |> require_names(c("a", "b"), mode = "superset")
  expect_valid(sup, list(a = 1, b = 2, c = 3))
  expect_invalid(sup, list(a = 1), regexp = 'missing required name: "b"')
  expect_invalid(sup, 1:2, regexp = 'missing required names: "a", "b"')

  perm <- restrict("cfg") |> require_names(c("a", "b"), mode = "permutation")
  expect_valid(perm, list(b = 1, a = 2))
  expect_invalid(perm, list(a = 1, a = 2, b = 3), regexp = "differ in how often")
})

test_that("require_names() reports missing and unexpected names together", {
  v <- restrict("cfg") |> require_names(c("a", "b"))
  err <- validation_errors(v, list(a = 1, z = 2))
  expect_match(err, 'cfg: missing required name: "b"; unexpected name: "z"',
               fixed = TRUE)
})

test_that("require_names() labels and checks its arguments", {
  expect_equal(steps(restrict("x") |> require_names(c("a", "b"), "superset"))$label,
               'must have names: "a", "b"')
  expect_equal(steps(restrict("x") |> require_names("a", "subset"))$label,
               'names must be among: "a"')
  expect_error(restrict("x") |> require_names("a", mode = "other"), "should be one of")
  expect_error(restrict("x") |> require_names(1:2), "character vector without NA")
  expect_error(restrict("x") |> require_names(NA_character_), "without NA")
})

test_that("require_has_cols() is the superset case with column wording", {
  v <- restrict("df") |> require_has_cols(c("a", "b"))
  expect_equal(steps(v)$label, 'must have columns: "a", "b"')
  expect_valid(v, data.frame(a = 1, b = 2, c = 3))
  expect_invalid(v, data.frame(a = 1), regexp = 'missing required column: "b"')
})

test_that("require_unique_names() reports duplicated names", {
  v <- restrict("x") |> require_unique_names()
  expect_valid(v, c(a = 1, b = 2))
  expect_valid(v, 1:3)
  expect_valid(v, c(a = 1, 2, 3))
  err <- validation_errors(v, c(a = 1, b = 2, a = 3, b = 4))
  expect_match(err, "x: names must be unique", fixed = TRUE)
  expect_match(err, 'Found: "a", "b"', fixed = TRUE)
  expect_match(err, "At: 3, 4", fixed = TRUE)
})

test_that("require_levels() modes", {
  ident <- restrict("f") |> require_levels(c("a", "b"))
  expect_valid(ident, factor(c("a", "b")))
  expect_invalid(ident, factor("a", levels = c("b", "a")),
                 regexp = "levels are in a different order")

  sub <- restrict("f") |> require_levels(c("a", "b"), mode = "subset")
  expect_valid(sub, factor("a", levels = c("a", "b")))
  expect_valid(sub, factor("a"))
  expect_invalid(sub, factor(c("a", "z")), regexp = 'f: unexpected level: "z"')

  sup <- restrict("f") |> require_levels(c("a", "b"), mode = "superset")
  expect_valid(sup, factor(c("a", "b", "c")))
  expect_invalid(sup, factor("a"), regexp = 'missing required level: "b"')
})

test_that("require_levels() reads declared levels and rejects non-factors", {
  sub <- restrict("f") |> require_levels(c("a", "b"), mode = "subset")
  expect_valid(sub, factor(c("a", "a"), levels = c("a", "b")))
  expect_error(sub(c("a", "b")), "f: must be a factor, got character",
               class = "restrictR_precondition")
  expect_error(restrict("f") |> require_levels(1:2), "character vector without NA")
})

test_that("require_contains() requires every listed value", {
  v <- restrict("x") |> require_contains(c("a", "b"))
  expect_valid(v, c("a", "b", "c"))
  expect_valid(v, c("b", "a", "a"))
  expect_invalid(v, "a", regexp = 'x: missing required value: "b"')
  expect_invalid(v, character(0), regexp = 'missing required values: "a", "b"')
  expect_invalid(v, NULL, regexp = "missing required values")
})

test_that("require_contains() ignores NA and compares factors by label", {
  v <- restrict("x") |> require_contains(c("a", "b"))
  expect_valid(v, c("a", "b", NA))
  expect_valid(v, factor(c("a", "b", "c")))
  expect_invalid(v, factor(c("a", "c")), regexp = 'missing required value: "b"')
  expect_valid(restrict("x") |> require_contains(2:3), c(3, 2, 1))
  expect_error(v(list("a", "b")), "must be an atomic vector, got list",
               class = "restrictR_precondition")
})

test_that("require_set_equal() ignores order and duplicates", {
  v <- restrict("x") |> require_set_equal(c("a", "b"))
  expect_valid(v, c("b", "a", "a"))
  expect_valid(v, factor(c("b", "a")))
  expect_valid(v, c("a", "b", NA))
  err <- validation_errors(v, c("a", "z"))
  expect_match(err, 'x: missing required value: "b"; unexpected value: "z"',
               fixed = TRUE)
  expect_equal(steps(v)$label, 'values must be exactly the set: "a", "b"')
})

test_that("require_one_of() is the subset test for vectors", {
  v <- restrict("x") |> require_one_of(c("a", "b", "c"))
  expect_valid(v, c("a", "c"))
  expect_valid(v, character(0))
  expect_invalid(v, c("a", "q"), regexp = 'Found: "q"')
})

test_that("require_disjoint() compares with context", {
  v <- restrict("train_ids") |> require_disjoint(~ test_ids)
  expect_valid(v, 1:3, test_ids = 4:6)
  expect_valid(v, c(1, NA), test_ids = c(NA, 2))
  err <- validation_errors(v, c(1, 2, 3, 4), test_ids = c(3, 4, 9))
  expect_match(err, "train_ids: must not share values with test_ids", fixed = TRUE)
  expect_match(err, 'Found: "3", "4"', fixed = TRUE)
  expect_match(err, "At: 3, 4", fixed = TRUE)
})

test_that("require_disjoint() handles factors, expressions and bad context", {
  v <- restrict("a") |> require_disjoint(~ b)
  expect_invalid(v, factor(c("x", "y")), b = c("y", "z"), regexp = 'Found: "y"')
  expect_valid(v, c("x", "y"), b = factor("z"))
  w <- restrict("a") |> require_disjoint(~ unique(ref$id))
  expect_valid(w, 1:2, ref = data.frame(id = 3:4))
  expect_error(v(1, b = list(1)), "must evaluate to a vector", class = "restrictR_failure")
  expect_error(v(1), "depends on: b")
  expect_error(restrict("a") |> require_disjoint(y ~ b), "one-sided formula")
  expect_error(w(list(1), ref = data.frame(id = 1)),
               "must be an atomic vector, got list")
})
