# Require Values Disjoint From Context

Validates that no element of the value occurs in the vector a formula
evaluates to, for example that train and test ids do not overlap. The
formula is evaluated using only explicitly passed context arguments,
plus `.value` and `.name`.

## Usage

``` r
require_disjoint(restriction, formula)
```

## Arguments

- restriction:

  a `restriction` object.

- formula:

  a one-sided formula (e.g. `~ test_ids`).

## Value

The modified `restriction` object.

## Details

`NA` elements are ignored. A factor is compared by its labels.

## See also

Other value checks:
[`require_between()`](https://gillescolling.com/restrictR/reference/require_between.md),
[`require_contains()`](https://gillescolling.com/restrictR/reference/require_contains.md),
[`require_levels()`](https://gillescolling.com/restrictR/reference/require_levels.md),
[`require_negative()`](https://gillescolling.com/restrictR/reference/require_negative.md),
[`require_one_of()`](https://gillescolling.com/restrictR/reference/require_one_of.md),
[`require_positive()`](https://gillescolling.com/restrictR/reference/require_positive.md),
[`require_set_equal()`](https://gillescolling.com/restrictR/reference/require_set_equal.md),
[`require_unique()`](https://gillescolling.com/restrictR/reference/require_unique.md)

## Examples

``` r
train_ids <- restrict("train_ids") |> require_disjoint(~ test_ids)
train_ids(1:3, test_ids = 4:6)
try(train_ids(1:3, test_ids = 3:6))
#> Error : train_ids: must not share values with test_ids
#>   Found: "3"
#>   At: 3
```
