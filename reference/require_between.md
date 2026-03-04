# Require Value in Range

Validates that all elements of a numeric value fall within a specified
range.

## Usage

``` r
require_between(
  restriction,
  lower = -Inf,
  upper = Inf,
  exclusive_lower = FALSE,
  exclusive_upper = FALSE
)
```

## Arguments

- restriction:

  a `restriction` object.

- lower:

  numeric(1) lower bound (default `-Inf`).

- upper:

  numeric(1) upper bound (default `Inf`).

- exclusive_lower:

  logical; if `TRUE`, lower bound is exclusive.

- exclusive_upper:

  logical; if `TRUE`, upper bound is exclusive.

## Value

The modified `restriction` object.

## See also

Other value checks:
[`require_one_of()`](https://gillescolling.com/restrictR/reference/require_one_of.md)
