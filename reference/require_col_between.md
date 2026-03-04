# Require Column Values in Range

Validates that all values in a column fall within a specified range.

## Usage

``` r
require_col_between(
  restriction,
  col,
  lower = -Inf,
  upper = Inf,
  exclusive_lower = FALSE,
  exclusive_upper = FALSE
)
```

## Arguments

- restriction:

  a `restriction` object.

- col:

  character(1) column name.

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

Other column checks:
[`require_col_character()`](https://gillescolling.com/restrictR/reference/require_col_character.md),
[`require_col_numeric()`](https://gillescolling.com/restrictR/reference/require_col_numeric.md),
[`require_col_one_of()`](https://gillescolling.com/restrictR/reference/require_col_one_of.md)
