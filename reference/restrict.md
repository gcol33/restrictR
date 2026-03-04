# Create a Composable Validator

Creates a callable validation object that accumulates checks via the
base pipe operator `|>`. The resulting object behaves like a function:
call it with a value to validate.

## Usage

``` r
restrict(name)
```

## Arguments

- name:

  character(1) name used in error messages (e.g. `"newdata"`).

## Value

A `restriction` object (callable function) with no validation steps.

## Calling convention

Validators accept `value` as the first argument, plus context via named
arguments in `...` or as a named list in `.ctx`:

    require_pred(out, newdata = df)
    require_pred(out, .ctx = list(newdata = df))

Named arguments in `...` take precedence over `.ctx` entries with the
same name. If a step declares dependencies (e.g.
`require_length_matches(~ nrow(newdata))`), the validator checks that
all required context is present before running any steps and errors
early if not.

## See also

Other core:
[`as_contract_block()`](https://gillescolling.com/restrictR/reference/as_contract_block.md),
[`as_contract_text()`](https://gillescolling.com/restrictR/reference/as_contract_text.md),
[`require_custom()`](https://gillescolling.com/restrictR/reference/require_custom.md)

## Examples

``` r
# Define a validator
require_positive <- restrict("x") |>
  require_numeric(no_na = TRUE) |>
  require_between(lower = 0, exclusive_lower = TRUE)

# Use it
require_positive(5)   # passes silently

# Compose with pipe
require_score <- restrict("score") |>
  require_numeric() |>
  require_length(1L) |>
  require_between(lower = 0, upper = 100)
```
