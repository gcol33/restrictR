# Format a Validation Error

Produces a consistently formatted error message and stops execution.
Intended for use inside custom validation steps created with
[`require_custom()`](https://gillescolling.com/restrictR/reference/require_custom.md),
so they produce the same structured errors as built-in steps.

## Usage

``` r
fail(path, message, found = NULL, at = NULL)
```

## Arguments

- path:

  the full path (e.g. `"x"` or `"newdata$x2"`).

- message:

  the specific failure message.

- found:

  optional value to show on a `Found:` line.

- at:

  optional integer positions to show on an `At:` line.

## Value

No return value. Called for its side effect: it signals a classed
`restrictR_failure` condition (an error) carrying `path`, `message`, and
the optional `found` and `at` details.

## Details

Format: `path: message`, with optional `Found:` and `At:` lines.

## See also

Other core:
[`as_contract_block()`](https://gillescolling.com/restrictR/reference/as_contract_block.md),
[`as_contract_text()`](https://gillescolling.com/restrictR/reference/as_contract_text.md),
[`is_valid()`](https://gillescolling.com/restrictR/reference/is_valid.md),
[`require_custom()`](https://gillescolling.com/restrictR/reference/require_custom.md),
[`restrict()`](https://gillescolling.com/restrictR/reference/restrict.md),
[`validation_errors()`](https://gillescolling.com/restrictR/reference/validation_errors.md)

## Examples

``` r
# fail() signals an error; wrap in try() to show the formatted message
try(fail("x", "must be positive", found = -3, at = 2L))
#> Error : x: must be positive
#>   Found: -3
#>   At: 2
```
