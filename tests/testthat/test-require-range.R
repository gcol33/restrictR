# ---- Range steps over ordered types (#16) ----

test_that("require_between() accepts Date values and bounds", {
  v <- restrict("start") |>
    require_between(as.Date("2020-01-01"), as.Date("2020-12-31"))
  expect_invisible(v(as.Date(c("2020-01-01", "2020-12-31"))))
  expect_error(v(as.Date(c("2020-06-01", "2021-01-01"))),
               "start: must be in \\[2020-01-01, 2020-12-31\\]")
  expect_error(v(as.Date(c("2020-06-01", "2021-01-01"))), "Found: 2021-01-01")
  expect_error(v(as.Date(c("2020-06-01", "2021-01-01"))), "At: 2")
})

test_that("require_between() with one Date bound leaves the other open", {
  lower_only <- restrict("start") |> require_between(lower = as.Date("2020-01-01"))
  expect_invisible(lower_only(as.Date("2030-01-01")))
  expect_error(lower_only(as.Date("2019-01-01")), "must be in \\[2020-01-01, Inf\\]")
  upper_only <- restrict("end") |>
    require_between(upper = as.Date("2020-01-01"), exclusive_upper = TRUE)
  expect_error(upper_only(as.Date("2020-01-01")), "end: must be in")
  expect_invisible(upper_only(as.Date("2019-12-31")))
})

test_that("require_between() skips NA in Date input", {
  v <- restrict("d") |> require_between(as.Date("2020-01-01"))
  expect_invisible(v(c(as.Date("2021-01-01"), NA)))
})

test_that("require_between() handles POSIXct across time zones", {
  lo <- as.POSIXct("2020-01-01 00:00:00", tz = "UTC")
  hi <- as.POSIXct("2020-01-02 00:00:00", tz = "UTC")
  v <- restrict("t") |> require_between(lo, hi)
  expect_invisible(v(as.POSIXct("2020-01-01 12:00:00", tz = "UTC")))
  # 2020-01-02 01:00 in Vienna (UTC+1) is 00:00 UTC, so inside the window
  expect_invisible(v(as.POSIXct("2020-01-02 01:00:00", tz = "Europe/Vienna")))
  expect_error(v(as.POSIXct("2020-01-03 00:00:00", tz = "UTC")), "t: must be in")
})

test_that("require_between() handles difftime with different units", {
  v <- restrict("gap") |>
    require_between(as.difftime(1, units = "hours"), as.difftime(1, units = "days"))
  expect_invisible(v(as.difftime(90, units = "mins")))
  expect_invisible(v(as.difftime(12, units = "hours")))
  expect_error(v(as.difftime(30, units = "mins")), "gap: must be in")
  expect_error(v(as.difftime(2, units = "days")), "gap: must be in")
})

test_that("require_between() handles ordered factors", {
  lv <- c("low", "mid", "high")
  mk <- function(x) factor(x, levels = lv, ordered = TRUE)
  v <- restrict("level") |> require_between(mk("mid"), mk("high"))
  expect_invisible(v(mk(c("mid", "high"))))
  expect_error(v(mk(c("mid", "low"))), "level: must be in \\[mid, high\\]")
  expect_error(v(mk(c("mid", "low"))), "Found: low")
  other <- factor("mid", levels = c("a", "mid"), ordered = TRUE)
  expect_error(v(other), "same levels")
})

test_that("require_between() rejects a value of the wrong kind", {
  dv <- restrict("start") |> require_between(lower = as.Date("2020-01-01"))
  expect_error(dv(5), "start: must be Date, got numeric")
  expect_error(dv("2020-06-01"), "start: must be Date, got character")
  nv <- restrict("x") |> require_between(0, 10)
  expect_error(nv(as.Date("2020-01-01")), "x: must be numeric, got Date")
  expect_error(nv(factor("a")), "must be numeric, got factor")
  tv <- restrict("t") |> require_between(as.POSIXct("2020-01-01", tz = "UTC"))
  expect_error(tv(as.Date("2020-01-01")), "t: must be POSIXct, got Date")
})

test_that("require_between() rejects mixed or invalid bounds when built", {
  expect_error(require_between(restrict("x"), as.Date("2020-01-01"), 5),
               "same kind")
  expect_error(require_between(restrict("x"), "a", "b"), "range bounds")
  expect_error(require_between(restrict("x"), NA_real_, 1), "range bounds")
})

test_that("unbounded ranges accept any ordered kind", {
  v <- restrict("d") |> require_between()
  expect_invisible(v(as.Date("2020-01-01")))
  expect_invisible(v(c(1, 2)))
  expect_error(v("a"), "must be numeric, got character")
})

test_that("require_positive() and require_negative() stay numeric-only", {
  expect_error((restrict("d") |> require_positive())(as.Date("2020-01-01")),
               "must be numeric, got Date")
  expect_error((restrict("d") |> require_negative())(Sys.time()),
               "must be numeric, got POSIXct")
})

test_that("require_col() carries Date ranges to columns", {
  v <- restrict("df") |>
    require_df() |>
    require_col("when", restrict("when") |>
                  require_between(as.Date("2020-01-01"), as.Date("2020-12-31")))
  expect_invisible(v(data.frame(when = as.Date("2020-06-01"))))
  expect_error(v(data.frame(when = as.Date("2022-06-01"))), "df\\$when: must be in")
})
