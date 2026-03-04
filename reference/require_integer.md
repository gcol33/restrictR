# Require Integer Values

Validates that the value contains whole numbers. By default accepts both
`integer` and `numeric` types as long as all values are whole
(`x == floor(x)`). Set `strict = TRUE` to require the R `integer` type.

## Usage

``` r
require_integer(restriction, no_na = FALSE, strict = FALSE)
```

## Arguments

- restriction:

  a `restriction` object.

- no_na:

  logical; if `TRUE`, rejects NA values.

- strict:

  logical; if `TRUE`, requires R `integer` type. If `FALSE` (default),
  accepts any numeric value that is a whole number.

## Value

The modified `restriction` object.

## See also

Other type checks:
[`require_character()`](https://gillescolling.com/restrictR/reference/require_character.md),
[`require_df()`](https://gillescolling.com/restrictR/reference/require_df.md),
[`require_logical()`](https://gillescolling.com/restrictR/reference/require_logical.md),
[`require_numeric()`](https://gillescolling.com/restrictR/reference/require_numeric.md)
