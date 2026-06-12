# Require a Specific Class

Validates that the value belongs to a given class. One verb covers the
types without a dedicated check, including `factor`, `Date`, `POSIXct`,
`list`, and fitted-model objects such as `lm`.

## Usage

``` r
require_class(restriction, class, exact = FALSE)
```

## Arguments

- restriction:

  a `restriction` object.

- class:

  character(1) class name to require.

- exact:

  logical; if `TRUE`, requires `class(value)[1]` to equal `class`
  exactly. If `FALSE` (default), tests inheritance with
  [`inherits()`](https://rdrr.io/r/base/class.html), so a subclass
  passes.

## Value

The modified `restriction` object.

## See also

Other type checks:
[`require_character()`](https://gillescolling.com/restrictR/reference/require_character.md),
[`require_df()`](https://gillescolling.com/restrictR/reference/require_df.md),
[`require_integer()`](https://gillescolling.com/restrictR/reference/require_integer.md),
[`require_logical()`](https://gillescolling.com/restrictR/reference/require_logical.md),
[`require_numeric()`](https://gillescolling.com/restrictR/reference/require_numeric.md)

## Examples

``` r
restrict("d") |> require_class("Date")
#> <restriction d>
#>   1. must be of class "Date"
restrict("f") |> require_class("factor")
#> <restriction f>
#>   1. must be of class "factor"
restrict("model") |> require_class("lm")
#> <restriction model>
#>   1. must be of class "lm"
```
