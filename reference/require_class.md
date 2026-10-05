# Require a Specific Class

Validates that the value belongs to a given class. One verb covers the
types without a dedicated check, including `factor`, `Date`, `POSIXct`,
`list`, `matrix`, `environment`, and fitted-model objects such as `lm`.

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

## Details

A matrix is `require_class("matrix")`
([`inherits()`](https://rdrr.io/r/base/class.html) is `TRUE` for
matrices since R 4.0) and an environment is
`require_class("environment")`; neither needs a dedicated step. Use
[`require_dim()`](https://gillescolling.com/restrictR/reference/require_dim.md)
for the shape.

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
restrict("m") |> require_class("matrix") |> require_dim(c(NA, 3))
#> <restriction m>
#>   1. must be of class "matrix"
#>   2. must have dim (any, 3)
```
