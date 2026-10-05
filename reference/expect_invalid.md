# Expect a Value to Fail a Validator

testthat expectation that the value violates the validator, optionally
with a message matching a regular expression.

## Usage

``` r
expect_invalid(validator, value, ..., regexp = NULL)
```

## Arguments

- validator:

  a `restriction` object created by
  [`restrict()`](https://gillescolling.com/restrictR/reference/restrict.md).

- value:

  the value to validate.

- ...:

  context arguments passed to the validator (e.g. `newdata = df`).

- regexp:

  optional regular expression the failure messages must match. All
  messages are joined with newlines before matching.

## Value

`value`, invisibly.

## Details

Requires the testthat package, which is checked when the expectation
runs. A missing context dependency is a usage error and propagates.

## See also

[`expect_valid()`](https://gillescolling.com/restrictR/reference/expect_valid.md)

Other testthat expectations:
[`expect_valid()`](https://gillescolling.com/restrictR/reference/expect_valid.md)

## Examples

``` r
if (requireNamespace("testthat", quietly = TRUE)) {
  v <- restrict("x") |> require_numeric()
  expect_invalid(v, "a", regexp = "must be numeric")
}
```
