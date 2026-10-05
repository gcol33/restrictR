# Require Readable Paths

Validates that every path of a character value exists and can be read,
judged by [`file.access()`](https://rdrr.io/r/base/file.access.html).

## Usage

``` r
require_readable(restriction)
```

## Arguments

- restriction:

  a `restriction` object.

## Value

The modified `restriction` object.

## Details

Non-character input fails with a type error. `NA` paths are skipped;
chain
[`require_no_na()`](https://gillescolling.com/restrictR/reference/require_no_na.md)
to reject them.

## See also

Other file checks:
[`require_dir_exists()`](https://gillescolling.com/restrictR/reference/require_dir_exists.md),
[`require_file_exists()`](https://gillescolling.com/restrictR/reference/require_file_exists.md),
[`require_writable()`](https://gillescolling.com/restrictR/reference/require_writable.md)
