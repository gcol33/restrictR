# Require String Length

Validates the number of characters of every non-`NA` element of a
character value.

## Usage

``` r
require_nchar(restriction, min = 0, max = Inf)
```

## Arguments

- restriction:

  a `restriction` object.

- min:

  minimum number of characters (default 0).

- max:

  maximum number of characters (default `Inf`).

## Value

The modified `restriction` object.

## Details

Length is counted in characters, not bytes. Non-character input fails
with a type error. `NA` elements are skipped; chain
[`require_no_na()`](https://gillescolling.com/restrictR/reference/require_no_na.md)
to reject them.

## See also

Other character checks:
[`require_nonempty()`](https://gillescolling.com/restrictR/reference/require_nonempty.md),
[`require_pattern()`](https://gillescolling.com/restrictR/reference/require_pattern.md)

## Examples

``` r
initials <- restrict("initials") |> require_nchar(min = 2, max = 3)
initials(c("AB", "ABC"))
try(initials("A"))
#> Error : initials: must have between 2 and 3 characters
#>   Found: "A" (1 character)
```
