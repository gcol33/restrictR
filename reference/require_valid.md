# Include Another Validator's Steps

Splices the steps of `validator` into `restriction`, so two
independently defined validators combine into one. Splicing happens when
the validator is built: [`print()`](https://rdrr.io/r/base/print.html)
shows one flat list of steps and there is no nesting at run time.

## Usage

``` r
require_valid(restriction, validator)
```

## Arguments

- restriction:

  a `restriction` object.

- validator:

  a `restriction` object whose steps are appended.

## Value

The modified `restriction` object.

## Details

If `validator` allows `NULL` (see
[`allow_null()`](https://gillescolling.com/restrictR/reference/allow_null.md)),
its steps are skipped for a `NULL` value and the combined validator does
not itself become `NULL`-tolerant.

## See also

Other composition:
[`allow_null()`](https://gillescolling.com/restrictR/reference/allow_null.md),
[`require_any()`](https://gillescolling.com/restrictR/reference/require_any.md),
[`require_col()`](https://gillescolling.com/restrictR/reference/require_col.md),
[`require_each()`](https://gillescolling.com/restrictR/reference/require_each.md),
[`require_fields()`](https://gillescolling.com/restrictR/reference/require_fields.md)

## Examples

``` r
id_v <- restrict("id") |> require_integer(no_na = TRUE)
pos_v <- restrict("x") |> require_positive(strict = TRUE)
restrict("id") |> require_valid(id_v) |> require_valid(pos_v)
#> <restriction id>
#>   1. must be whole number (no NA)
#>   2. must be positive
```
