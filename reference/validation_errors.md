# Collect Validation Errors Without Throwing

Runs a validator against a value and returns the validation messages
instead of raising an error. Every step is checked (as with
`.on_fail = "all"`), so all violations are reported in one pass.

## Usage

``` r
validation_errors(validator, value, ...)
```

## Arguments

- validator:

  a `restriction` object created by
  [`restrict()`](https://gillescolling.com/restrictR/reference/restrict.md).

- value:

  the value to validate.

- ...:

  context arguments passed to the validator (e.g. `newdata = df`), the
  same as a direct validator call.

## Value

A character vector of failure messages, or `character(0)` if the value
satisfies every step. Each element is the full path-aware message for
one failing step.

## Details

Only validation failures are caught. A usage error, such as a missing
context dependency declared by a formula step, still propagates so the
calling mistake is not silently reported as invalid data.

## See also

[`is_valid()`](https://gillescolling.com/restrictR/reference/is_valid.md)
for a logical predicate.

Other core:
[`as_contract_block()`](https://gillescolling.com/restrictR/reference/as_contract_block.md),
[`as_contract_text()`](https://gillescolling.com/restrictR/reference/as_contract_text.md),
[`fail()`](https://gillescolling.com/restrictR/reference/fail.md),
[`is_valid()`](https://gillescolling.com/restrictR/reference/is_valid.md),
[`require_custom()`](https://gillescolling.com/restrictR/reference/require_custom.md),
[`restrict()`](https://gillescolling.com/restrictR/reference/restrict.md)

## Examples

``` r
v <- restrict("x") |> require_numeric() |> require_positive()
validation_errors(v, 5)       # character(0)
#> character(0)
validation_errors(v, c(-1))   # one message
#> [1] "x: must be non-negative\n  Found: -1"
```
