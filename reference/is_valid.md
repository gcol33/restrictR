# Test Whether a Value Satisfies a Validator

Non-throwing predicate: returns `TRUE` when `value` passes every step of
`validator`, `FALSE` otherwise. Use it to branch on validity instead of
wrapping a validator call in
[`tryCatch()`](https://rdrr.io/r/base/conditions.html).

## Usage

``` r
is_valid(validator, value, ...)
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

A length-1 logical.

## Details

Like
[`validation_errors()`](https://gillescolling.com/restrictR/reference/validation_errors.md),
only validation failures are caught; a missing context dependency still
raises so a calling mistake is not mistaken for invalid data.

## See also

[`validation_errors()`](https://gillescolling.com/restrictR/reference/validation_errors.md)
for the failure messages.

Other core:
[`as_contract_block()`](https://gillescolling.com/restrictR/reference/as_contract_block.md),
[`as_contract_text()`](https://gillescolling.com/restrictR/reference/as_contract_text.md),
[`fail()`](https://gillescolling.com/restrictR/reference/fail.md),
[`require_custom()`](https://gillescolling.com/restrictR/reference/require_custom.md),
[`restrict()`](https://gillescolling.com/restrictR/reference/restrict.md),
[`validation_errors()`](https://gillescolling.com/restrictR/reference/validation_errors.md)

## Examples

``` r
v <- restrict("x") |> require_numeric(no_na = TRUE)
is_valid(v, 1:5)        # TRUE
#> [1] TRUE
is_valid(v, c(1, NA))   # FALSE
#> [1] FALSE
```
