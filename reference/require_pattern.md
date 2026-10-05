# Require Strings Matching a Pattern

Validates that every non-`NA` element of a character value matches a
regular expression. `Found:` shows the first element that does not match
and `At:` lists every offender.

## Usage

``` r
require_pattern(restriction, regex, fixed = FALSE, ignore_case = FALSE)
```

## Arguments

- restriction:

  a `restriction` object.

- regex:

  character(1) regular expression (extended syntax, as in
  [`grepl()`](https://rdrr.io/r/base/grep.html)).

- fixed:

  logical; if `TRUE`, `regex` is a literal substring.

- ignore_case:

  logical; if `TRUE`, matching ignores case. Not available with
  `fixed = TRUE`.

## Value

The modified `restriction` object.

## Details

A match anywhere in the string counts; anchor the pattern with `^` and
`$` to match the whole string. Non-character input fails with a type
error. `NA` elements are skipped; chain
[`require_no_na()`](https://gillescolling.com/restrictR/reference/require_no_na.md)
to reject them.

## See also

Other character checks:
[`require_nchar()`](https://gillescolling.com/restrictR/reference/require_nchar.md),
[`require_nonempty()`](https://gillescolling.com/restrictR/reference/require_nonempty.md)

## Examples

``` r
code <- restrict("code") |> require_character() |> require_pattern("^[A-Z]{3}$")
code(c("ABC", "XYZ"))
try(code(c("ABC", "xy")))
#> Error : code: must match pattern "^[A-Z]{3}$"
#>   Found: "xy"
#>   At: 2
```
