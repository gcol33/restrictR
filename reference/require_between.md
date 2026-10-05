# Require Value in Range

Validates that all elements of a value fall within a specified range.
The value can be numeric, `Date`, `POSIXct`, `difftime` or an ordered
factor.

## Usage

``` r
require_between(
  restriction,
  lower = -Inf,
  upper = Inf,
  exclusive_lower = FALSE,
  exclusive_upper = FALSE
)
```

## Arguments

- restriction:

  a `restriction` object.

- lower:

  lower bound (default `-Inf`, no lower bound).

- upper:

  upper bound (default `Inf`, no upper bound).

- exclusive_lower:

  logical; if `TRUE`, lower bound is exclusive.

- exclusive_upper:

  logical; if `TRUE`, upper bound is exclusive.

## Value

The modified `restriction` object.

## Details

The value and the bounds must be the same kind: a `Date` bound against a
numeric value fails with a type error. Ordered-factor bounds are single
values of a factor with the same levels as the validated value. Other
input fails with a type error. `NA` elements are skipped; chain
[`require_no_na()`](https://gillescolling.com/restrictR/reference/require_no_na.md)
to reject them.

## See also

Other value checks:
[`require_contains()`](https://gillescolling.com/restrictR/reference/require_contains.md),
[`require_disjoint()`](https://gillescolling.com/restrictR/reference/require_disjoint.md),
[`require_levels()`](https://gillescolling.com/restrictR/reference/require_levels.md),
[`require_negative()`](https://gillescolling.com/restrictR/reference/require_negative.md),
[`require_one_of()`](https://gillescolling.com/restrictR/reference/require_one_of.md),
[`require_positive()`](https://gillescolling.com/restrictR/reference/require_positive.md),
[`require_set_equal()`](https://gillescolling.com/restrictR/reference/require_set_equal.md),
[`require_unique()`](https://gillescolling.com/restrictR/reference/require_unique.md)

## Examples

``` r
period <- restrict("start") |>
  require_between(as.Date("2020-01-01"), as.Date("2020-12-31"))
period(as.Date("2020-06-15"))
try(period(as.Date("2021-01-01")))
#> Error : start: must be in [2020-01-01, 2020-12-31]
#>   Found: 2021-01-01
```
