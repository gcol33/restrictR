# Require Existing Files

Validates that every path of a character value exists and is a file.
`Found:` shows the normalized path of the first offender, so a relative
path resolved against the wrong working directory is visible.

## Usage

``` r
require_file_exists(restriction, extension = NULL)
```

## Arguments

- restriction:

  a `restriction` object.

- extension:

  optional character vector of accepted extensions, with or without the
  leading dot, compared case-insensitively. Adds a second step that
  checks the extension.

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
[`require_readable()`](https://gillescolling.com/restrictR/reference/require_readable.md),
[`require_writable()`](https://gillescolling.com/restrictR/reference/require_writable.md)

## Examples

``` r
csv_in <- restrict("path") |> require_file_exists(extension = "csv")
tmp <- tempfile(fileext = ".csv")
invisible(file.create(tmp))
csv_in(tmp)
try(csv_in(file.path(tempdir(), "missing.csv")))
#> Error : path: must be an existing file
#>   Found: "/tmp/RtmpXbQFpW/missing.csv"
```
