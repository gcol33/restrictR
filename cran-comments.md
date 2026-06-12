## R CMD check results

0 errors | 0 warnings | 0 notes

## Test environments

* local: Windows 11, R 4.6.0
* win-builder: R-devel and R-release
* GitHub Actions: ubuntu-latest (R-devel, release, oldrel-1),
  macOS-latest (release), windows-latest (release)

## Changes in this version

This is a feature update (0.1.0 -> 0.2.0):

* New step require_class() for asserting arbitrary classes.
* Validators gain a .on_fail = "all" mode that reports every violation in
  one error instead of stopping at the first.
* New non-throwing helpers is_valid() and validation_errors().
* Formula-based steps now resolve non-base functions.

It also addresses the previous reviewer requests: the Title no longer ends
with "for R", and the Description no longer single-quotes the restrict()
function name.

## Downstream dependencies

No reverse dependencies.
