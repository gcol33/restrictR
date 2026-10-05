# Require at Least One of Several Validators

Passes when the value satisfies at least one of the alternative
validators. When none passes, the error lists the first failure of every
alternative.

## Usage

``` r
require_any(restriction, ..., .label = NULL)
```

## Arguments

- restriction:

  a `restriction` object.

- ...:

  `restriction` objects, the alternatives.

- .label:

  optional character(1) description for
  [`print()`](https://rdrr.io/r/base/print.html) and contract text;
  defaults to the alternatives' own labels.

## Value

The modified `restriction` object.

## Details

Each alternative runs in fail-first mode. Context needed by any
alternative is required from the caller, like for any other step.
Missing context is a usage error, not an alternative failing. In
`.on_fail = "all"` mode the step reports a single failure.

## See also

Other composition:
[`allow_null()`](https://gillescolling.com/restrictR/reference/allow_null.md),
[`require_col()`](https://gillescolling.com/restrictR/reference/require_col.md),
[`require_each()`](https://gillescolling.com/restrictR/reference/require_each.md),
[`require_fields()`](https://gillescolling.com/restrictR/reference/require_fields.md),
[`require_valid()`](https://gillescolling.com/restrictR/reference/require_valid.md)

## Examples

``` r
num_or_df <- restrict("x") |>
  require_any(
    restrict("x") |> require_numeric(),
    restrict("x") |> require_df() |> require_has_cols("value")
  )
num_or_df(1:3)
num_or_df(data.frame(value = 1))
try(num_or_df("a"))
#> Error : x: must satisfy one of:
#>   - must be numeric, got character
#>   - must be a data.frame, got character
```
