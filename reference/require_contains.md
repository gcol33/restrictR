# Require All of a Set of Values

Validates that the value contains every element of `values`. Extra
elements are allowed.

## Usage

``` r
require_contains(restriction, values)
```

## Arguments

- restriction:

  a `restriction` object.

- values:

  vector of values that must be present.

## Value

The modified `restriction` object.

## Details

`NA` elements of the validated value are ignored. A factor is compared
by its labels. For the opposite direction (every element must be one of
`values`) use
[`require_one_of()`](https://gillescolling.com/restrictR/reference/require_one_of.md).

## See also

Other value checks:
[`require_between()`](https://gillescolling.com/restrictR/reference/require_between.md),
[`require_disjoint()`](https://gillescolling.com/restrictR/reference/require_disjoint.md),
[`require_levels()`](https://gillescolling.com/restrictR/reference/require_levels.md),
[`require_negative()`](https://gillescolling.com/restrictR/reference/require_negative.md),
[`require_one_of()`](https://gillescolling.com/restrictR/reference/require_one_of.md),
[`require_positive()`](https://gillescolling.com/restrictR/reference/require_positive.md),
[`require_set_equal()`](https://gillescolling.com/restrictR/reference/require_set_equal.md),
[`require_unique()`](https://gillescolling.com/restrictR/reference/require_unique.md)
