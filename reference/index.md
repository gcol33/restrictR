# Package index

## Core

Create and inspect validators

- [`restrict()`](https://gillescolling.com/restrictR/reference/restrict.md)
  : Create a Composable Validator
- [`as_contract_text()`](https://gillescolling.com/restrictR/reference/as_contract_text.md)
  : Convert a Validator to Plain Text
- [`as_contract_block()`](https://gillescolling.com/restrictR/reference/as_contract_block.md)
  : Convert a Validator to a Multi-Line Block
- [`require_custom()`](https://gillescolling.com/restrictR/reference/require_custom.md)
  : Create a Custom Validation Step

## Type Checks

Validate value types

- [`require_df()`](https://gillescolling.com/restrictR/reference/require_df.md)
  : Require a Data Frame
- [`require_numeric()`](https://gillescolling.com/restrictR/reference/require_numeric.md)
  : Require Numeric Type
- [`require_integer()`](https://gillescolling.com/restrictR/reference/require_integer.md)
  : Require Integer Type
- [`require_character()`](https://gillescolling.com/restrictR/reference/require_character.md)
  : Require Character Type
- [`require_logical()`](https://gillescolling.com/restrictR/reference/require_logical.md)
  : Require Logical Type

## Missingness & Finiteness

Check for NA and non-finite values

- [`require_no_na()`](https://gillescolling.com/restrictR/reference/require_no_na.md)
  : Require No NA Values
- [`require_finite()`](https://gillescolling.com/restrictR/reference/require_finite.md)
  : Require Finite Values

## Structure Checks

Validate length, columns, and row counts

- [`require_length()`](https://gillescolling.com/restrictR/reference/require_length.md)
  : Require Specific Length
- [`require_length_min()`](https://gillescolling.com/restrictR/reference/require_length_min.md)
  : Require Minimum Length
- [`require_length_max()`](https://gillescolling.com/restrictR/reference/require_length_max.md)
  : Require Maximum Length
- [`require_length_matches()`](https://gillescolling.com/restrictR/reference/require_length_matches.md)
  : Require Length Matching an Expression
- [`require_nrow_min()`](https://gillescolling.com/restrictR/reference/require_nrow_min.md)
  : Require Minimum Number of Rows
- [`require_nrow_matches()`](https://gillescolling.com/restrictR/reference/require_nrow_matches.md)
  : Require Row Count Matching an Expression
- [`require_has_cols()`](https://gillescolling.com/restrictR/reference/require_has_cols.md)
  : Require Specific Columns

## Column-Level Checks

Validate individual columns with path-aware errors

- [`require_col_numeric()`](https://gillescolling.com/restrictR/reference/require_col_numeric.md)
  : Require Numeric Column
- [`require_col_character()`](https://gillescolling.com/restrictR/reference/require_col_character.md)
  : Require Character Column
- [`require_col_between()`](https://gillescolling.com/restrictR/reference/require_col_between.md)
  : Require Column Values in Range
- [`require_col_one_of()`](https://gillescolling.com/restrictR/reference/require_col_one_of.md)
  : Require Column Values from a Set

## Value Checks

Validate value ranges and set membership

- [`require_between()`](https://gillescolling.com/restrictR/reference/require_between.md)
  : Require Value in Range
- [`require_one_of()`](https://gillescolling.com/restrictR/reference/require_one_of.md)
  : Require Value from a Set
