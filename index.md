# restrictR

*you wrote that check already*

[![CRAN
status](https://www.r-pkg.org/badges/version/restrictR)](https://CRAN.R-project.org/package=restrictR)
[![CRAN
downloads](https://cranlogs.r-pkg.org/badges/grand-total/restrictR)](https://cran.r-project.org/package=restrictR)
[![Monthly
downloads](https://cranlogs.r-pkg.org/badges/restrictR)](https://cran.r-project.org/package=restrictR)
[![R-CMD-check](https://github.com/gcol33/restrictR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/gcol33/restrictR/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/gcol33/restrictR/graph/badge.svg)](https://app.codecov.io/gh/gcol33/restrictR)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Composable runtime contracts for R, built from base pipe chains into
immutable validator closures.**

Write each input contract once. `restrictR` turns a `|>` chain of small
`require_*()` steps into a callable validator you drop at the top of any
function. Every `|>` returns a new validator, so you branch from a
shared base without touching it, and every failure comes back in one
structured `path: message` format. No DSL, no operator overloading; a
validator is an ordinary R closure you can pass around, print, and read
back as documentation.

``` r

library(restrictR)

# define once
require_positive_scalar <- restrict("x") |>
  require_numeric(no_na = TRUE) |>
  require_length(1L) |>
  require_between(lower = 0, exclusive_lower = TRUE)

# enforce anywhere
require_positive_scalar(3.14)   # passes silently
require_positive_scalar(-1)     # Error: x: must be in (0, Inf]
                                #   Found: -1
```

## One contract, not scattered guard clauses

Every exported function tends to start with the same
`if (!is.numeric(...)) stop(...)` checks, copied across methods and
drifting apart, until one function says `"x must be numeric"` and
another says `"expected numeric input"`. Define the contract once as a
pipe chain, call it at the top of any method, and the rule lives in one
place with one error format. Change the rule, change it once.

``` r

require_newdata <- restrict("newdata") |>
  require_df() |>
  require_has_cols(c("x1", "x2")) |>
  require_col_numeric("x1", no_na = TRUE, finite = TRUE) |>
  require_col_numeric("x2", no_na = TRUE, finite = TRUE) |>
  require_nrow_min(1L)

predict2 <- function(object, newdata, ...) {
  require_newdata(newdata)
  predict(object, newdata = newdata)
}
```

## Rules that depend on other arguments

A one-sided formula references another argument by name. Context is
passed explicitly when you call the validator, so evaluation never
reaches into parent frames for it.

``` r

require_pred <- restrict("pred") |>
  require_numeric(no_na = TRUE) |>
  require_length_matches(~ nrow(newdata))

require_pred(predictions, newdata = df)
```

## Path-aware error messages

Failures report the exact path and position, in one shared format:

    newdata$x2: must be numeric, got character

    pred: length must match nrow(newdata) (100)
      Found: length 50

    x: must not contain NA
      At: 2, 5, 9

## A validator that documents itself

The same step list that runs the checks also prints the contract and
renders it as text for roxygen, so `@param` documentation and
enforcement stay in sync:

``` r

print(require_newdata)
#> <restriction newdata>
#>   1. must be a data.frame
#>   2. must have columns: "x1", "x2"
#>   3. $x1 must be numeric (no NA, finite)
#>   4. $x2 must be numeric (no NA, finite)
#>   5. must have at least 1 row

#' @param newdata `r as_contract_text(require_newdata)`
```

## Custom steps

When a contract needs a domain-specific invariant,
[`require_custom()`](https://gillescolling.com/restrictR/reference/require_custom.md)
runs your own check while keeping the same error format through
[`fail()`](https://gillescolling.com/restrictR/reference/fail.md):

``` r

require_weights <- restrict("weights") |>
  require_numeric(no_na = TRUE) |>
  require_between(lower = 0, upper = 1) |>
  require_custom(
    label = "must sum to 1",
    fn = function(value, name, ctx) {
      if (abs(sum(value) - 1) > 1e-8) {
        fail(name, "must sum to 1", found = sprintf("sum = %g", sum(value)))
      }
    }
  )
```

## Built-in steps

| Category | Steps |
|----|----|
| **Type checks** | [`require_df()`](https://gillescolling.com/restrictR/reference/require_df.md), [`require_numeric()`](https://gillescolling.com/restrictR/reference/require_numeric.md), [`require_integer()`](https://gillescolling.com/restrictR/reference/require_integer.md), [`require_character()`](https://gillescolling.com/restrictR/reference/require_character.md), [`require_logical()`](https://gillescolling.com/restrictR/reference/require_logical.md) |
| **Null / missingness** | [`require_not_null()`](https://gillescolling.com/restrictR/reference/require_not_null.md), [`require_no_na()`](https://gillescolling.com/restrictR/reference/require_no_na.md), [`require_finite()`](https://gillescolling.com/restrictR/reference/require_finite.md) |
| **Structure** | [`require_scalar()`](https://gillescolling.com/restrictR/reference/require_scalar.md), [`require_named()`](https://gillescolling.com/restrictR/reference/require_named.md), [`require_length()`](https://gillescolling.com/restrictR/reference/require_length.md), [`require_length_min()`](https://gillescolling.com/restrictR/reference/require_length_min.md), [`require_length_max()`](https://gillescolling.com/restrictR/reference/require_length_max.md), [`require_length_matches()`](https://gillescolling.com/restrictR/reference/require_length_matches.md), [`require_nrow_min()`](https://gillescolling.com/restrictR/reference/require_nrow_min.md), [`require_nrow_matches()`](https://gillescolling.com/restrictR/reference/require_nrow_matches.md), [`require_has_cols()`](https://gillescolling.com/restrictR/reference/require_has_cols.md) |
| **Values** | [`require_positive()`](https://gillescolling.com/restrictR/reference/require_positive.md), [`require_negative()`](https://gillescolling.com/restrictR/reference/require_negative.md), [`require_between()`](https://gillescolling.com/restrictR/reference/require_between.md), [`require_one_of()`](https://gillescolling.com/restrictR/reference/require_one_of.md), [`require_unique()`](https://gillescolling.com/restrictR/reference/require_unique.md) |
| **Columns** | [`require_col_numeric()`](https://gillescolling.com/restrictR/reference/require_col_numeric.md), [`require_col_character()`](https://gillescolling.com/restrictR/reference/require_col_character.md), [`require_col_between()`](https://gillescolling.com/restrictR/reference/require_col_between.md), [`require_col_one_of()`](https://gillescolling.com/restrictR/reference/require_col_one_of.md) |
| **Extension** | [`require_custom()`](https://gillescolling.com/restrictR/reference/require_custom.md) |

## Installation

``` r

install.packages("restrictR")            # CRAN

install.packages("pak")                  # development version
pak::pak("gcol33/restrictR")
```

## Documentation

- [Runtime Contracts for R
  Functions](https://gillescolling.com/restrictR/articles/restrictR.html)

## Support

> “Software is like sex: it’s better when it’s free.” – Linus Torvalds

I’m a PhD student who builds R packages in my free time because I
believe good tools should be free and open. I started these projects for
my own work and figured others might find them useful too.

If this package saved you some time, buying me a coffee is a nice way to
say thanks. It helps with my coffee addiction.

[![Buy Me A
Coffee](https://img.shields.io/badge/-Buy%20me%20a%20coffee-FFDD00?logo=buymeacoffee&logoColor=black)](https://buymeacoffee.com/gcol33)

## License

MIT (see the LICENSE file)

## Citation

``` bibtex
@software{restrictR,
  author = {Colling, Gilles},
  title = {restrictR: Composable Runtime Contracts for R},
  year = {2026},
  url = {https://github.com/gcol33/restrictR}
}
```
