# Changelog

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
- README: tightened prose, removed AI-ish phrasing.

## restrictR 0.1.0

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
  [`require_col_numeric()`](https://gillescolling.com/restrictR/reference/require_col_numeric.md),
  [`require_col_character()`](https://gillescolling.com/restrictR/reference/require_col_character.md),
  `require_col_range()`, `require_range()`,
  [`require_one_of()`](https://gillescolling.com/restrictR/reference/require_one_of.md).
- Dependent validation via one-sided formulas with explicit context
  passing.
- Path-aware error messages (e.g. `newdata$x2 must be numeric`).
- [`as_contract_text()`](https://gillescolling.com/restrictR/reference/as_contract_text.md)
  for roxygen-compatible documentation.
