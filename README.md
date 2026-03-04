
<!-- badges: start -->
[![R-CMD-check](https://github.com/gcol33/restrictR/actions/workflows/R-CMD-check.yml/badge.svg)](https://github.com/gcol33/restrictR/actions/workflows/R-CMD-check.yml)
[![Codecov test coverage](https://codecov.io/gh/gcol33/restrictR/graph/badge.svg)](https://app.codecov.io/gh/gcol33/restrictR)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

# restrictR <img src="man/figures/logo.png" align="right" height="139" alt="" />

**Composable runtime contracts for R.**

## Quick Start

```r
library(restrictR)

# Define once
require_positive_scalar <- restrict("x") |>
  require_numeric(no_na = TRUE) |>
  require_length(1L) |>
  require_range(lower = 0, exclusive_lower = TRUE)

# Enforce anywhere
require_positive_scalar(3.14)   # passes silently
require_positive_scalar(-1)     # Error: `x` failed validation
                                #   ✖ must be in (0, Inf], got -1
```

## Statement of Need

R has no built-in way to define reusable input contracts. Developers copy-paste
the same `stopifnot()` / `if (!is.numeric(...)) stop(...)` blocks across
functions. restrictR replaces that with composable, pipe-friendly validators
that produce clear error messages.

## Features

### Schema validation

```r
require_newdata <- restrict("newdata") |>
  require_df() |>
  require_has_cols(c("x1", "x2")) |>
  require_col_numeric("x1", no_na = TRUE, finite = TRUE) |>
  require_col_numeric("x2", no_na = TRUE, finite = TRUE)
```

### Dependent rules

```r
require_pred <- restrict("pred") |>
  require_numeric(no_na = TRUE) |>
  require_length_matches(~ nrow(newdata))

# Context is explicit, never magic
require_pred(predictions, newdata = df)
```

### Path-aware error messages

```
`newdata` failed validation
  ✖ newdata$x2 must be numeric, got character
```

### Self-documenting

```r
print(require_newdata)
#> <restriction: newdata>
#>
#>   1. must be a data.frame
#>   2. must have columns: "x1", "x2"
#>   3. $x1 must be numeric (no NA, finite)
#>   4. $x2 must be numeric (no NA, finite)

as_contract_text(require_newdata)
#> "Must be a data.frame. Must have columns: \"x1\", \"x2\". ..."
```

## Installation

```r
# install.packages("pak")
pak::pak("gcol33/restrictR")
```

## Usage

### In functions

```r
predict2 <- function(object, newdata, ...) {
  require_newdata(newdata)
  UseMethod("predict2")
}

predict2.lm <- function(object, newdata, ...) {
  out <- predict(object, newdata = newdata)
  require_pred(out, newdata = newdata)
  out
}
```

### Enum validation

```r
require_method <- restrict("method") |>
  require_character(no_na = TRUE) |>
  require_length(1L) |>
  require_one_of(c("euclidean", "manhattan", "cosine"))

compute_distance <- function(x, y, method = "euclidean") {
  require_method(method)
  # ...
}
```

### Roxygen integration

```r
#' @param newdata `r as_contract_text(require_newdata)`
```

## Support

> "Software is like sex: it's better when it's free." -- Linus Torvalds

I'm a PhD student who builds R packages in my free time because I believe good
tools should be free and open.

[![Buy Me A Coffee](https://img.shields.io/badge/-Buy%20me%20a%20coffee-FFDD00?logo=buymeacoffee&logoColor=black)](https://buymeacoffee.com/gcol33)

## License

MIT
