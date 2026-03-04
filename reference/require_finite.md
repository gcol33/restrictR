# Require Finite Values

Validates that a numeric value contains no `Inf`, `-Inf`, or `NaN`
values. Does not check for `NA` (use
[`require_no_na()`](https://gillescolling.com/restrictR/reference/require_no_na.md)
for that).

## Usage

``` r
require_finite(restriction)
```

## Arguments

- restriction:

  a `restriction` object.

## Value

The modified `restriction` object.

## See also

Other missingness checks:
[`require_no_na()`](https://gillescolling.com/restrictR/reference/require_no_na.md)
