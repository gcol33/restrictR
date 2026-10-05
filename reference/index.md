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
- [`fail()`](https://gillescolling.com/restrictR/reference/fail.md) :
  Format a Validation Error
- [`steps()`](https://gillescolling.com/restrictR/reference/steps.md) :
  List the Steps of a Validator

## Checking

Run a validator without throwing

- [`is_valid()`](https://gillescolling.com/restrictR/reference/is_valid.md)
  : Test Whether a Value Satisfies a Validator
- [`validation_errors()`](https://gillescolling.com/restrictR/reference/validation_errors.md)
  : Collect Validation Errors Without Throwing

## Type Checks

Validate value types

- [`require_df()`](https://gillescolling.com/restrictR/reference/require_df.md)
  : Require a Data Frame
- [`require_numeric()`](https://gillescolling.com/restrictR/reference/require_numeric.md)
  : Require Numeric Type
- [`require_integer()`](https://gillescolling.com/restrictR/reference/require_integer.md)
  : Require Integer Values
- [`require_character()`](https://gillescolling.com/restrictR/reference/require_character.md)
  : Require Character Type
- [`require_logical()`](https://gillescolling.com/restrictR/reference/require_logical.md)
  : Require Logical Type
- [`require_class()`](https://gillescolling.com/restrictR/reference/require_class.md)
  : Require a Specific Class

## Null & Missingness

Check for NULL, NA, and non-finite values

- [`require_not_null()`](https://gillescolling.com/restrictR/reference/require_not_null.md)
  : Require Non-NULL Value
- [`require_no_na()`](https://gillescolling.com/restrictR/reference/require_no_na.md)
  : Require No NA Values
- [`require_finite()`](https://gillescolling.com/restrictR/reference/require_finite.md)
  : Require Finite Values

## Structure Checks

Validate length, dimensions, names, columns, and order

- [`require_scalar()`](https://gillescolling.com/restrictR/reference/require_scalar.md)
  : Require Scalar Value
- [`require_named()`](https://gillescolling.com/restrictR/reference/require_named.md)
  : Require Named Value
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
- [`require_ncol_min()`](https://gillescolling.com/restrictR/reference/require_ncol_min.md)
  : Require Minimum Number of Columns
- [`require_ncol_matches()`](https://gillescolling.com/restrictR/reference/require_ncol_matches.md)
  : Require Column Count Matching an Expression
- [`require_dim()`](https://gillescolling.com/restrictR/reference/require_dim.md)
  : Require Exact Dimensions
- [`require_has_cols()`](https://gillescolling.com/restrictR/reference/require_has_cols.md)
  : Require Specific Columns
- [`require_names()`](https://gillescolling.com/restrictR/reference/require_names.md)
  : Require Names
- [`require_unique_names()`](https://gillescolling.com/restrictR/reference/require_unique_names.md)
  : Require Unique Names
- [`require_sorted()`](https://gillescolling.com/restrictR/reference/require_sorted.md)
  : Require Sorted Values

## Composition

Apply validators to columns and list elements, combine them, allow NULL

- [`require_col()`](https://gillescolling.com/restrictR/reference/require_col.md)
  : Validate a Data Frame Column with a Validator
- [`require_each()`](https://gillescolling.com/restrictR/reference/require_each.md)
  : Validate Every Element of a List
- [`require_fields()`](https://gillescolling.com/restrictR/reference/require_fields.md)
  : Validate Named Fields of a List
- [`require_valid()`](https://gillescolling.com/restrictR/reference/require_valid.md)
  : Include Another Validator's Steps
- [`require_any()`](https://gillescolling.com/restrictR/reference/require_any.md)
  : Require at Least One of Several Validators
- [`allow_null()`](https://gillescolling.com/restrictR/reference/allow_null.md)
  : Allow NULL

## Value Checks

Validate value ranges, set membership, and factor levels

- [`require_positive()`](https://gillescolling.com/restrictR/reference/require_positive.md)
  : Require Positive Values
- [`require_negative()`](https://gillescolling.com/restrictR/reference/require_negative.md)
  : Require Negative Values
- [`require_between()`](https://gillescolling.com/restrictR/reference/require_between.md)
  : Require Value in Range
- [`require_one_of()`](https://gillescolling.com/restrictR/reference/require_one_of.md)
  : Require Value from a Set
- [`require_contains()`](https://gillescolling.com/restrictR/reference/require_contains.md)
  : Require All of a Set of Values
- [`require_set_equal()`](https://gillescolling.com/restrictR/reference/require_set_equal.md)
  : Require the Same Set of Values
- [`require_levels()`](https://gillescolling.com/restrictR/reference/require_levels.md)
  : Require Factor Levels
- [`require_disjoint()`](https://gillescolling.com/restrictR/reference/require_disjoint.md)
  : Require Values Disjoint From Context
- [`require_unique()`](https://gillescolling.com/restrictR/reference/require_unique.md)
  : Require Unique Values

## Character Checks

Validate strings by pattern, length, and blankness

- [`require_pattern()`](https://gillescolling.com/restrictR/reference/require_pattern.md)
  : Require Strings Matching a Pattern
- [`require_nchar()`](https://gillescolling.com/restrictR/reference/require_nchar.md)
  : Require String Length
- [`require_nonempty()`](https://gillescolling.com/restrictR/reference/require_nonempty.md)
  : Require Non-Blank Strings

## File-System Checks

Validate input paths and output locations

- [`require_file_exists()`](https://gillescolling.com/restrictR/reference/require_file_exists.md)
  : Require Existing Files
- [`require_dir_exists()`](https://gillescolling.com/restrictR/reference/require_dir_exists.md)
  : Require Existing Directories
- [`require_readable()`](https://gillescolling.com/restrictR/reference/require_readable.md)
  : Require Readable Paths
- [`require_writable()`](https://gillescolling.com/restrictR/reference/require_writable.md)
  : Require Writable Paths

## Function Checks

Validate callback arguments

- [`require_function()`](https://gillescolling.com/restrictR/reference/require_function.md)
  : Require a Function

## Testing

testthat expectations that report validator messages

- [`expect_valid()`](https://gillescolling.com/restrictR/reference/expect_valid.md)
  : Expect a Value to Pass a Validator
- [`expect_invalid()`](https://gillescolling.com/restrictR/reference/expect_invalid.md)
  : Expect a Value to Fail a Validator
