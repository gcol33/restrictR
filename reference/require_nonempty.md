# Require Non-Blank Strings

Validates that no non-`NA` element of a character value is empty or made
of whitespace only.

## Usage

``` r
require_nonempty(restriction)
```

## Arguments

- restriction:

  a `restriction` object.

## Value

The modified `restriction` object.

## Details

Non-character input fails with a type error. `NA` elements are skipped;
chain
[`require_no_na()`](https://gillescolling.com/restrictR/reference/require_no_na.md)
to reject them.

## See also

Other character checks:
[`require_nchar()`](https://gillescolling.com/restrictR/reference/require_nchar.md),
[`require_pattern()`](https://gillescolling.com/restrictR/reference/require_pattern.md)

## Examples

``` r
label <- restrict("label") |> require_nonempty()
label(c("a", "b"))
try(label(c("a", " ")))
#> Error : label: must not contain blank strings
#>   Found: " "
#>   At: 2
```
