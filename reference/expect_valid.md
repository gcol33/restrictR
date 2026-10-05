# Expect a Value to Pass a Validator

testthat expectation that reports the validator's own messages when the
value is invalid, so a failing test shows `newdata$x2: must be numeric`
rather than a generic "error thrown".

## Usage

``` r
expect_valid(validator, value, ...)
```

## Arguments

- validator:

  a `restriction` object created by
  [`restrict()`](https://gillescolling.com/restrictR/reference/restrict.md).

- value:

  the value to validate.

- ...:

  context arguments passed to the validator (e.g. `newdata = df`).

## Value

`value`, invisibly.

## Details

Requires the testthat package, which is checked when the expectation
runs. Every violation is reported, as with
[`validation_errors()`](https://gillescolling.com/restrictR/reference/validation_errors.md).

## See also

[`expect_invalid()`](https://gillescolling.com/restrictR/reference/expect_invalid.md)

Other testthat expectations:
[`expect_invalid()`](https://gillescolling.com/restrictR/reference/expect_invalid.md)

## Examples

``` r
if (requireNamespace("testthat", quietly = TRUE)) {
  v <- restrict("x") |> require_numeric()
  expect_valid(v, 1:3)
}
```
