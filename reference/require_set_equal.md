# Require the Same Set of Values

Validates that the value and `values` hold the same distinct elements.
Order and duplicates are ignored.

## Usage

``` r
require_set_equal(restriction, values)
```

## Arguments

- restriction:

  a `restriction` object.

- values:

  vector of values that must be present.

## Value

The modified `restriction` object.

## See also

Other value checks:
[`require_between()`](https://gillescolling.com/restrictR/reference/require_between.md),
[`require_contains()`](https://gillescolling.com/restrictR/reference/require_contains.md),
[`require_disjoint()`](https://gillescolling.com/restrictR/reference/require_disjoint.md),
[`require_levels()`](https://gillescolling.com/restrictR/reference/require_levels.md),
[`require_negative()`](https://gillescolling.com/restrictR/reference/require_negative.md),
[`require_one_of()`](https://gillescolling.com/restrictR/reference/require_one_of.md),
[`require_positive()`](https://gillescolling.com/restrictR/reference/require_positive.md),
[`require_unique()`](https://gillescolling.com/restrictR/reference/require_unique.md)
