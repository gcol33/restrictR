# Runtime Contracts for R Functions

``` r

library(restrictR)
```

## Overview

`restrictR` lets you define reusable input contracts from small building
blocks using the base pipe `|>`. A contract is defined once and called
like a function to validate data at runtime. Validators are immutable:
each `|>` returns a new validator, so you can safely branch from a
shared base without side effects.

| Section | What you’ll learn |
|----|----|
| [Reusable schemas](#reusable-schemas) | Define and reuse data.frame contracts |
| [Dependent validation](#dependent-validation) | Constraints that reference other arguments |
| [Enum arguments](#enum-arguments) | Restrict string arguments to a fixed set |
| [Arbitrary classes](#arbitrary-classes) | Validate factors, dates, and model objects |
| [Data frame with mixed constraints](#data-frame-with-mixed-constraints) | Columns + enums + ranges in one contract |
| [Checking without stopping](#checking-without-stopping) | Collect all failures; test without throwing |
| [Custom steps](#custom-steps) | Domain-specific invariants |
| [Self-documentation](#self-documentation) | Print, [`as_contract_text()`](https://gillescolling.com/restrictR/reference/as_contract_text.md), [`as_contract_block()`](https://gillescolling.com/restrictR/reference/as_contract_block.md) |
| [Using contracts in packages](#using-contracts-in-packages) | The recommended pattern for R packages |

## Reusable Schemas

The most common use case: validating a `newdata` argument in a
predict-like function. Instead of scattering
`if`/[`stop()`](https://rdrr.io/r/base/stop.html) blocks, define the
contract once:

``` r

require_feature <- restrict("feature") |>
  require_numeric(no_na = TRUE, finite = TRUE)

require_newdata <- restrict("newdata") |>
  require_df() |>
  require_has_cols(c("x1", "x2")) |>
  require_col("x1", require_feature) |>
  require_col("x2", require_feature) |>
  require_nrow_min(1L)
```

The result is a callable function. Valid input passes silently:

``` r

good <- data.frame(x1 = c(1, 2, 3), x2 = c(4, 5, 6))
require_newdata(good)
```

Invalid input produces a structured error with the exact path and
position:

``` r

require_newdata(42)
#> Error:
#> ! newdata: must be a data.frame, got numeric
```

``` r

require_newdata(data.frame(x1 = c(1, NA), x2 = c(3, 4)))
#> Error:
#> ! newdata$x1: must not contain NA
#>   At: 2
```

``` r

require_newdata(data.frame(x1 = c(1, 2), x2 = c("a", "b")))
#> Error:
#> ! newdata$x2: must be numeric, got character
```

Every error follows the same format: `path: message`, optionally
followed by `Found:` and `At:` lines. This makes errors instantly
recognizable and grep-friendly.

## Dependent Validation

Some contracts depend on context. A prediction vector must have the same
length as the rows in `newdata`:

``` r

require_pred <- restrict("pred") |>
  require_numeric(no_na = TRUE, finite = TRUE) |>
  require_length_matches(~ nrow(newdata))
```

The formula `~ nrow(newdata)` declares a dependency on `newdata`. Pass
it explicitly when calling the validator:

``` r

newdata <- data.frame(x1 = 1:5, x2 = 6:10)
require_pred(c(0.1, 0.2, 0.3, 0.4, 0.5), newdata = newdata)
```

Mismatched lengths produce a precise diagnostic:

``` r

require_pred(c(0.1, 0.2, 0.3), newdata = newdata)
#> Error:
#> ! pred: length must match nrow(newdata) (5)
#>   Found: length 3
```

Missing context is caught **before any checks run**:

``` r

require_pred(c(0.1, 0.2, 0.3))
#> Error:
#> ! `pred` depends on: newdata. Pass newdata = ... when calling the validator.
```

Context can also be passed as a named list via `.ctx`:

``` r

require_pred(1:5, .ctx = list(newdata = newdata))
```

## Enum Arguments

For string arguments that must be one of a fixed set:

``` r

require_method <- restrict("method") |>
  require_character(no_na = TRUE) |>
  require_length(1L) |>
  require_one_of(c("euclidean", "manhattan", "cosine"))
```

``` r

require_method("euclidean")
```

``` r

require_method("chebyshev")
#> Error:
#> ! method: must be one of: "euclidean", "manhattan", "cosine"
#>   Found: "chebyshev"
```

## Arbitrary Classes

[`require_class()`](https://gillescolling.com/restrictR/reference/require_class.md)
covers types without a dedicated check, such as factors, dates, and
fitted-model objects. By default it tests inheritance, so a subclass
passes; set `exact = TRUE` to require the first class exactly.

``` r

require_event <- restrict("event") |>
  require_class("Date")

require_event(as.Date("2026-01-01"))
```

``` r

require_event("2026-01-01")
#> Error:
#> ! event: must be of class "Date", got character
```

## Data Frame with Mixed Constraints

Contracts work well for functions that accept a data frame with typed
columns, value ranges, and categorical fields in one go:

``` r

require_survey <- restrict("survey") |>
  require_df() |>
  require_has_cols(c("age", "income", "status")) |>
  require_col("age", restrict("age") |>
                require_numeric(no_na = TRUE) |>
                require_between(lower = 0, upper = 150)) |>
  require_col("income", restrict("income") |>
                require_numeric(no_na = TRUE, finite = TRUE)) |>
  require_col("status", restrict("status") |>
                require_one_of(c("active", "inactive", "pending")))
```

``` r

good_survey <- data.frame(
  age = c(25, 40, 33),
  income = c(35000, 60000, 45000),
  status = c("active", "inactive", "active")
)
require_survey(good_survey)
```

``` r

bad_survey <- data.frame(
  age = c(25, -5, 200),
  income = c(35000, 60000, 45000),
  status = c("active", "inactive", "active")
)
require_survey(bad_survey)
#> Error:
#> ! survey$age: must be in [0, 150]
#>   Found: -5
#>   At: 2, 3
```

## Composing Validators

[`require_col()`](https://gillescolling.com/restrictR/reference/require_col.md)
lifts any validator onto a data frame column, so a rule written once
serves both a standalone argument and a column. Errors keep the column
path.
[`require_each()`](https://gillescolling.com/restrictR/reference/require_each.md)
applies a validator to every element of a list, and
[`require_fields()`](https://gillescolling.com/restrictR/reference/require_fields.md)
to named fields:

``` r

require_age <- restrict("age") |>
  require_integer(no_na = TRUE) |>
  require_between(0, 120)

require_people <- restrict("people") |>
  require_df() |>
  require_col("age", require_age)

validation_errors(require_people, data.frame(age = c(30L, 150L)))
#> [1] "people$age: must be in [0, 120]\n  Found: 150\n  At: 2"
```

``` r

require_layers <- restrict("layers") |>
  require_class("list") |>
  require_each(restrict("layer") |> require_numeric())

validation_errors(require_layers, list(1, "a", 3))
#> [1] "layers[[2]]: must be numeric, got character"
```

[`allow_null()`](https://gillescolling.com/restrictR/reference/allow_null.md)
marks an optional argument: `NULL` passes, anything else must satisfy
every step.
[`require_valid()`](https://gillescolling.com/restrictR/reference/require_valid.md)
includes another validator’s steps, and
[`require_any()`](https://gillescolling.com/restrictR/reference/require_any.md)
accepts a value that satisfies at least one alternative:

``` r

require_weights <- restrict("weights") |>
  require_numeric(no_na = TRUE) |>
  require_positive() |>
  allow_null()
require_weights(NULL)

require_num_or_df <- restrict("x") |>
  require_any(
    restrict("x") |> require_numeric(),
    restrict("x") |> require_df() |> require_has_cols("value")
  )
validation_errors(require_num_or_df, "a")
#> [1] "x: must satisfy one of:\n  - must be numeric, got character\n  - must be a data.frame, got character"
```

[`require_between()`](https://gillescolling.com/restrictR/reference/require_between.md)
also bounds dates, times, durations and ordered factors:

``` r

require_period <- restrict("start") |>
  require_between(as.Date("2020-01-01"), as.Date("2020-12-31"))
validation_errors(require_period, as.Date("2021-03-01"))
#> [1] "start: must be in [2020-01-01, 2020-12-31]\n  Found: 2021-03-01"
```

## Strings, Paths, and Factor Levels

Character steps check every non-`NA` element:
[`require_pattern()`](https://gillescolling.com/restrictR/reference/require_pattern.md)
matches a regular expression,
[`require_nchar()`](https://gillescolling.com/restrictR/reference/require_nchar.md)
bounds the length and
[`require_nonempty()`](https://gillescolling.com/restrictR/reference/require_nonempty.md)
rejects blank strings.

``` r

require_code <- restrict("code") |>
  require_character() |>
  require_nonempty() |>
  require_pattern("^[A-Z]{3}-[0-9]{2}$")
validation_errors(require_code, c("ABC-12", "abc-12", " "))
#> [1] "code: must not contain blank strings\n  Found: \" \"\n  At: 3"                    
#> [2] "code: must match pattern \"^[A-Z]{3}-[0-9]{2}$\"\n  Found: \"abc-12\"\n  At: 2, 3"
```

File-system steps catch a bad input path or output directory at the top
of a function. `Found:` shows the normalized path, so a relative path
resolved against the wrong working directory is visible:

``` r

require_input <- restrict("path") |> require_file_exists(extension = "csv")
validation_errors(require_input, "data/missing.csv")
#> [1] "path: must be an existing file\n  Found: \"/home/runner/work/restrictR/restrictR/vignettes/data/missing.csv\""
```

A factor with a level the model has not seen is the classic
[`predict()`](https://rdrr.io/r/stats/predict.html) failure.
[`require_levels()`](https://gillescolling.com/restrictR/reference/require_levels.md)
compares against the training levels, and
[`require_names()`](https://gillescolling.com/restrictR/reference/require_names.md)
does the same for column names:

``` r

train <- data.frame(g = factor(c("a", "b")), x = 1:2)
require_newdata <- restrict("newdata") |>
  require_names(c("g", "x"), mode = "superset") |>
  require_col("g", restrict("g") |>
                 require_levels(levels(train$g), mode = "subset"))
validation_errors(require_newdata,
                  data.frame(g = factor("c"), x = 3L))
#> [1] "newdata$g: unexpected level: \"c\""
```

## Checking Without Stopping

By default a validator stops at the first failing step. Pass
`.on_fail = "all"` to run every step and collect all violations in one
report:

``` r

messy_survey <- data.frame(
  age = c(25, -5, 200),
  income = c(35000, NA, 45000),
  status = c("active", "banned", "active")
)
require_survey(messy_survey, .on_fail = "all")
#> Error:
#> ! 3 validation failures:
#> survey$age: must be in [0, 150]
#>   Found: -5
#>   At: 2, 3
#> survey$income: must not contain NA
#>   At: 2
#> survey$status: must be one of: "active", "inactive", "pending"
#>   Found: "banned"
#>   At: 2
```

To branch on validity in code,
[`is_valid()`](https://gillescolling.com/restrictR/reference/is_valid.md)
returns a logical and
[`validation_errors()`](https://gillescolling.com/restrictR/reference/validation_errors.md)
returns the messages as a character vector, empty when the value passes:

``` r

is_valid(require_survey, good_survey)
#> [1] TRUE
validation_errors(require_survey, messy_survey)
#> [1] "survey$age: must be in [0, 150]\n  Found: -5\n  At: 2, 3"                                          
#> [2] "survey$income: must not contain NA\n  At: 2"                                                       
#> [3] "survey$status: must be one of: \"active\", \"inactive\", \"pending\"\n  Found: \"banned\"\n  At: 2"
```

## Testing Validators

[`expect_valid()`](https://gillescolling.com/restrictR/reference/expect_valid.md)
and
[`expect_invalid()`](https://gillescolling.com/restrictR/reference/expect_invalid.md)
are testthat expectations that report the validator’s own messages:

``` r

test_that("newdata contract", {
  expect_valid(require_newdata, data.frame(g = factor("a"), x = 1L))
  expect_invalid(require_newdata, data.frame(x = 1L), regexp = "missing required")
})
```

[`steps()`](https://gillescolling.com/restrictR/reference/steps.md)
returns the steps of a validator as a data.frame (label, context
dependencies, parameters) for tooling:

``` r

steps(require_code)[, c("step", "label")]
#>   step                                    label
#> 1    1                        must be character
#> 2    2           must not contain blank strings
#> 3    3 must match pattern "^[A-Z]{3}-[0-9]{2}$"
```

## Custom Steps

For domain-specific invariants that don’t belong in the built-in set,
use
[`require_custom()`](https://gillescolling.com/restrictR/reference/require_custom.md).
The step function receives `(value, name, ctx)` and should call
[`fail()`](https://gillescolling.com/restrictR/reference/fail.md) on
failure to produce the same structured errors as built-in steps:

``` r

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

``` r

require_weights(c(0.5, 0.3, 0.2))
```

``` r

require_weights(c(0.5, 0.5, 0.5))
#> Error:
#> ! weights: must sum to 1
#>   Found: sum = 1.5
```

Custom steps can also declare dependencies:

``` r

require_probs <- restrict("probs") |>
  require_numeric(no_na = TRUE) |>
  require_custom(
    label = "length must match number of classes",
    deps = "n_classes",
    fn = function(value, name, ctx) {
      if (length(value) != ctx$n_classes) {
        fail(name, sprintf("expected %d probabilities", ctx$n_classes),
             found = sprintf("length %d", length(value)))
      }
    }
  )

require_probs(c(0.3, 0.7), n_classes = 2L)
```

## Self-Documentation

Print a validator to see its full contract:

``` r

require_newdata
#> <restriction newdata>
#>   1. must have names: "g", "x"
#>   2. $g: levels must be among: "a", "b"
```

Use
[`as_contract_text()`](https://gillescolling.com/restrictR/reference/as_contract_text.md)
to generate a one-line summary for roxygen `@param`:

``` r

as_contract_text(require_newdata)
#> [1] "Must have names: \"g\", \"x\". $g: levels must be among: \"a\", \"b\"."
```

Use
[`as_contract_block()`](https://gillescolling.com/restrictR/reference/as_contract_block.md)
for multi-line output suitable for `@details`:

``` r

cat(as_contract_block(require_newdata))
#> - must have names: "g", "x"
#> - $g: levels must be among: "a", "b"
```

## Using Contracts in Packages

The recommended pattern: define contracts near the top of the file that
uses them, or in a dedicated `R/contracts.R` if several files share the
same validators. Call them at the top of exported functions.

``` r

# R/contracts.R
require_feature <- restrict("feature") |>
  require_numeric(no_na = TRUE, finite = TRUE)

require_newdata <- restrict("newdata") |>
  require_df() |>
  require_has_cols(c("x1", "x2")) |>
  require_col("x1", require_feature) |>
  require_col("x2", require_feature)

require_pred <- restrict("pred") |>
  require_numeric(no_na = TRUE, finite = TRUE) |>
  require_length_matches(~ nrow(newdata))
```

``` r

# R/predict.R

#' Predict from a fitted model
#'
#' @param newdata Must have names: "g", "x". $g: levels must be among: "a", "b".
#' @param ... additional arguments passed to the underlying model.
#'
#' @export
my_predict <- function(object, newdata, ...) {
  require_newdata(newdata)
  pred <- do_prediction(object, newdata)
  require_pred(pred, newdata = newdata)
  pred
}
```

Contracts compose naturally with the pipe and branch safely (each `|>`
creates a new validator):

``` r

base <- restrict("x") |> require_numeric()
v1 <- base |> require_length(1L)
v2 <- base |> require_between(lower = 0)

# base is unchanged
length(environment(base)$steps)
#> [1] 1
length(environment(v1)$steps)
#> [1] 2
length(environment(v2)$steps)
#> [1] 2
```

## Relation to checkmate

The [checkmate](https://CRAN.R-project.org/package=checkmate) package
covers similar ground with a different emphasis. Its
`assert*`/`check*`/`test*` families provide fast, C-backed checks that
you call inline, one per argument, where the check is needed.
`restrictR` instead lets you name a contract once as a `|>` chain and
reuse that callable validator across functions, compose and branch it
immutably, and have it print and document itself via
[`as_contract_text()`](https://gillescolling.com/restrictR/reference/as_contract_text.md).
Use checkmate when you want quick inline assertions; use `restrictR`
when the same contract recurs across functions and you want a single
definition that also serves as documentation. The two interoperate: a
checkmate assertion can live inside a
[`require_custom()`](https://gillescolling.com/restrictR/reference/require_custom.md)
step.

``` r

sessionInfo()
#> R version 4.6.1 (2026-06-24)
#> Platform: x86_64-pc-linux-gnu
#> Running under: Ubuntu 24.04.5 LTS
#> 
#> Matrix products: default
#> BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
#> LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
#> 
#> locale:
#>  [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
#>  [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
#>  [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
#> [10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   
#> 
#> time zone: UTC
#> tzcode source: system (glibc)
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] restrictR_0.3.0
#> 
#> loaded via a namespace (and not attached):
#>  [1] vctrs_0.7.3       svglite_2.2.2     cli_3.6.6         knitr_1.52       
#>  [5] rlang_1.3.0       xfun_0.61         otel_0.2.0        textshaping_1.0.5
#>  [9] jsonlite_2.0.0    glue_1.8.1        htmltools_0.5.9   sass_0.4.10      
#> [13] rmarkdown_2.32    evaluate_1.0.5    jquerylib_0.1.4   fastmap_1.2.0    
#> [17] yaml_2.3.12       lifecycle_1.0.5   compiler_4.6.1    fs_2.1.0         
#> [21] systemfonts_1.3.2 digest_0.6.39     R6_2.6.1          pillar_1.11.1    
#> [25] bslib_0.12.0      tools_4.6.1       pkgdown_2.2.1     cachem_1.1.0     
#> [29] desc_1.4.3
```
