# Convert a Validator to a Multi-Line Block

Produces a multi-line text summary suitable for roxygen `@details`
documentation. Each step appears on its own line as a bullet point.

## Usage

``` r
as_contract_block(x)
```

## Arguments

- x:

  a `restriction` object.

## Value

A character(1) string with one step per line.

## See also

Other core:
[`as_contract_text()`](https://gillescolling.com/restrictR/reference/as_contract_text.md),
[`require_custom()`](https://gillescolling.com/restrictR/reference/require_custom.md),
[`restrict()`](https://gillescolling.com/restrictR/reference/restrict.md)

## Examples

``` r
v <- restrict("x") |> require_numeric(no_na = TRUE) |> require_length(1L)
as_contract_block(v)
#> [1] "- must be numeric, no NA\n- must have length 1"
```
