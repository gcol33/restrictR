# Convert a Validator to Plain Text

Produces a single-line text summary suitable for roxygen `@param`
documentation. Use with inline R code in roxygen:
`` `r as_contract_text(validator)` ``.

## Usage

``` r
as_contract_text(x)
```

## Arguments

- x:

  a `restriction` object.

## Value

A character(1) string describing the validation contract.

## See also

Other core:
[`as_contract_block()`](https://gillescolling.com/restrictR/reference/as_contract_block.md),
[`require_custom()`](https://gillescolling.com/restrictR/reference/require_custom.md),
[`restrict()`](https://gillescolling.com/restrictR/reference/restrict.md)

## Examples

``` r
v <- restrict("x") |> require_numeric(no_na = TRUE) |> require_length(1L)
as_contract_text(v)
#> [1] "Must be numeric, no NA. must have length 1."
```
