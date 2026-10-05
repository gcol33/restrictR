# Changelog

## restrictR 0.3.0

- New character steps
  [`require_pattern()`](https://gillescolling.com/restrictR/reference/require_pattern.md),
  [`require_nchar()`](https://gillescolling.com/restrictR/reference/require_nchar.md)
  and
  [`require_nonempty()`](https://gillescolling.com/restrictR/reference/require_nonempty.md).
- New structure steps
  [`require_ncol_min()`](https://gillescolling.com/restrictR/reference/require_ncol_min.md),
  [`require_ncol_matches()`](https://gillescolling.com/restrictR/reference/require_ncol_matches.md),
  [`require_dim()`](https://gillescolling.com/restrictR/reference/require_dim.md),
  [`require_names()`](https://gillescolling.com/restrictR/reference/require_names.md)
  (modes `"identical"`, `"subset"`, `"superset"`, `"permutation"`),
  [`require_unique_names()`](https://gillescolling.com/restrictR/reference/require_unique_names.md)
  and
  [`require_sorted()`](https://gillescolling.com/restrictR/reference/require_sorted.md).
  [`require_has_cols()`](https://gillescolling.com/restrictR/reference/require_has_cols.md)
  is the `"superset"` case of the same comparison. A matrix is checked
  with `require_class("matrix")`.
- New set and factor steps
  [`require_contains()`](https://gillescolling.com/restrictR/reference/require_contains.md),
  [`require_set_equal()`](https://gillescolling.com/restrictR/reference/require_set_equal.md),
  [`require_levels()`](https://gillescolling.com/restrictR/reference/require_levels.md)
  and
  [`require_disjoint()`](https://gillescolling.com/restrictR/reference/require_disjoint.md).
  [`require_one_of()`](https://gillescolling.com/restrictR/reference/require_one_of.md)
  is the subset test for vectors.
- New file-system steps
  [`require_file_exists()`](https://gillescolling.com/restrictR/reference/require_file_exists.md),
  [`require_dir_exists()`](https://gillescolling.com/restrictR/reference/require_dir_exists.md),
  [`require_readable()`](https://gillescolling.com/restrictR/reference/require_readable.md)
  and
  [`require_writable()`](https://gillescolling.com/restrictR/reference/require_writable.md).
- New
  [`require_function()`](https://gillescolling.com/restrictR/reference/require_function.md)
  checks callback arguments by argument names or call signature.
  [`require_custom()`](https://gillescolling.com/restrictR/reference/require_custom.md)
  now requires a function callable with three positional arguments.
- New testthat expectations
  [`expect_valid()`](https://gillescolling.com/restrictR/reference/expect_valid.md)
  and
  [`expect_invalid()`](https://gillescolling.com/restrictR/reference/expect_invalid.md).
- New
  [`steps()`](https://gillescolling.com/restrictR/reference/steps.md)
  returns the label, context dependencies and parameters of every step
  as a data.frame.
- [`require_nrow_min()`](https://gillescolling.com/restrictR/reference/require_nrow_min.md)
  and
  [`require_nrow_matches()`](https://gillescolling.com/restrictR/reference/require_nrow_matches.md)
  also accept matrices.
- [`require_integer()`](https://gillescolling.com/restrictR/reference/require_integer.md)
  rejects `Inf` and `-Inf` in both modes.
- Formula steps no longer treat the member name in `ref$id` as a context
  dependency, nor `.value` and `.name`.
- The failure message of a step is its label, so the two cannot differ:
  [`require_unique()`](https://gillescolling.com/restrictR/reference/require_unique.md)
  reports `must contain unique values` and
  [`require_one_of()`](https://gillescolling.com/restrictR/reference/require_one_of.md)
  reports `must be one of: ...`.
- New `require_col(col, validator)` lifts any validator onto a
  data.frame column with path-aware errors (`newdata$age: ...`). It
  replaces `require_col_numeric()`, `require_col_character()`,
  `require_col_between()` and `require_col_one_of()`, which are removed:
  write `require_col("x", restrict("x") |> require_numeric())` instead.
- New
  [`require_each()`](https://gillescolling.com/restrictR/reference/require_each.md)
  and
  [`require_fields()`](https://gillescolling.com/restrictR/reference/require_fields.md)
  validate every element, or named fields, of a list (`layers[[2]]`,
  `opts$alpha`).
- New
  [`allow_null()`](https://gillescolling.com/restrictR/reference/allow_null.md)
  marks an optional argument: `NULL` passes, otherwise all steps apply.
- New
  [`require_valid()`](https://gillescolling.com/restrictR/reference/require_valid.md)
  includes another validator’s steps and
  [`require_any()`](https://gillescolling.com/restrictR/reference/require_any.md)
  accepts a value that satisfies at least one alternative.
- [`require_between()`](https://gillescolling.com/restrictR/reference/require_between.md)
  now accepts `Date`, `POSIXct`, `difftime` and ordered factor values
  and bounds.
- [`require_nrow_min()`](https://gillescolling.com/restrictR/reference/require_nrow_min.md)
  and
  [`require_nrow_matches()`](https://gillescolling.com/restrictR/reference/require_nrow_matches.md)
  fail with a path-aware error on non-data.frame input, and
  [`require_length_matches()`](https://gillescolling.com/restrictR/reference/require_length_matches.md)
  /
  [`require_nrow_matches()`](https://gillescolling.com/restrictR/reference/require_nrow_matches.md)
  reject formulas that do not evaluate to a single non-NA number.
- With `.on_fail = "all"`, a type or structure failure on a path is
  reported once instead of once per step. The aggregated message lists
  at most 20 failures; the full list stays in `$failures`.

## restrictR 0.2.0

- New step
  [`require_class()`](https://gillescolling.com/restrictR/reference/require_class.md):
  assert any class (e.g. `factor`, `Date`, `POSIXct`, fitted-model
  objects) through one verb, with `exact` for a strict first-class
  match.
- Validators gain `.on_fail = "all"`: run every step and report all
  violations in one aggregated error instead of stopping at the first.
- New non-throwing helpers
  [`is_valid()`](https://gillescolling.com/restrictR/reference/is_valid.md)
  (logical predicate) and
  [`validation_errors()`](https://gillescolling.com/restrictR/reference/validation_errors.md)
  (character vector of failure messages, empty when the value passes).
- Formula steps
  ([`require_length_matches()`](https://gillescolling.com/restrictR/reference/require_length_matches.md),
  [`require_nrow_matches()`](https://gillescolling.com/restrictR/reference/require_nrow_matches.md))
  now resolve non-base functions such as
  [`median()`](https://rdrr.io/r/stats/median.html),
  [`sd()`](https://rdrr.io/r/stats/sd.html), and package exports. Data
  names are still taken only from explicit context.
- [`fail()`](https://gillescolling.com/restrictR/reference/fail.md) now
  signals a structured `restrictR_failure` condition carrying `path`,
  `found`, and `at`, so failures can be collected and inspected
  programmatically.

## restrictR 0.1.2

- New steps:
  [`require_scalar()`](https://gillescolling.com/restrictR/reference/require_scalar.md),
  [`require_not_null()`](https://gillescolling.com/restrictR/reference/require_not_null.md),
  [`require_unique()`](https://gillescolling.com/restrictR/reference/require_unique.md),
  [`require_named()`](https://gillescolling.com/restrictR/reference/require_named.md).
- New steps:
  [`require_positive()`](https://gillescolling.com/restrictR/reference/require_positive.md)
  and
  [`require_negative()`](https://gillescolling.com/restrictR/reference/require_negative.md)
  with `strict` argument (non-strict by default).
- [`require_integer()`](https://gillescolling.com/restrictR/reference/require_integer.md)
  gains a `strict` argument. Default (`strict = FALSE`) accepts any
  numeric whole number; `strict = TRUE` requires the R `integer` type.

## restrictR 0.1.1

- Export
  [`fail()`](https://gillescolling.com/restrictR/reference/fail.md) so
  custom steps produce canonical structured errors.
- [`as_contract_text()`](https://gillescolling.com/restrictR/reference/as_contract_text.md)
  now capitalizes every sentence, not just the first.
- [`require_between()`](https://gillescolling.com/restrictR/reference/require_between.md)
  and
  [`require_one_of()`](https://gillescolling.com/restrictR/reference/require_one_of.md)
  omit the `At:` line for scalar values where it adds no information.
- Vignette: added “Data Frame with Mixed Constraints” section, surfaced
  immutability in the overview, updated custom step examples to use
  [`fail()`](https://gillescolling.com/restrictR/reference/fail.md).
- Documentation: tightened prose in the overview and examples.

## restrictR 0.1.0

CRAN release: 2026-03-09

- Initial release.
- Core constructor:
  [`restrict()`](https://gillescolling.com/restrictR/reference/restrict.md)
  for building composable validators.
- Building blocks:
  [`require_df()`](https://gillescolling.com/restrictR/reference/require_df.md),
  [`require_numeric()`](https://gillescolling.com/restrictR/reference/require_numeric.md),
  [`require_character()`](https://gillescolling.com/restrictR/reference/require_character.md),
  [`require_length()`](https://gillescolling.com/restrictR/reference/require_length.md),
  [`require_length_matches()`](https://gillescolling.com/restrictR/reference/require_length_matches.md),
  [`require_nrow_min()`](https://gillescolling.com/restrictR/reference/require_nrow_min.md),
  [`require_has_cols()`](https://gillescolling.com/restrictR/reference/require_has_cols.md),
  `require_col_numeric()`, `require_col_character()`,
  `require_col_range()`, `require_range()`,
  [`require_one_of()`](https://gillescolling.com/restrictR/reference/require_one_of.md).
- Dependent validation via one-sided formulas with explicit context
  passing.
- Path-aware error messages (e.g. `newdata$x2 must be numeric`).
- [`as_contract_text()`](https://gillescolling.com/restrictR/reference/as_contract_text.md)
  for roxygen-compatible documentation.
