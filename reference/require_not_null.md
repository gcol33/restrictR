# Require Non-NULL Value

Validates that the value is not `NULL`. Place this step first in the
pipeline when `NULL` is a possible input.

## Usage

``` r
require_not_null(restriction)
```

## Arguments

- restriction:

  a `restriction` object.

## Value

The modified `restriction` object.

## See also

Other missingness checks:
[`require_finite()`](https://gillescolling.com/restrictR/reference/require_finite.md),
[`require_no_na()`](https://gillescolling.com/restrictR/reference/require_no_na.md)
