# Require Factor Levels

Compares `levels(value)` of a factor with a reference. The classic
`predict(newdata)` failure, a factor with a level the model has not
seen, is `require_levels(levels(train$f), mode = "subset")`.

## Usage

``` r
require_levels(
  restriction,
  levels,
  mode = c("identical", "subset", "superset")
)
```

## Arguments

- restriction:

  a `restriction` object.

- levels:

  character vector of reference levels.

- mode:

  how the observed levels relate to `levels`:

  - `"identical"`: the same levels in the same order;

  - `"subset"`: every observed level is in `levels`;

  - `"superset"`: every level in `levels` is present.

## Value

The modified `restriction` object.

## Details

The levels of the factor are compared, whether or not a level occurs in
the data. Non-factor input fails with a type error.

## See also

Other value checks:
[`require_between()`](https://gillescolling.com/restrictR/reference/require_between.md),
[`require_contains()`](https://gillescolling.com/restrictR/reference/require_contains.md),
[`require_disjoint()`](https://gillescolling.com/restrictR/reference/require_disjoint.md),
[`require_negative()`](https://gillescolling.com/restrictR/reference/require_negative.md),
[`require_one_of()`](https://gillescolling.com/restrictR/reference/require_one_of.md),
[`require_positive()`](https://gillescolling.com/restrictR/reference/require_positive.md),
[`require_set_equal()`](https://gillescolling.com/restrictR/reference/require_set_equal.md),
[`require_unique()`](https://gillescolling.com/restrictR/reference/require_unique.md)

## Examples

``` r
f_v <- restrict("f") |> require_levels(c("a", "b"), mode = "subset")
f_v(factor(c("a", "b")))
try(f_v(factor(c("a", "z"))))
#> Error : f: unexpected level: "z"
```
