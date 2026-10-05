# ---- testthat expectations ----

#' Check That testthat Is Available
#'
#' @param fn name of the calling expectation, for the error message.
#'
#' @noRd
check_testthat <- function(fn) {
  if (!requireNamespace("testthat", quietly = TRUE)) {
    stop(sprintf("`%s()` needs the testthat package", fn), call. = FALSE)
  }
}


#' Expect a Value to Pass a Validator
#'
#' testthat expectation that reports the validator's own messages when the
#' value is invalid, so a failing test shows `newdata$x2: must be numeric`
#' rather than a generic "error thrown".
#'
#' @param validator a `restriction` object created by [restrict()].
#' @param value the value to validate.
#' @param ... context arguments passed to the validator (e.g. `newdata = df`).
#'
#' @details Requires the testthat package, which is checked when the
#'   expectation runs. Every violation is reported, as with
#'   [validation_errors()].
#'
#' @return `value`, invisibly.
#'
#' @examples
#' if (requireNamespace("testthat", quietly = TRUE)) {
#'   v <- restrict("x") |> require_numeric()
#'   expect_valid(v, 1:3)
#' }
#'
#' @seealso [expect_invalid()]
#' @family testthat expectations
#' @export
expect_valid <- function(validator, value, ...) {
  check_testthat("expect_valid")
  errors <- validation_errors(validator, value, ...)
  testthat::expect(
    length(errors) == 0L,
    sprintf("`%s` is invalid:\n%s", restriction_name(validator),
            paste(errors, collapse = "\n")),
    trace_env = parent.frame()
  )
  invisible(value)
}


#' Expect a Value to Fail a Validator
#'
#' testthat expectation that the value violates the validator, optionally with
#' a message matching a regular expression.
#'
#' @inheritParams expect_valid
#' @param regexp optional regular expression the failure messages must match.
#'   All messages are joined with newlines before matching.
#'
#' @details Requires the testthat package, which is checked when the
#'   expectation runs. A missing context dependency is a usage error and
#'   propagates.
#'
#' @return `value`, invisibly.
#'
#' @examples
#' if (requireNamespace("testthat", quietly = TRUE)) {
#'   v <- restrict("x") |> require_numeric()
#'   expect_invalid(v, "a", regexp = "must be numeric")
#' }
#'
#' @seealso [expect_valid()]
#' @family testthat expectations
#' @export
expect_invalid <- function(validator, value, ..., regexp = NULL) {
  check_testthat("expect_invalid")
  errors <- validation_errors(validator, value, ...)
  name <- restriction_name(validator)
  joined <- paste(errors, collapse = "\n")
  if (length(errors) == 0L) {
    ok <- FALSE
    msg <- sprintf("`%s` accepted the value, expected a failure", name)
  } else {
    ok <- is.null(regexp) || grepl(regexp, joined)
    msg <- sprintf("`%s` failed, but no message matches `%s`:\n%s",
                   name, regexp, joined)
  }
  testthat::expect(ok, msg, trace_env = parent.frame())
  invisible(value)
}
