# Require Numeric Column

Validates that a specific column in a data.frame is numeric. Produces
path-aware error messages (e.g. `newdata$x2: must be numeric`).

## Usage

``` r
require_col_numeric(restriction, col, no_na = FALSE, finite = FALSE)
```

## Arguments

- restriction:

  a `restriction` object.

- col:

  character(1) column name.

- no_na:

  logical; if `TRUE`, rejects NA values in the column.

- finite:

  logical; if `TRUE`, rejects non-finite values in the column.

## Value

The modified `restriction` object.

## See also

Other column checks:
[`require_col_between()`](https://gillescolling.com/restrictR/reference/require_col_between.md),
[`require_col_character()`](https://gillescolling.com/restrictR/reference/require_col_character.md),
[`require_col_one_of()`](https://gillescolling.com/restrictR/reference/require_col_one_of.md)
