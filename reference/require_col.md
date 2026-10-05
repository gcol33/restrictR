# Validate a Data Frame Column with a Validator

Lifts any validator onto one column of a data.frame. Errors keep the
column path (e.g. `newdata$age: must be in [0, 120]`), so one set of
steps serves both a standalone argument and a column.

## Usage

``` r
require_col(restriction, col, validator)
```

## Arguments

- restriction:

  a `restriction` object.

- col:

  character(1) column name.

- validator:

  a `restriction` object applied to the column.

## Value

The modified `restriction` object.

## Details

The value must be a data.frame containing `col`, unless `validator`
allows `NULL` (see
[`allow_null()`](https://gillescolling.com/restrictR/reference/allow_null.md)),
in which case a missing column passes. Context passed to the outer
validator is visible to formula steps in `validator`. With
`.on_fail = "all"` each inner failure is reported on its own.

## See also

Other composition:
[`allow_null()`](https://gillescolling.com/restrictR/reference/allow_null.md),
[`require_any()`](https://gillescolling.com/restrictR/reference/require_any.md),
[`require_each()`](https://gillescolling.com/restrictR/reference/require_each.md),
[`require_fields()`](https://gillescolling.com/restrictR/reference/require_fields.md),
[`require_valid()`](https://gillescolling.com/restrictR/reference/require_valid.md)

## Examples

``` r
age <- restrict("age") |>
  require_integer(no_na = TRUE) |>
  require_between(0, 120)

newdata_v <- restrict("newdata") |>
  require_df() |>
  require_col("age", age) |>
  require_col("sex", restrict("sex") |> require_one_of(c("f", "m")))

newdata_v(data.frame(age = 30L, sex = "f"))
validation_errors(newdata_v, data.frame(age = 130L, sex = "x"))
#> [1] "newdata$age: must be in [0, 120]\n  Found: 130"           
#> [2] "newdata$sex: must be one of: \"f\", \"m\"\n  Found: \"x\""
```
