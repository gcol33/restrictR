# Require Writable Paths

Validates that every path of a character value can be written: an
existing file or directory must be writable, and a path that does not
exist yet needs a writable parent directory. Use it for output files and
directories.

## Usage

``` r
require_writable(restriction)
```

## Arguments

- restriction:

  a `restriction` object.

## Value

The modified `restriction` object.

## Details

Writability is judged by
[`file.access()`](https://rdrr.io/r/base/file.access.html). On Windows
it reflects the read-only attribute and not access control lists, so a
directory that is denied by permissions can still pass. The check cannot
tell whether the disk has room.

## See also

Other file checks:
[`require_dir_exists()`](https://gillescolling.com/restrictR/reference/require_dir_exists.md),
[`require_file_exists()`](https://gillescolling.com/restrictR/reference/require_file_exists.md),
[`require_readable()`](https://gillescolling.com/restrictR/reference/require_readable.md)

## Examples

``` r
out_dir <- restrict("out") |> require_writable()
out_dir(tempdir())
out_dir(file.path(tempdir(), "result.csv"))
```
