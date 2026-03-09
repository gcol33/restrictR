# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## Package Overview

Composable runtime contracts for R. Validators built from `require_*()`
building blocks, composed with base pipe `|>`.

## Commands

``` bash
# Full check
"/mnt/c/Program Files/R/R-4.5.2/bin/Rscript.exe" -e 'devtools::check(args = "--no-manual")'

# Document (regenerate NAMESPACE + man/)
"/mnt/c/Program Files/R/R-4.5.2/bin/Rscript.exe" -e 'devtools::document()'

# Run all tests
"/mnt/c/Program Files/R/R-4.5.2/bin/Rscript.exe" -e 'devtools::test()'

# Run a single test file
"/mnt/c/Program Files/R/R-4.5.2/bin/Rscript.exe" -e 'devtools::test(filter = "require-type")'
```

## Architecture

### Core flow

`restrict(name)` → `require_*()` steps via `|>` → callable `restriction`
object (S3 class over a closure)

Validators are **immutable**: `add_step()` creates a new closure via
`make_validator()`, never mutates the original. The closure captures
`name`, `steps`, and precomputed `all_deps` in its environment.

### Source files

- **`R/restrict.R`**: Core machinery —
  [`restrict()`](https://gillescolling.com/restrictR/reference/restrict.md),
  `make_validator()`, `add_step()`, `print.restriction`,
  `as_contract_text/block()`,
  [`require_custom()`](https://gillescolling.com/restrictR/reference/require_custom.md)
- **`R/require.R`**: All 21 built-in `require_*()` steps, organized in
  sections: type checks, missingness, structure checks, column-level
  checks, value checks
- **`R/utils.R`**: Internal helpers —
  [`fail()`](https://gillescolling.com/restrictR/reference/fail.md)
  (error formatter), `eval_formula()`, `col_path()`, `check_no_na()`,
  `check_na_finite()`, `%||%`

### Step structure

Each step is a list with four fields: - `label` (character):
human-readable description for
[`print()`](https://rdrr.io/r/base/print.html) - `deps` (character
vector): context variable names required (extracted from formulas) -
`fields` (named list or NULL): step parameters for introspection - `fn`
(function(value, name, ctx)): the actual check; calls
[`fail()`](https://gillescolling.com/restrictR/reference/fail.md) on
error

### Error format

All validation errors go through `fail(path, message, found, at)`.
Format: `path: message`, with optional `Found:` and `At:` lines.
Column-level errors use `col_path(name, col)` to produce paths like
`newdata$x2`.

### Context / dependency system

Formula-based steps (e.g. `require_length_matches(~ nrow(newdata))`)
declare `deps` extracted via
[`all.vars()`](https://rdrr.io/r/base/allnames.html). At call time, the
validator checks all deps are present in `...`/`.ctx` before running any
steps. `eval_formula()` evaluates in a locked-down environment (parent =
[`baseenv()`](https://rdrr.io/r/base/environment.html)).

## Key Design Constraints

1.  No DSL, no operator overloading
2.  Composition via base pipe `|>` only (R \>= 4.1.0)
3.  Validators are callable functions (not data objects)
4.  Dependent rules use formulas with explicit context — never search
    parent frames
5.  Error messages must be path-aware
    (e.g. `newdata$x2: must be numeric`)
6.  Zero non-base dependencies at runtime

## CRAN Notes (for next update)

From CRAN reviewer Konstanze Lauseker: - Remove “for R” from the end of
the Title field in DESCRIPTION - Remove single quotes around function
name
[`restrict()`](https://gillescolling.com/restrictR/reference/restrict.md)
in Description field

## Adding a new `require_*()` step

1.  Add the function in `R/require.R` under the appropriate section
2.  Use `add_step(restriction, list(label, deps, fields, fn))` — follow
    existing patterns
3.  Use
    [`fail()`](https://gillescolling.com/restrictR/reference/fail.md)
    for errors — never raw [`stop()`](https://rdrr.io/r/base/stop.html)
    in step functions
4.  Add `@family` tag matching the section (type checks, structure
    checks, column checks, value checks, missingness checks)
5.  Add `@export` and run `devtools::document()`
6.  Add tests in the corresponding `tests/testthat/test-require-*.R`
    file
