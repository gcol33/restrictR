# Require Row Count Matching an Expression

Validates that `nrow(value)` equals the result of evaluating a formula.
The formula is evaluated using only explicitly passed context arguments,
plus `.value` (the validated value) and `.name` (the restriction name).

## Usage

``` r
require_nrow_matches(restriction, formula)
```

## Arguments

- restriction:

  a `restriction` object.

- formula:

  a one-sided formula (e.g. `~ nrow(reference)`).

## Value

The modified `restriction` object.

## See also

Other structure checks:
[`require_has_cols()`](https://gillescolling.com/restrictR/reference/require_has_cols.md),
[`require_length()`](https://gillescolling.com/restrictR/reference/require_length.md),
[`require_length_matches()`](https://gillescolling.com/restrictR/reference/require_length_matches.md),
[`require_length_max()`](https://gillescolling.com/restrictR/reference/require_length_max.md),
[`require_length_min()`](https://gillescolling.com/restrictR/reference/require_length_min.md),
[`require_named()`](https://gillescolling.com/restrictR/reference/require_named.md),
[`require_nrow_min()`](https://gillescolling.com/restrictR/reference/require_nrow_min.md),
[`require_scalar()`](https://gillescolling.com/restrictR/reference/require_scalar.md)
