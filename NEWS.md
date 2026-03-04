# restrictR 0.1.0

* Initial release.
* Core constructor: `restrict()` for building composable validators.
* Building blocks: `require_df()`, `require_numeric()`, `require_character()`,
  `require_length()`, `require_length_matches()`, `require_nrow_min()`,
  `require_has_cols()`, `require_col_numeric()`, `require_col_character()`,
  `require_col_range()`, `require_range()`, `require_one_of()`.
* Dependent validation via one-sided formulas with explicit context passing.
* Path-aware error messages (e.g. `newdata$x2 must be numeric`).
* `as_contract_text()` for roxygen-compatible documentation.
