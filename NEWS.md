# restrictR 0.1.2

* New steps: `require_scalar()`, `require_not_null()`, `require_unique()`,
  `require_named()`.
* New steps: `require_positive()` and `require_negative()` with `strict`
  argument (non-strict by default).
* `require_integer()` gains a `strict` argument. Default (`strict = FALSE`)
  accepts any numeric whole number; `strict = TRUE` requires the R `integer`
  type.

# restrictR 0.1.1

* Export `fail()` so custom steps produce canonical structured errors.
* `as_contract_text()` now capitalizes every sentence, not just the first.
* `require_between()` and `require_one_of()` omit the `At:` line for scalar
  values where it adds no information.
* Vignette: added "Data Frame with Mixed Constraints" section, surfaced
  immutability in the overview, updated custom step examples to use `fail()`.
* README: tightened prose, removed AI-ish phrasing.

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
