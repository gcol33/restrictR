# Require Positive Values

Validates that all elements are positive. By default uses `>= 0`
(non-negative); set `strict = TRUE` for `> 0`.

## Usage

``` r
require_positive(restriction, strict = FALSE)
```

## Arguments

- restriction:

  a `restriction` object.

- strict:

  logical; if `TRUE`, requires `> 0`. If `FALSE` (default), requires
  `>= 0`.

## Value

The modified `restriction` object.

## Details

Non-numeric input fails with a type error. `NA` elements are skipped;
chain
[`require_no_na()`](https://gillescolling.com/restrictR/reference/require_no_na.md)
to reject them.

## See also

Other value checks:
[`require_between()`](https://gillescolling.com/restrictR/reference/require_between.md),
[`require_negative()`](https://gillescolling.com/restrictR/reference/require_negative.md),
[`require_one_of()`](https://gillescolling.com/restrictR/reference/require_one_of.md),
[`require_unique()`](https://gillescolling.com/restrictR/reference/require_unique.md)
