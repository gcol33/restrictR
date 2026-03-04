# Require Specific Columns

Validates that a data.frame contains all specified columns.

## Usage

``` r
require_has_cols(restriction, cols)
```

## Arguments

- restriction:

  a `restriction` object.

- cols:

  character vector of required column names.

## Value

The modified `restriction` object.

## See also

Other structure checks:
[`require_length()`](https://gillescolling.com/restrictR/reference/require_length.md),
[`require_length_matches()`](https://gillescolling.com/restrictR/reference/require_length_matches.md),
[`require_length_max()`](https://gillescolling.com/restrictR/reference/require_length_max.md),
[`require_length_min()`](https://gillescolling.com/restrictR/reference/require_length_min.md),
[`require_nrow_matches()`](https://gillescolling.com/restrictR/reference/require_nrow_matches.md),
[`require_nrow_min()`](https://gillescolling.com/restrictR/reference/require_nrow_min.md)
