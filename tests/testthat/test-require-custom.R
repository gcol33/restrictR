test_that("require_custom() adds a custom step", {
  v <- restrict("id") |>
    require_custom(
      label = "must be unique",
      fn = function(value, name, ctx) {
        if (anyDuplicated(value) > 0L) {
          fail <- get("fail", envir = asNamespace("restrictR"))
          fail(name, "contains duplicates")
        }
      }
    )

  expect_invisible(v(c(1, 2, 3)))
  expect_error(v(c(1, 2, 1)), "contains duplicates")
})

test_that("require_custom() shows label in print", {
  v <- restrict("x") |>
    require_numeric() |>
    require_custom(label = "must be sorted ascending", fn = function(value, name, ctx) {
      if (is.unsorted(value)) {
        stop(sprintf("%s: not sorted", name), call. = FALSE)
      }
    })

  expect_output(print(v), "must be sorted ascending")
})

test_that("require_custom() with deps enforces context", {
  v <- restrict("weights") |>
    require_numeric() |>
    require_custom(
      label = "must sum to 1",
      deps = "expected_sum",
      fn = function(value, name, ctx) {
        if (abs(sum(value) - ctx$expected_sum) > 1e-8) {
          stop(sprintf("%s: sum is %g, expected %g",
                       name, sum(value), ctx$expected_sum), call. = FALSE)
        }
      }
    )

  expect_invisible(v(c(0.5, 0.3, 0.2), expected_sum = 1))
  expect_error(v(c(0.5, 0.3, 0.2)), "depends on: expected_sum")
  expect_error(v(c(0.5, 0.5, 0.5), expected_sum = 1), "sum is 1.5")
})

test_that("require_custom() validates fn argument", {
  expect_error(
    restrict("x") |> require_custom(label = "test", fn = "not a function"),
    "must be a function"
  )
})
