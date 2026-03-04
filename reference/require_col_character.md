# Require Character Column

Validates that a specific column in a data.frame is character. Produces
path-aware error messages.

## Usage

``` r
require_col_character(restriction, col, no_na = FALSE)
```

## Arguments

- restriction:

  a `restriction` object.

- col:

  character(1) column name.

- no_na:

  logical; if `TRUE`, rejects NA values in the column.

## Value

The modified `restriction` object.

## See also

Other column checks:
[`require_col_between()`](https://gillescolling.com/restrictR/reference/require_col_between.md),
[`require_col_numeric()`](https://gillescolling.com/restrictR/reference/require_col_numeric.md),
[`require_col_one_of()`](https://gillescolling.com/restrictR/reference/require_col_one_of.md)
