# Validate Named Fields of a List

Applies a different validator to each named element of a list, for
heterogeneous configuration or argument lists. Errors carry the field
path, e.g. `opts$alpha`.

## Usage

``` r
require_fields(restriction, ..., .required = TRUE)
```

## Arguments

- restriction:

  a `restriction` object.

- ...:

  named `restriction` objects, one per field.

- .required:

  logical; if `TRUE` (default) a missing field is a failure. If `FALSE`,
  a missing field passes. A field whose validator allows `NULL` (see
  [`allow_null()`](https://gillescolling.com/restrictR/reference/allow_null.md))
  may always be missing.

## Value

The modified `restriction` object.

## See also

Other composition:
[`allow_null()`](https://gillescolling.com/restrictR/reference/allow_null.md),
[`require_any()`](https://gillescolling.com/restrictR/reference/require_any.md),
[`require_col()`](https://gillescolling.com/restrictR/reference/require_col.md),
[`require_each()`](https://gillescolling.com/restrictR/reference/require_each.md),
[`require_valid()`](https://gillescolling.com/restrictR/reference/require_valid.md)

## Examples

``` r
opts_v <- restrict("opts") |>
  require_class("list") |>
  require_fields(
    alpha = restrict("alpha") |> require_numeric() |> require_between(0, 1),
    label = restrict("label") |> require_character()
  )
opts_v(list(alpha = 0.05, label = "a"))
validation_errors(opts_v, list(alpha = 2))
#> [1] "opts$alpha: must be in [0, 1]\n  Found: 2"
#> [2] "opts$label: is required but missing"      
```
