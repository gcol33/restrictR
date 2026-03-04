# Create a Custom Validation Step

Allows advanced users to define their own validation step without
growing the package's built-in API surface. The step function receives
`(value, name, ctx)` and should call
[`testthat::fail()`](https://testthat.r-lib.org/reference/fail.html) on
validation failure.

## Usage

``` r
require_custom(restriction, label, fn, deps = character(0L))
```

## Arguments

- restriction:

  a `restriction` object.

- label:

  character(1) human-readable description for printing.

- fn:

  a function with signature `function(value, name, ctx)` that calls
  [`stop()`](https://rdrr.io/r/base/stop.html) or `restrictR:::fail()`
  on failure.

- deps:

  character vector of context names this step requires (default: none).

## Value

A new `restriction` object with the custom step appended.

## See also

Other core:
[`as_contract_block()`](https://gillescolling.com/restrictR/reference/as_contract_block.md),
[`as_contract_text()`](https://gillescolling.com/restrictR/reference/as_contract_text.md),
[`restrict()`](https://gillescolling.com/restrictR/reference/restrict.md)

## Examples

``` r
# Custom step: require all values to be unique
require_unique_id <- restrict("id") |>
  require_custom(
    label = "must contain unique values",
    fn = function(value, name, ctx) {
      dupes <- which(duplicated(value))
      if (length(dupes) > 0L) {
        stop(sprintf("%s: contains %d duplicate value(s)",
                     name, length(dupes)), call. = FALSE)
      }
    }
  )
```
