# Require Numeric Type

Validates that the value is numeric. Optionally checks for NA and
non-finite values.

## Usage

``` r
require_numeric(restriction, no_na = FALSE, finite = FALSE)
```

## Arguments

- restriction:

  a `restriction` object.

- no_na:

  logical; if `TRUE`, rejects NA values.

- finite:

  logical; if `TRUE`, rejects `Inf`/`-Inf`/`NaN`.

## Value

The modified `restriction` object.

## See also

Other type checks:
[`require_character()`](https://gillescolling.com/restrictR/reference/require_character.md),
[`require_df()`](https://gillescolling.com/restrictR/reference/require_df.md),
[`require_integer()`](https://gillescolling.com/restrictR/reference/require_integer.md),
[`require_logical()`](https://gillescolling.com/restrictR/reference/require_logical.md)
