# List the Steps of a Validator

Returns the steps of a validator as a data.frame, one row per step in
the order they run, for introspection and tooling. It shows the same
steps as [`print()`](https://rdrr.io/r/base/print.html).

## Usage

``` r
steps(x)
```

## Arguments

- x:

  a `restriction` object.

## Value

A data.frame with the columns `step` (position), `label` (the
description shown by [`print()`](https://rdrr.io/r/base/print.html)),
`deps` (list column: context names the step needs) and `fields` (list
column: the parameters the step was built with, `NULL` when it has
none).

## See also

Other core:
[`as_contract_block()`](https://gillescolling.com/restrictR/reference/as_contract_block.md),
[`as_contract_text()`](https://gillescolling.com/restrictR/reference/as_contract_text.md),
[`fail()`](https://gillescolling.com/restrictR/reference/fail.md),
[`is_valid()`](https://gillescolling.com/restrictR/reference/is_valid.md),
[`require_custom()`](https://gillescolling.com/restrictR/reference/require_custom.md),
[`restrict()`](https://gillescolling.com/restrictR/reference/restrict.md),
[`validation_errors()`](https://gillescolling.com/restrictR/reference/validation_errors.md)

## Examples

``` r
v <- restrict("x") |> require_numeric(no_na = TRUE) |> require_between(0, 1)
steps(v)
#>   step                  label deps      fields
#> 1    1 must be numeric, no NA      TRUE, FALSE
#> 2    2      must be in [0, 1]       0, 1, 0, 0
steps(v)$fields[[2]]
#> $lower
#> [1] 0
#> 
#> $upper
#> [1] 1
#> 
#> $exclusive_lower
#> [1] FALSE
#> 
#> $exclusive_upper
#> [1] FALSE
#> 
```
