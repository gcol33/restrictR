# Require Sorted Values

Validates that the elements are in order and reports the position of the
first element that breaks it.

## Usage

``` r
require_sorted(restriction, decreasing = FALSE, strict = FALSE)
```

## Arguments

- restriction:

  a `restriction` object.

- decreasing:

  logical; if `TRUE`, requires decreasing order.

- strict:

  logical; if `TRUE`, equal neighbours are a violation.

## Value

The modified `restriction` object.

## Details

Works on numeric, character, logical, `Date`, `POSIXct`, `difftime` and
ordered-factor values; other input fails with a type error. Character
values compare in the collation order of the session locale. `NA`
elements are skipped; chain
[`require_no_na()`](https://gillescolling.com/restrictR/reference/require_no_na.md)
to reject them.

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
[`require_ncol_min()`](https://gillescolling.com/restrictR/reference/require_ncol_min.md),
[`require_nrow_matches()`](https://gillescolling.com/restrictR/reference/require_nrow_matches.md),
[`require_nrow_min()`](https://gillescolling.com/restrictR/reference/require_nrow_min.md),
[`require_scalar()`](https://gillescolling.com/restrictR/reference/require_scalar.md),
[`require_unique_names()`](https://gillescolling.com/restrictR/reference/require_unique_names.md)

## Examples

``` r
ts_v <- restrict("time") |> require_sorted(strict = TRUE)
ts_v(c(1, 2, 5))
try(ts_v(c(1, 3, 2)))
#> Error : time: must be strictly increasing order
#>   Found: 2 after 3
#>   At: 3
```
