# Require Minimum Number of Rows

Validates that a data.frame has at least `n` rows.

## Usage

``` r
require_nrow_min(restriction, n)
```

## Arguments

- restriction:

  a `restriction` object.

- n:

  integer(1) minimum row count.

## Value

The modified `restriction` object.

## See also

Other structure checks:
[`require_has_cols()`](https://gillescolling.com/restrictR/reference/require_has_cols.md),
[`require_length()`](https://gillescolling.com/restrictR/reference/require_length.md),
[`require_length_matches()`](https://gillescolling.com/restrictR/reference/require_length_matches.md),
[`require_length_max()`](https://gillescolling.com/restrictR/reference/require_length_max.md),
[`require_length_min()`](https://gillescolling.com/restrictR/reference/require_length_min.md),
[`require_named()`](https://gillescolling.com/restrictR/reference/require_named.md),
[`require_nrow_matches()`](https://gillescolling.com/restrictR/reference/require_nrow_matches.md),
[`require_scalar()`](https://gillescolling.com/restrictR/reference/require_scalar.md)
