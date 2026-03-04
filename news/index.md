# Changelog

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
