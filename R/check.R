# ---- Non-throwing validation ----

#' Collect Validation Errors Without Throwing
#'
#' Runs a validator against a value and returns the validation messages
#' instead of raising an error. Every step is checked (as with
#' `.on_fail = "all"`), so all violations are reported in one pass.
#'
#' @param validator a `restriction` object created by [restrict()].
#' @param value the value to validate.
#' @param ... context arguments passed to the validator (e.g. `newdata = df`),
#'   the same as a direct validator call.
#'
#' @return A character vector of failure messages, or `character(0)` if the
#'   value satisfies every step. Each element is the full path-aware message
#'   for one failing step.
#'
#' @details Only validation failures are caught. A usage error, such as a
#'   missing context dependency declared by a formula step, still propagates
#'   so the calling mistake is not silently reported as invalid data.
#'
#' @examples
#' v <- restrict("x") |> require_numeric() |> require_positive()
#' validation_errors(v, 5)       # character(0)
#' validation_errors(v, c(-1))   # one message
#'
#' @seealso [is_valid()] for a logical predicate.
#' @family core
#' @export
validation_errors <- function(validator, value, ...) {
  if (!inherits(validator, "restriction")) {
    stop("`validator` must be a restriction object created by restrict()",
         call. = FALSE)
  }
  tryCatch(
    {
      validator(value, ..., .on_fail = "all")
      character(0L)
    },
    restrictR_failures = function(c) {
      vapply(c$failures, conditionMessage, character(1L))
    }
  )
}


#' Test Whether a Value Satisfies a Validator
#'
#' Non-throwing predicate: returns `TRUE` when `value` passes every step of
#' `validator`, `FALSE` otherwise. Use it to branch on validity instead of
#' wrapping a validator call in [tryCatch()].
#'
#' @inheritParams validation_errors
#'
#' @return A length-1 logical.
#'
#' @details Like [validation_errors()], only validation failures are caught;
#'   a missing context dependency still raises so a calling mistake is not
#'   mistaken for invalid data.
#'
#' @examples
#' v <- restrict("x") |> require_numeric(no_na = TRUE)
#' is_valid(v, 1:5)        # TRUE
#' is_valid(v, c(1, NA))   # FALSE
#'
#' @seealso [validation_errors()] for the failure messages.
#' @family core
#' @export
is_valid <- function(validator, value, ...) {
  length(validation_errors(validator, value, ...)) == 0L
}
