# restrictR

*the same input check, written once*

restrictR checks the arguments of R functions against contracts, such as
“a single non-negative number” or “a data frame with numeric columns
`x1` and `x2`”, that are written once and called at the top of every
function that takes the argument.

A contract is built with the base pipe:
[`restrict()`](https://gillescolling.com/restrictR/reference/restrict.md)
names the argument and each `require_*()` step adds one check. The
result is a validator, an ordinary R function that stops with a message
of the form `path: message` when a value fails. Each pipe returns a new
validator and leaves the one it started from unchanged, so a shared base
can be extended in several directions. You decide which contracts share
a base and where each validator is called. restrictR supports:

- **One rule for many functions.** A validator defined once is called by
  every function that takes the same argument, so the rule and its error
  message live in one place.
- **Rules that depend on other arguments.** A one-sided formula such as
  `~ nrow(newdata)` refers to another argument, which is passed to the
  validator when it is called.
- **Errors that point to the value.** A failure names the path to the
  offending element (`newdata$x2`), what was expected and what was
  found, with the positions of missing values.
- **Contracts as documentation.** A validator prints its steps as a
  numbered list, and
  [`as_contract_text()`](https://gillescolling.com/restrictR/reference/as_contract_text.html)
  renders them as text for a roxygen `@param`.
- **Checks without stopping.**
  [`is_valid()`](https://gillescolling.com/restrictR/reference/is_valid.md)
  returns `TRUE` or `FALSE`,
  [`validation_errors()`](https://gillescolling.com/restrictR/reference/validation_errors.md)
  returns the messages, and
  [`expect_valid()`](https://gillescolling.com/restrictR/reference/expect_valid.md)
  and
  [`expect_invalid()`](https://gillescolling.com/restrictR/reference/expect_invalid.md)
  test a validator with [testthat](https://testthat.r-lib.org).

restrictR is written in base R and imports no other package.

## Installation

``` r

install.packages("restrictR")
```

Development version:

``` r

# install.packages("pak")
pak::pak("gcol33/restrictR")
```

## Usage

1.  Name the argument with
    [`restrict()`](https://gillescolling.com/restrictR/reference/restrict.md).
2.  Add one `require_*()` step per condition with `|>`.
3.  Call the validator at the top of each function that takes the
    argument.

``` r

library(restrictR)

require_dose <- restrict("dose") |>
  require_numeric() |>
  require_length(1L) |>
  require_positive()

require_dose(2.5)
require_dose(-1)
#> Error:
#> ! dose: must be non-negative
#>   Found: -1
```

A value that passes returns invisibly, so the call prints nothing. A
value that fails stops with the argument name, the condition and the
value found.

## One rule for many functions

A contract for a data frame combines steps on the whole object with
validators for single columns:

``` r

require_feature <- restrict("feature") |>
  require_numeric(no_na = TRUE, finite = TRUE)

require_newdata <- restrict("newdata") |>
  require_df() |>
  require_has_cols(c("x1", "x2")) |>
  require_col("x1", require_feature) |>
  require_col("x2", require_feature) |>
  require_nrow_min(1L)

require_newdata(data.frame(x1 = 1:3, x2 = c("a", "b", "c")))
#> Error:
#> ! newdata$x2: must be numeric, got character
```

[`predict()`](https://rdrr.io/r/stats/predict.html),
[`simulate()`](https://rdrr.io/r/stats/simulate.html) or any other
function that takes `newdata` calls `require_newdata(newdata)` as its
first line. A change to the rule is made once, in the definition.

## Rules that depend on other arguments

A one-sided formula names another argument, and that argument is passed
to the validator by name when it is called:

``` r

require_pred <- restrict("pred") |>
  require_numeric(no_na = TRUE) |>
  require_length_matches(~ nrow(newdata))

newdata <- data.frame(x1 = 1:3, x2 = c(0.5, 1.5, 2.5))
require_pred(c(0.1, 0.2), newdata = newdata)
#> Error:
#> ! pred: length must match nrow(newdata) (3)
#>   Found: length 2
```

The validator reads `newdata` only from its arguments, never from the
calling environment.

## A validator that documents itself

Printing a validator lists its steps, and
[`as_contract_text()`](https://gillescolling.com/restrictR/reference/as_contract_text.md)
turns the same list into the text of a roxygen `@param`, so the
documentation of an argument follows its contract:

``` r

require_newdata
#> <restriction newdata>
#>   1. must be a data.frame
#>   2. must have columns: "x1", "x2"
#>   3. $x1: must be numeric, no NA, finite
#>   4. $x2: must be numeric, no NA, finite
#>   5. must have at least 1 row
```

``` r

#' @param newdata `r as_contract_text(require_newdata)`
```

[`require_custom()`](https://gillescolling.com/restrictR/reference/require_custom.md)
adds a step with a check of your own, reported in the same format
through
[`fail()`](https://gillescolling.com/restrictR/reference/fail.md). The
[reference index](https://gillescolling.com/restrictR/reference/) lists
every built-in step, grouped into type, missingness, structure, value,
character, file-system and function checks.

## Compared with checkmate

[checkmate](https://CRAN.R-project.org/package=checkmate) provides
`assert*()`, `check*()` and `test*()` functions in C that are called
inline, one per argument, where the check is needed. restrictR names a
contract once, reuses it across functions, and prints it as
documentation. The two work together: a
[`require_custom()`](https://gillescolling.com/restrictR/reference/require_custom.md)
step can call a checkmate assertion. [Relation to
checkmate](https://gillescolling.com/restrictR/articles/restrictR.html#relation-to-checkmate)
compares them further.

## Documentation

Start with [Runtime Contracts for R
Functions](https://gillescolling.com/restrictR/articles/restrictR.html):
reusable schemas, dependent rules, composition, custom steps, testing
and contracts in a package.

- [Full reference](https://gillescolling.com/restrictR/reference/):
  every step, grouped by job.

## Getting help

Questions and bug reports go to the [GitHub
issues](https://github.com/gcol33/restrictR/issues). A bug report is
easiest to act on with a small reproducible example, for instance made
with [reprex](https://reprex.tidyverse.org/).

## Support

> “Software is like sex: it’s better when it’s free.” — Linus Torvalds

I’m a PhD student who builds R packages in my free time because I
believe good tools should be free and open. I started these projects for
my own work and figured others might find them useful too.

If this package saved you some time, buying me a coffee is a nice way to
say thanks. It helps with my coffee addiction.

[![Buy Me A
Coffee](https://img.shields.io/badge/-Buy%20me%20a%20coffee-FFDD00?logo=buymeacoffee&logoColor=black)](https://buymeacoffee.com/gcol33)

## License

restrictR is licensed under MIT.

## Citation

``` text
Colling G (2026). _restrictR: Composable Runtime Contracts_.
doi:10.32614/CRAN.package.restrictR
<https://doi.org/10.32614/CRAN.package.restrictR>. R package version
0.3.0, <https://gillescolling.com/restrictR/>.
```

BibTeX:

``` bibtex
@Manual{colling2026restrictr,
  title = {restrictR: Composable Runtime Contracts},
  author = {Gilles Colling},
  year = {2026},
  note = {R package version 0.3.0},
  doi = {10.32614/CRAN.package.restrictR},
  url = {https://gillescolling.com/restrictR/},
}
```

Download the citation as
[BibTeX](https://gillescolling.com/restrictR/restrictR.bib) or
[RIS](https://gillescolling.com/restrictR/restrictR.ris).
