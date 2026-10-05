# Require Minimum Number of Columns

Validates that a data.frame or matrix has at least `n` columns.

## Usage

``` r
require_ncol_min(restriction, n)
```

## Arguments

- restriction:

  a `restriction` object.

- n:

  integer(1) minimum column count.

## Value

The modified `restriction` object.

## See also

Other structure checks:
[`require_dim()`](https://gillescolling.com/restrictR/reference/require_dim.md),
[`require_has_cols()`](https://gillescolling.com/restrictR/reference/require_has_cols.md),
[`require_length()`](https://gillescolling.com/restrictR/reference/require_length.md),
[`require_length_matches()`](https://gillescolling.com/restrictR/reference/require_length_matches.md),
[`require_length_max()`](https://gillescolling.com/restrictR/reference/require_length_max.md),
[`require_length_min()`](https://gillescolling.com/restrictR/reference/require_length_min.md),
[`require_named()`](https://gillescolling.com/restrictR/reference/require_named.md),
[`require_names()`](https://gillescolling.com/restrictR/reference/require_names.md),
[`require_ncol_matches()`](https://gillescolling.com/restrictR/reference/require_ncol_matches.md),
[`require_nrow_matches()`](https://gillescolling.com/restrictR/reference/require_nrow_matches.md),
[`require_nrow_min()`](https://gillescolling.com/restrictR/reference/require_nrow_min.md),
[`require_scalar()`](https://gillescolling.com/restrictR/reference/require_scalar.md),
[`require_sorted()`](https://gillescolling.com/restrictR/reference/require_sorted.md),
[`require_unique_names()`](https://gillescolling.com/restrictR/reference/require_unique_names.md)
