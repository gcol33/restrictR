# ---- require_col() (#12) ----

age_v <- restrict("age") |>
  require_integer(no_na = TRUE) |>
  require_between(0, 120)

newdata_v <- restrict("newdata") |>
  require_df() |>
  require_col("age", age_v) |>
  require_col("sex", restrict("sex") |> require_one_of(c("f", "m")))

test_that("require_col() keeps the column path in errors", {
  expect_invisible(newdata_v(data.frame(age = 30L, sex = "f")))
  expect_error(newdata_v(data.frame(age = 130L, sex = "f")),
               "newdata\\$age: must be in \\[0, 120\\]")
  expect_error(newdata_v(data.frame(age = 30L, sex = "x")),
               "newdata\\$sex: must be one of")
})

test_that("require_col() fails on a missing column or non-data.frame", {
  expect_error(newdata_v(data.frame(sex = "f")),
               'newdata: column "age" does not exist')
  col_only <- restrict("newdata") |> require_col("age", age_v)
  expect_error(col_only(1:3), "must be a data.frame to check column")
})

test_that("require_col() passes context to formula steps", {
  v <- restrict("df") |>
    require_df() |>
    require_col("w", restrict("w") |> require_length_matches(~ nrow(ref)))
  df <- data.frame(w = 1:3)
  expect_invisible(v(df, ref = df))
  expect_error(v(df, ref = df[1:2, , drop = FALSE]), "df\\$w: length must match")
  expect_error(v(df), "depends on: ref")
  expect_identical(environment(v)$all_deps, "ref")
})

test_that("require_col() collects inner failures individually in all mode", {
  w <- restrict("x") |> require_numeric(no_na = TRUE) |> require_between(0, 1)
  v <- restrict("df") |> require_df() |> require_col("x", w)
  errs <- validation_errors(v, data.frame(x = c(NA, 5)))
  expect_length(errs, 2L)
  expect_match(errs[1], "df\\$x: must not contain NA")
  expect_match(errs[2], "df\\$x: must be in")
  # first mode stops at the first one
  expect_error(v(data.frame(x = c(NA, 5))), "must not contain NA")
})

test_that("require_col() reports a column type failure once in all mode", {
  w <- restrict("x") |> require_numeric() |> require_between(0, 1)
  v <- restrict("df") |> require_df() |> require_col("x", w)
  expect_length(validation_errors(v, data.frame(x = "a")), 1L)
})

test_that("require_col() nests for list-columns", {
  inner <- restrict("cell") |> require_numeric()
  col <- restrict("items") |> require_each(inner)
  v <- restrict("df") |> require_df() |> require_col("items", col)
  d <- data.frame(id = 1:2)
  d$items <- list(1, "a")
  expect_error(v(d), "df\\$items\\[\\[2\\]\\]: must be numeric, got character")
})

test_that("require_col() labels nest in print and contract text", {
  expect_match(as_contract_text(newdata_v),
               "\\$age: must be whole number \\(no NA\\); must be in \\[0, 120\\]")
  expect_output(print(newdata_v), "\\$sex: must be one of")
})

test_that("require_col() validates its arguments", {
  expect_error(restrict("d") |> require_col(1, age_v), "single non-NA")
  expect_error(restrict("d") |> require_col("a", "not a validator"),
               "restriction object")
})

test_that("the require_col_* family is gone", {
  ns <- asNamespace("restrictR")
  for (f in c("require_col_numeric", "require_col_character",
              "require_col_between", "require_col_one_of")) {
    expect_false(exists(f, envir = ns, inherits = FALSE))
  }
})


# ---- require_each() / require_fields() (#13) ----

layer_v <- restrict("layer") |> require_class("data.frame")
layers_v <- restrict("layers") |> require_class("list") |> require_each(layer_v)

test_that("require_each() reports the element path", {
  ok <- data.frame(a = 1)
  expect_invisible(layers_v(list(ok, ok)))
  expect_error(layers_v(list(ok, "oops")),
               'layers\\[\\[2\\]\\]: must be of class "data.frame", got character')
  expect_error(layers_v(list(a = ok, b = 1)), "layers\\$b: must be of class")
})

test_that("require_each() handles empty lists, NULL elements and non-lists", {
  expect_invisible(layers_v(list()))
  expect_error(layers_v(list(NULL)), "layers\\[\\[1\\]\\]")
  v <- restrict("x") |> require_each(restrict("e") |> require_numeric())
  expect_error(v(1:3), "must be a list to check each element, got integer")
  expect_error(v(NULL), "must be a list")
})

test_that("require_each() skips NULL elements for allow_null validators", {
  v <- restrict("x") |>
    require_each(restrict("e") |> require_numeric() |> allow_null())
  expect_invisible(v(list(1, NULL, 3)))
  expect_error(v(list(1, "a")), "x\\[\\[2\\]\\]")
})

test_that("require_each() reports every bad element in all mode", {
  v <- restrict("x") |> require_each(restrict("e") |> require_numeric())
  errs <- validation_errors(v, list(1, "a", "b"))
  expect_length(errs, 2L)
  expect_match(errs[1], "x\\[\\[2\\]\\]")
  expect_match(errs[2], "x\\[\\[3\\]\\]")
  expect_error(v(list(1, "a", "b")), "x\\[\\[2\\]\\]")
})

test_that("require_each() passes context through", {
  v <- restrict("x") |>
    require_each(restrict("e") |> require_length_matches(~ n))
  expect_invisible(v(list(1:2, 3:4), n = 2))
  expect_error(v(list(1:2, 3), n = 2), "x\\[\\[2\\]\\]: length must match")
})

opts_v <- restrict("opts") |>
  require_class("list") |>
  require_fields(
    alpha = restrict("alpha") |> require_numeric() |> require_between(0, 1),
    label = restrict("label") |> require_character()
  )

test_that("require_fields() validates named fields with paths", {
  expect_invisible(opts_v(list(alpha = 0.05, label = "a")))
  expect_error(opts_v(list(alpha = 2, label = "a")), "opts\\$alpha: must be in")
  expect_error(opts_v(list(alpha = 0.5)), "opts\\$label: is required but missing")
  errs <- validation_errors(opts_v, list(alpha = 2))
  expect_length(errs, 2L)
})

test_that("require_fields() honours .required and allow_null()", {
  opt <- restrict("opts") |>
    require_fields(alpha = restrict("alpha") |> require_numeric(),
                   .required = FALSE)
  expect_invisible(opt(list()))
  expect_error(opt(list(alpha = "a")), "opts\\$alpha: must be numeric")

  nul <- restrict("opts") |>
    require_fields(alpha = restrict("alpha") |> require_numeric() |> allow_null())
  expect_invisible(nul(list()))
  expect_invisible(nul(list(alpha = NULL)))
})

test_that("require_fields() validates its arguments", {
  expect_error(restrict("o") |> require_fields(), "uniquely named")
  expect_error(restrict("o") |> require_fields(age_v), "uniquely named")
  expect_error(restrict("o") |> require_fields(a = age_v, a = age_v),
               "uniquely named")
  expect_error(restrict("o") |> require_fields(a = 1), "restriction object")
  fields_only <- restrict("opts") |>
    require_fields(alpha = restrict("alpha") |> require_numeric())
  expect_error(fields_only(1:3), "must be a list to check fields")
})


# ---- allow_null() (#14) ----

test_that("allow_null() lets NULL pass and validates everything else", {
  df <- data.frame(a = 1:3)
  w <- restrict("weights") |>
    require_numeric(no_na = TRUE) |>
    require_positive() |>
    require_length_matches(~ nrow(data)) |>
    allow_null()
  expect_invisible(w(NULL, data = df))
  expect_invisible(w(NULL))
  expect_invisible(w(c(1, 2, 3), data = df))
  expect_error(w(-1, data = df), "must be non-negative")
  expect_error(w(1:2, data = df), "length must match")
  expect_error(w(1, data = df, .on_fail = "all"), "length must match")
})

test_that("allow_null() is order-independent and idempotent", {
  a <- restrict("x") |> allow_null() |> require_numeric()
  b <- restrict("x") |> require_numeric() |> allow_null() |> allow_null()
  expect_invisible(a(NULL))
  expect_invisible(b(NULL))
  expect_length(environment(b)$steps, 2L)
  expect_error(a("x"), "must be numeric")
})

test_that("a validator without allow_null() still rejects NULL", {
  expect_error((restrict("x") |> require_numeric())(NULL), "must be numeric")
})

test_that("allow_null() shows in print and contract text", {
  v <- restrict("x") |> require_numeric() |> allow_null()
  expect_output(print(v), "may be NULL")
  expect_identical(as_contract_text(v), "NULL, or: Must be numeric.")
  expect_match(as_contract_block(v), "may be NULL; otherwise:")
  expect_identical(as_contract_text(restrict("x") |> allow_null()),
                   "May be NULL.")
})

test_that("allow_null() lets a column be absent under require_col()", {
  v <- restrict("df") |>
    require_df() |>
    require_col("w", restrict("w") |> require_numeric() |> allow_null())
  expect_invisible(v(data.frame(a = 1)))
  expect_error(v(data.frame(w = "a")), "df\\$w: must be numeric")
})

test_that("allow_null() requires a restriction", {
  expect_error(allow_null(1), "restriction object")
})


# ---- require_valid() / require_any() (#15) ----

test_that("require_valid() splices another validator's steps", {
  id_v <- restrict("id") |> require_integer(no_na = TRUE)
  pos_v <- restrict("p") |> require_positive(strict = TRUE)
  v <- restrict("x") |> require_valid(id_v) |> require_valid(pos_v)
  expect_length(environment(v)$steps, 2L)
  expect_invisible(v(1:3))
  expect_error(v(c(1L, NA)), "x: must not contain NA")
  expect_error(v(0L), "x: must be positive")
  expect_output(print(v), "1\\. must be whole number")
})

test_that("require_valid() carries dependencies", {
  dep_v <- restrict("y") |> require_length_matches(~ n)
  v <- restrict("x") |> require_valid(dep_v)
  expect_identical(environment(v)$all_deps, "n")
  expect_error(v(1:2), "depends on: n")
  expect_invisible(v(1:2, n = 2))
})

test_that("require_valid() keeps NULL tolerance local to the spliced steps", {
  opt <- restrict("w") |> require_numeric() |> allow_null()
  v <- restrict("x") |> require_valid(opt)
  expect_invisible(v(NULL))
  expect_error(v("a"), "must be numeric")
  expect_error((restrict("x") |> require_valid(opt) |> require_scalar())(NULL),
               "must be a scalar|length 1")
})

num_or_df <- restrict("x") |>
  require_any(
    restrict("x") |> require_numeric(),
    restrict("x") |> require_df() |> require_has_cols("value")
  )

test_that("require_any() passes when one alternative passes", {
  expect_invisible(num_or_df(1:3))
  expect_invisible(num_or_df(data.frame(value = 1)))
})

test_that("require_any() lists every alternative's first failure", {
  err <- tryCatch(num_or_df("a"), error = conditionMessage)
  expect_match(err, "x: must satisfy one of:", fixed = TRUE)
  expect_match(err, "  - must be numeric, got character", fixed = TRUE)
  expect_match(err, "  - must be a data.frame, got character", fixed = TRUE)
  expect_error(num_or_df(data.frame(a = 1)), "missing required column")
  expect_s3_class(tryCatch(num_or_df("a"), error = identity),
                  "restrictR_failure")
})

test_that("require_any() treats missing context as a usage error", {
  v <- restrict("x") |>
    require_any(restrict("x") |> require_numeric(),
                restrict("x") |> require_length_matches(~ n))
  expect_error(v("a"), "depends on: n")
  expect_invisible(v(1, n = 5))
  expect_error(v("a", n = 5), "must satisfy one of")
})

test_that("require_any() respects allow_null alternatives and labels", {
  v <- restrict("x") |>
    require_any(restrict("x") |> require_numeric() |> allow_null(),
                restrict("x") |> require_character(),
                .label = "must be numeric, character or NULL")
  expect_invisible(v(NULL))
  expect_output(print(v), "must be numeric, character or NULL")
  expect_match(as_contract_text(num_or_df), "Must satisfy one of: (must be numeric)",
               fixed = TRUE)
})

test_that("require_any() reports one failure in all mode and validates input", {
  expect_length(validation_errors(num_or_df, "a"), 1L)
  expect_error(restrict("x") |> require_any(), "at least one")
  expect_error(restrict("x") |> require_any(1), "restriction object")
  expect_error(restrict("x") |> require_any(age_v, .label = 1), "\\.label")
})

test_that("the aggregated message is capped but $failures keeps everything", {
  v <- restrict("x") |> require_each(restrict("e") |> require_numeric())
  err <- tryCatch(v(as.list(rep("a", 30)), .on_fail = "all"), error = identity)
  expect_s3_class(err, "restrictR_failures")
  expect_length(err$failures, 30L)
  expect_match(conditionMessage(err), "30 validation failures")
  expect_match(conditionMessage(err), "... and 10 more", fixed = TRUE)
  expect_false(grepl("x[[21]]", conditionMessage(err), fixed = TRUE))
  expect_length(validation_errors(v, as.list(rep("a", 30))), 30L)
})
