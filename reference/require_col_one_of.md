# Require Column Values from a Set

Validates that all values in a column are among the allowed values.

## Usage

``` r
require_col_one_of(restriction, col, values)
```

## Arguments

- restriction:

  a `restriction` object.

- col:

  character(1) column name.

- values:

  vector of allowed values.

## Value

The modified `restriction` object.

## See also

Other column checks:
[`require_col_between()`](https://gillescolling.com/restrictR/reference/require_col_between.md),
[`require_col_character()`](https://gillescolling.com/restrictR/reference/require_col_character.md),
[`require_col_numeric()`](https://gillescolling.com/restrictR/reference/require_col_numeric.md)
