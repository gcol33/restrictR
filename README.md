# restrictR

[![R-CMD-check](https://github.com/gcol33/restrictR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/gcol33/restrictR/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/gcol33/restrictR/graph/badge.svg)](https://app.codecov.io/gh/gcol33/restrictR)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Composable Runtime Contracts for R**

Build reusable input validators from small `require_*()` blocks, composed with the base pipe `|>`. Each `|>` returns a new immutable validator you can call like a function. Dependent rules use formulas with explicit context. Errors are structured and path-aware. No DSL, no operator overloading, just R.

## Quick Start

```r
library(restrictR)

# Define once
require_positive_scalar <- restrict("x") |>
  require_numeric(no_na = TRUE) |>
  require_length(1L) |>
  require_between(lower = 0, exclusive_lower = TRUE)

# Enforce anywhere
require_positive_scalar(3.14)   # passes silently
require_positive_scalar(-1)     # Error: x: must be in (0, Inf]
                                #   Found: -1
```

## Statement of Need

R has no built-in way to define reusable input contracts. You end up copy-pasting the same `stopifnot()` / `if (!is.numeric(...)) stop(...)` blocks across functions. When the contract changes, you hunt for every copy. One function says `"x must be numeric"`, the next says `"expected numeric input"`.

`restrictR` gives you pipe-composable validators instead. Define once, call like a function, get structured errors every time. Validators also print their own contracts, so your documentation stays in sync with what actually runs.

## Features

### Schema Validation

```r
require_newdata <- restrict("newdata") |>
  require_df() |>
  require_has_cols(c("x1", "x2")) |>
  require_col_numeric("x1", no_na = TRUE, finite = TRUE) |>
  require_col_numeric("x2", no_na = TRUE, finite = TRUE) |>
  require_nrow_min(1L)
```

### Dependent Rules

```r
require_pred <- restrict("pred") |>
  require_numeric(no_na = TRUE) |>
  require_length_matches(~ nrow(newdata))

# Context is explicit, never magic
require_pred(predictions, newdata = df)
```

### Path-Aware Error Messages

```
newdata$x2: must be numeric, got character
```

```
pred: length must match nrow(newdata) (100)
  Found: length 50
```

```
x: must not contain NA
  At: 2, 5, 9
```

### Self-Documenting

```r
print(require_newdata)
#> <restriction newdata>
#>   1. must be a data.frame
#>   2. must have columns: "x1", "x2"
#>   3. $x1 must be numeric (no NA, finite)
#>   4. $x2 must be numeric (no NA, finite)
#>   5. must have at least 1 row

as_contract_text(require_newdata)
#> "Must be a data.frame. Must have columns: \"x1\", \"x2\".
#>  $x1 must be numeric (no NA, finite). ..."
```

## Installation

```r
# Install development version from GitHub
# install.packages("pak")
pak::pak("gcol33/restrictR")
```

## Usage Examples

### In Functions

```r
predict2 <- function(object, newdata, ...) {
  require_newdata(newdata)
  out <- predict(object, newdata = newdata)
  require_pred(out, newdata = newdata)
  out
}
```

### Enum Validation

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

### Column-Level Checks

```r
require_survey <- restrict("survey") |>
  require_df() |>
  require_has_cols(c("age", "income", "status")) |>
  require_col_numeric("age", no_na = TRUE) |>
  require_col_between("age", lower = 0, upper = 150) |>
  require_col_numeric("income", no_na = TRUE, finite = TRUE) |>
  require_col_one_of("status", c("active", "inactive", "pending"))
```

### Roxygen Integration

```r
#' @param newdata `r as_contract_text(require_newdata)`
```

### Custom Steps

For domain-specific invariants, `require_custom()` lets you write your own
check while keeping the same error format via `fail()`:

```r
require_weights <- restrict("weights") |>
  require_numeric(no_na = TRUE) |>
  require_between(lower = 0, upper = 1) |>
  require_custom(
    label = "must sum to 1",
    fn = function(value, name, ctx) {
      if (abs(sum(value) - 1) > 1e-8) {
        fail(name, "must sum to 1",
             found = sprintf("sum = %g", sum(value)))
      }
    }
  )
```

## Built-In Steps

| Category | Steps |
|----------|-------|
| **Type checks** | `require_df()`, `require_numeric()`, `require_integer()`, `require_character()`, `require_logical()` |
| **Missingness** | `require_no_na()`, `require_finite()` |
| **Structure** | `require_length()`, `require_length_min()`, `require_length_max()`, `require_length_matches()`, `require_nrow_min()`, `require_nrow_matches()`, `require_has_cols()` |
| **Values** | `require_positive()`, `require_negative()`, `require_between()`, `require_one_of()` |
| **Columns** | `require_col_numeric()`, `require_col_character()`, `require_col_between()`, `require_col_one_of()` |
| **Extension** | `require_custom()` |

## Documentation

- [Runtime Contracts for R Functions](https://gillescolling.com/restrictR/articles/restrictR.html)

## Support

> "Software is like sex: it's better when it's free." -- Linus Torvalds

I'm a PhD student who builds R packages in my free time because I believe good tools should be free and open. I started these projects for my own work and figured others might find them useful too.

If this package saved you some time, buying me a coffee is a nice way to say thanks. It helps with my coffee addiction.

[![Buy Me A Coffee](https://img.shields.io/badge/-Buy%20me%20a%20coffee-FFDD00?logo=buymeacoffee&logoColor=black)](https://buymeacoffee.com/gcol33)

## License

MIT (see the LICENSE file)

## Citation

```bibtex
@software{restrictR,
  author = {Colling, Gilles},
  title = {restrictR: Composable Runtime Contracts for R},
  year = {2026},
  url = {https://github.com/gcol33/restrictR}
}
```
