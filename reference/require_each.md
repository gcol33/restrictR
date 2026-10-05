# Validate Every Element of a List

Applies a validator to each element of a list: list arguments,
list-columns, collected `...`, configuration lists. Errors carry the
element path, `layers[[2]]` for unnamed elements and `layers$key` for
named ones.

## Usage

``` r
require_each(restriction, validator)
```

## Arguments

- restriction:

  a `restriction` object.

- validator:

  a `restriction` object applied to every element.

## Value

The modified `restriction` object.

## Details

The value must be a list. An empty list passes. In fail-first mode the
first invalid element stops the check; with `.on_fail = "all"` every
failing element is reported.

## See also

Other composition:
[`allow_null()`](https://gillescolling.com/restrictR/reference/allow_null.md),
[`require_any()`](https://gillescolling.com/restrictR/reference/require_any.md),
[`require_col()`](https://gillescolling.com/restrictR/reference/require_col.md),
[`require_fields()`](https://gillescolling.com/restrictR/reference/require_fields.md),
[`require_valid()`](https://gillescolling.com/restrictR/reference/require_valid.md)

## Examples

``` r
layer <- restrict("layer") |> require_class("data.frame")
layers_v <- restrict("layers") |> require_class("list") |> require_each(layer)
layers_v(list(data.frame(a = 1), data.frame(b = 2)))
try(layers_v(list(data.frame(a = 1), "oops")))
#> Error : layers[[2]]: must be of class "data.frame", got character
```
