# Require Character Type

Validates that the value is character. Optionally checks for NA values.

## Usage

``` r
require_character(restriction, no_na = FALSE)
```

## Arguments

- restriction:

  a `restriction` object.

- no_na:

  logical; if `TRUE`, rejects NA values.

## Value

The modified `restriction` object.

## See also

Other type checks:
[`require_df()`](https://gillescolling.com/restrictR/reference/require_df.md),
[`require_integer()`](https://gillescolling.com/restrictR/reference/require_integer.md),
[`require_logical()`](https://gillescolling.com/restrictR/reference/require_logical.md),
[`require_numeric()`](https://gillescolling.com/restrictR/reference/require_numeric.md)
