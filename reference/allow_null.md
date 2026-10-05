# Allow NULL

Marks a validator as accepting `NULL`: a `NULL` value passes without
running any step, and every other value is validated by all steps as
usual. Use it for optional arguments such as `weights = NULL`.

## Usage

``` r
allow_null(restriction)
```

## Arguments

- restriction:

  a `restriction` object.

## Value

The modified `restriction` object.

## Details

The marker is order-independent: it can sit anywhere in the pipe. A
`NULL` value returns before the context check, so context a step needs
(e.g. `data` in `require_length_matches(~ nrow(data))`) is not required
when the value is `NULL`. A validator that allows `NULL` also accepts a
`NULL` (or absent) element when it is lifted with
[`require_col()`](https://gillescolling.com/restrictR/reference/require_col.md),
[`require_each()`](https://gillescolling.com/restrictR/reference/require_each.md),
[`require_fields()`](https://gillescolling.com/restrictR/reference/require_fields.md)
or
[`require_valid()`](https://gillescolling.com/restrictR/reference/require_valid.md).

## See also

Other composition:
[`require_any()`](https://gillescolling.com/restrictR/reference/require_any.md),
[`require_col()`](https://gillescolling.com/restrictR/reference/require_col.md),
[`require_each()`](https://gillescolling.com/restrictR/reference/require_each.md),
[`require_fields()`](https://gillescolling.com/restrictR/reference/require_fields.md),
[`require_valid()`](https://gillescolling.com/restrictR/reference/require_valid.md)

## Examples

``` r
weights_v <- restrict("weights") |>
  require_numeric(no_na = TRUE) |>
  require_positive() |>
  allow_null()
weights_v(NULL)         # passes
weights_v(c(1, 2))      # passes
is_valid(weights_v, -1) # FALSE
#> [1] FALSE
```
