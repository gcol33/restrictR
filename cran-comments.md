## R CMD check results

0 errors | 0 warnings | 0 notes

## Test environments

* local: Windows 11, R 4.6.1
* win-builder: R-devel (2026-09-30 r90605) and R-release (4.6.1), Status: OK
* GitHub Actions: ubuntu-latest (R-devel, release, oldrel-1),
  macOS-latest (release), windows-latest (release)

## Changes in this version

This is a feature update (0.1.0 -> 0.3.0). The Title and Description no longer
end in "for R" and no longer single-quote the restrict() function name.
NEWS.md lists the changes in full. Main points:

* New steps for character, structure, set, file-system and function
  arguments, plus testthat expectations expect_valid() and expect_invalid().
* New combinators require_col(), require_each(), require_fields(),
  require_valid(), require_any() and allow_null().
* New .on_fail = "all" mode, is_valid(), validation_errors() and steps().
* require_col_numeric(), require_col_character(), require_col_between() and
  require_col_one_of() are replaced by require_col().

## Downstream dependencies

No reverse dependencies.
