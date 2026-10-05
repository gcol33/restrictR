# Require Names

Compares `names(value)` with a reference. One verb covers "exactly these
names in this order", "only allowed names" and "at least these names".

## Usage

``` r
require_names(
  restriction,
  names,
  mode = c("identical", "subset", "superset", "permutation")
)
```

## Arguments

- restriction:

  a `restriction` object.

- names:

  character vector of reference names.

- mode:

  how the observed names relate to `names`:

  - `"identical"`: the same names in the same order;

  - `"subset"`: every observed name is in `names` (no unexpected names);

  - `"superset"`: every name in `names` is present (nothing missing);

  - `"permutation"`: the same names in any order, each occurring as
    often.

## Value

The modified `restriction` object.

## Details

A value without names has no names: it fails every mode except
`"subset"`. The failure lists the missing and the unexpected names.

## See also

Other structure checks:
[`require_dim()`](https://gillescolling.com/restrictR/reference/require_dim.md),
[`require_has_cols()`](https://gillescolling.com/restrictR/reference/require_has_cols.md),
[`require_length()`](https://gillescolling.com/restrictR/reference/require_length.md),
[`require_length_matches()`](https://gillescolling.com/restrictR/reference/require_length_matches.md),
[`require_length_max()`](https://gillescolling.com/restrictR/reference/require_length_max.md),
[`require_length_min()`](https://gillescolling.com/restrictR/reference/require_length_min.md),
[`require_named()`](https://gillescolling.com/restrictR/reference/require_named.md),
[`require_ncol_matches()`](https://gillescolling.com/restrictR/reference/require_ncol_matches.md),
[`require_ncol_min()`](https://gillescolling.com/restrictR/reference/require_ncol_min.md),
[`require_nrow_matches()`](https://gillescolling.com/restrictR/reference/require_nrow_matches.md),
[`require_nrow_min()`](https://gillescolling.com/restrictR/reference/require_nrow_min.md),
[`require_scalar()`](https://gillescolling.com/restrictR/reference/require_scalar.md),
[`require_sorted()`](https://gillescolling.com/restrictR/reference/require_sorted.md),
[`require_unique_names()`](https://gillescolling.com/restrictR/reference/require_unique_names.md)

## Examples

``` r
cfg <- restrict("cfg") |> require_names(c("alpha", "beta"), mode = "subset")
cfg(list(alpha = 1))
try(cfg(list(alpha = 1, gamma = 2)))
#> Error : cfg: unexpected name: "gamma"
```
