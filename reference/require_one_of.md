# Require Value from a Set

Validates that all elements of the value are among the allowed values.

## Usage

``` r
require_one_of(restriction, values)
```

## Arguments

- restriction:

  a `restriction` object.

- values:

  vector of allowed values.

## Value

The modified `restriction` object.

## Details

`NA` elements are skipped; chain
[`require_no_na()`](https://gillescolling.com/restrictR/reference/require_no_na.md)
to reject them.

## See also

Other value checks:
[`require_between()`](https://gillescolling.com/restrictR/reference/require_between.md),
[`require_negative()`](https://gillescolling.com/restrictR/reference/require_negative.md),
[`require_positive()`](https://gillescolling.com/restrictR/reference/require_positive.md),
[`require_unique()`](https://gillescolling.com/restrictR/reference/require_unique.md)
