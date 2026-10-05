# Require a Function

Validates that the value is a function, optionally with named arguments
or a call signature. Meant for callback arguments.

## Usage

``` r
require_function(restriction, args = NULL, nargs = NULL)
```

## Arguments

- restriction:

  a `restriction` object.

- args:

  optional character vector of argument names the function must declare.

- nargs:

  optional whole number: the function must be callable with exactly this
  many positional arguments, so it declares at least that many (or
  `...`) and requires no more.

## Value

The modified `restriction` object.

## Details

`args` looks at the declared formals only: a function declaring `...`
does not satisfy a named argument.

## Examples

``` r
callback <- restrict("fn") |> require_function(nargs = 2L)
callback(function(x, y) x + y)
try(callback(function(x) x))
#> Error : fn: must be a function callable with 2 positional arguments
#>   Found: function(x)
```
