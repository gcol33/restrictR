# Require Value from a Set

Validates that all elements of the value are among the allowed values.
For a vector this is the subset test: every element must be one of
`values`.

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
to reject them. Use
[`require_contains()`](https://gillescolling.com/restrictR/reference/require_contains.md)
for the reverse direction (the value must hold all of `values`) and
[`require_set_equal()`](https://gillescolling.com/restrictR/reference/require_set_equal.md)
for both.

## See also

Other value checks:
[`require_between()`](https://gillescolling.com/restrictR/reference/require_between.md),
[`require_contains()`](https://gillescolling.com/restrictR/reference/require_contains.md),
[`require_disjoint()`](https://gillescolling.com/restrictR/reference/require_disjoint.md),
[`require_levels()`](https://gillescolling.com/restrictR/reference/require_levels.md),
[`require_negative()`](https://gillescolling.com/restrictR/reference/require_negative.md),
[`require_positive()`](https://gillescolling.com/restrictR/reference/require_positive.md),
[`require_set_equal()`](https://gillescolling.com/restrictR/reference/require_set_equal.md),
[`require_unique()`](https://gillescolling.com/restrictR/reference/require_unique.md)
