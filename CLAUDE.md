# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## Package Overview

Composable runtime contracts for R. Validators built from `require_*()`
building blocks, composed with base pipe `|>`.

## Commands

``` bash
# Full check
"/c/Program Files/R/R-4.6.1/bin/Rscript.exe" -e 'devtools::check(args = "--no-manual")'

# Document (regenerate NAMESPACE + man/)
"/c/Program Files/R/R-4.6.1/bin/Rscript.exe" -e 'devtools::document()'

# Run all tests
"/c/Program Files/R/R-4.6.1/bin/Rscript.exe" -e 'devtools::test()'

# Run a single test file
"/c/Program Files/R/R-4.6.1/bin/Rscript.exe" -e 'devtools::test(filter = "require-type")'
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
  `make_validator()`, `run_steps()` (the single step runner for
  “first”/“all” modes), `add_step()`,
  [`steps()`](https://gillescolling.com/restrictR/reference/steps.md),
  `print.restriction`, `as_contract_text/block()`,
  [`require_custom()`](https://gillescolling.com/restrictR/reference/require_custom.md)
- **`R/require.R`**: Type, missingness, length/row/column/dim, order and
  value steps. Shared builders: `count_bound_step()` /
  `count_matches_step()` (length, rows, columns), `sign_step()`
  (positive/negative)
- **`R/require-sets.R`**: One set-relation engine (`set_step()`,
  `set_mismatch()`) behind
  [`require_names()`](https://gillescolling.com/restrictR/reference/require_names.md),
  [`require_has_cols()`](https://gillescolling.com/restrictR/reference/require_has_cols.md),
  [`require_levels()`](https://gillescolling.com/restrictR/reference/require_levels.md),
  [`require_contains()`](https://gillescolling.com/restrictR/reference/require_contains.md),
  [`require_set_equal()`](https://gillescolling.com/restrictR/reference/require_set_equal.md);
  plus
  [`require_unique_names()`](https://gillescolling.com/restrictR/reference/require_unique_names.md),
  [`require_disjoint()`](https://gillescolling.com/restrictR/reference/require_disjoint.md)
- **`R/require-character.R`**:
  [`require_pattern()`](https://gillescolling.com/restrictR/reference/require_pattern.md),
  [`require_nchar()`](https://gillescolling.com/restrictR/reference/require_nchar.md),
  [`require_nonempty()`](https://gillescolling.com/restrictR/reference/require_nonempty.md)
  over `string_step()`
- **`R/require-files.R`**:
  [`require_file_exists()`](https://gillescolling.com/restrictR/reference/require_file_exists.md),
  [`require_dir_exists()`](https://gillescolling.com/restrictR/reference/require_dir_exists.md),
  [`require_readable()`](https://gillescolling.com/restrictR/reference/require_readable.md),
  [`require_writable()`](https://gillescolling.com/restrictR/reference/require_writable.md)
  over `path_step()`
- **`R/require-function.R`**:
  [`require_function()`](https://gillescolling.com/restrictR/reference/require_function.md)
- **`R/expect.R`**: testthat expectations
  [`expect_valid()`](https://gillescolling.com/restrictR/reference/expect_valid.md)
  /
  [`expect_invalid()`](https://gillescolling.com/restrictR/reference/expect_invalid.md)
  (testthat is Suggests, checked at call time)
- **`R/compose.R`**: Combinators that apply or combine whole validators
  —
  [`require_col()`](https://gillescolling.com/restrictR/reference/require_col.md),
  [`require_each()`](https://gillescolling.com/restrictR/reference/require_each.md),
  [`require_fields()`](https://gillescolling.com/restrictR/reference/require_fields.md)
  (built on `scoped_step()`),
  [`require_valid()`](https://gillescolling.com/restrictR/reference/require_valid.md),
  [`require_any()`](https://gillescolling.com/restrictR/reference/require_any.md),
  [`allow_null()`](https://gillescolling.com/restrictR/reference/allow_null.md)
- **`R/utils.R`**: Internal helpers — `new_step()`,
  [`fail()`](https://gillescolling.com/restrictR/reference/fail.md)
  (error formatter), `fail_values()`, `eval_formula()`,
  `formula_deps()`, `check_type()`, `col_path()`, `check_no_na()`,
  `check_na_finite()`, `%||%`

### Step structure

Each step is built by `new_step()` and is a list with four fields: -
`label` (character): human-readable description for
[`print()`](https://rdrr.io/r/base/print.html) - `deps` (character
vector): context variable names required (extracted from formulas) -
`fields` (named list or NULL): step parameters, exposed by
[`steps()`](https://gillescolling.com/restrictR/reference/steps.md) -
`fn` (function(value, name, ctx)): the actual check; calls
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
steps. `eval_formula()` evaluates in an environment holding the context
plus `.value`/`.name`; its parent is the formula’s own environment, so
functions resolve where the formula was written. Deps come from
`formula_deps()`, which walks the parse tree.

## Key Design Constraints

1.  No DSL, no operator overloading
2.  Composition via base pipe `|>` only (R \>= 4.1.0)
3.  Validators are callable functions (not data objects)
4.  Dependent rules use formulas with explicit context — never search
    parent frames
5.  Error messages must be path-aware
    (e.g. `newdata$x2: must be numeric`)
6.  Zero non-base dependencies at runtime

## Adding a new `require_*()` step

1.  Add the function in the file for its topic (`R/require.R`,
    `require-sets.R`, …). Prefer a call to a shared builder
    (`count_bound_step()`, `set_step()`, `string_step()`, `path_step()`)
    over a new closure
2.  Otherwise use
    `add_step(restriction, new_step(label, fn, deps, fields))`
3.  Use
    [`fail()`](https://gillescolling.com/restrictR/reference/fail.md)
    for errors — never raw [`stop()`](https://rdrr.io/r/base/stop.html)
    in step functions. The failure message is the label, or the label
    plus detail, never a second spelling
4.  Add `@family` tag matching the section (type checks, structure
    checks, value checks, missingness checks, character checks, file
    checks, function checks) and list the function in `_pkgdown.yml`
5.  Add `@export` and run `devtools::document()`
6.  Add tests in the corresponding `tests/testthat/test-require-*.R`
    file
