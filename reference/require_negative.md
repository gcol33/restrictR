# Require Negative Values

Validates that all elements are negative. By default uses `<= 0`
(non-positive); set `strict = TRUE` for `< 0`.

## Usage

``` r
require_negative(restriction, strict = FALSE)
```

## Arguments

- restriction:

  a `restriction` object.

- strict:

  logical; if `TRUE`, requires `< 0`. If `FALSE` (default), requires
  `<= 0`.

## Value

The modified `restriction` object.

## See also

Other value checks:
[`require_between()`](https://gillescolling.com/restrictR/reference/require_between.md),
[`require_one_of()`](https://gillescolling.com/restrictR/reference/require_one_of.md),
[`require_positive()`](https://gillescolling.com/restrictR/reference/require_positive.md),
[`require_unique()`](https://gillescolling.com/restrictR/reference/require_unique.md)
