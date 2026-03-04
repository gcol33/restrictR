# restrictR Development Guide

## Package Overview

Composable runtime contracts for R. Validators built from `require_*()`
building blocks, composed with base pipe `|>`.

## Architecture

- **`restrict(name)`**: Constructor returning a callable `restriction`
  object (S3 class over a function)
- **`require_*()`**: Building blocks that take a restriction as first
  arg, add a validation step, return the modified restriction
- **`add_step()`**: Internal helper appending steps to a restriction
- **Steps**: Each step is a list with `description` (character),
  `depends_on` (character vector), and `check` (function(value, name,
  ctx))
- **Formula evaluation**: `eval_formula()` evaluates RHS in an
  environment built only from explicit `...` args (never searches parent
  frames)

## Key Design Constraints

1.  No DSL, no operator overloading
2.  Composition via base pipe `|>` only
3.  Validators are callable functions
4.  Dependent rules use formulas (`~ nrow(newdata)`) with explicit
    context
5.  Error messages must be path-aware
    (e.g. `newdata$x2 must be numeric`)
6.  No devtools/snapshots/registries required

## R CMD check

``` bash
"/mnt/c/Program Files/R/R-4.5.2/bin/Rscript.exe" -e 'devtools::check(args = "--no-manual")'
```

## Document & build

``` bash
"/mnt/c/Program Files/R/R-4.5.2/bin/Rscript.exe" -e 'devtools::document()'
"/mnt/c/Program Files/R/R-4.5.2/bin/Rscript.exe" -e 'devtools::test()'
```

## R \>= 4.1.0

Required for native pipe `|>`. No backports needed.
