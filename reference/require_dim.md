# Require Exact Dimensions

Validates `dim(value)` of a data.frame, matrix or array. `NA` entries in
`dims` match any extent.

## Usage

``` r
require_dim(restriction, dims)
```

## Arguments

- restriction:

  a `restriction` object.

- dims:

  numeric vector of required extents, one per dimension; `NA` leaves
  that dimension unchecked.

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
[`require_names()`](https://gillescolling.com/restrictR/reference/require_names.md),
[`require_ncol_matches()`](https://gillescolling.com/restrictR/reference/require_ncol_matches.md),
[`require_ncol_min()`](https://gillescolling.com/restrictR/reference/require_ncol_min.md),
[`require_nrow_matches()`](https://gillescolling.com/restrictR/reference/require_nrow_matches.md),
[`require_nrow_min()`](https://gillescolling.com/restrictR/reference/require_nrow_min.md),
[`require_scalar()`](https://gillescolling.com/restrictR/reference/require_scalar.md),
[`require_sorted()`](https://gillescolling.com/restrictR/reference/require_sorted.md),
[`require_unique_names()`](https://gillescolling.com/restrictR/reference/require_unique_names.md)

## Examples

``` r
design <- restrict("X") |> require_class("matrix") |> require_dim(c(NA, 3))
design(matrix(0, 10, 3))
try(design(matrix(0, 10, 2)))
#> Error : X: must have dim (any, 3)
#>   Found: dim (10, 2)
```
