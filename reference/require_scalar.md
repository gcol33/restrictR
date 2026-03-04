# Require Scalar Value

Validates that the value has length 1. Rejects `NULL`, zero-length
vectors, and vectors with more than one element.

## Usage

``` r
require_scalar(restriction)
```

## Arguments

- restriction:

  a `restriction` object.

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
[`require_nrow_min()`](https://gillescolling.com/restrictR/reference/require_nrow_min.md)
