#' Format a Validation Error
#'
#' Produces a consistently formatted error message and stops execution.
#' Intended for use inside custom validation steps created with
#' [require_custom()], so they produce the same structured errors as built-in
#' steps.
#'
#' Format: `path: message`, with optional `Found:` and `At:` lines.
#'
#' @param path the full path (e.g. `"x"` or `"newdata$x2"`).
#' @param message the specific failure message.
#' @param found optional value to show on a `Found:` line.
#' @param at optional integer positions to show on an `At:` line.
#'
#' @examples
#' \dontrun{
#' fail("x", "must be positive", found = -3, at = 2L)
#' # Error: x: must be positive
#' #   Found: -3
#' #   At: 2
#' }
#'
#' @family core
#' @export
fail <- function(path, message, found = NULL, at = NULL) {
  stop(restrictR_failure(path, message, found = found, at = at))
}


#' Build a Structured Validation-Failure Condition
#'
#' Creates the classed condition raised by [fail()]. Carries both the
#' formatted message and the structured fields (`path`, `detail`, `found`,
#' `at`) so callers can collect failures (`.on_fail = "all"`) or inspect them
#' programmatically without parsing strings.
#'
#' @inheritParams fail
#'
#' @return A condition of class `c("restrictR_failure", "error", "condition")`.
#'
#' @noRd
restrictR_failure <- function(path, message, found = NULL, at = NULL) {
  msg <- sprintf("%s: %s", path, message)
  if (!is.null(found)) {
    msg <- paste0(msg, "\n  Found: ", found)
  }
  if (!is.null(at)) {
    if (length(at) <= 5L) {
      msg <- paste0(msg, "\n  At: ", paste(at, collapse = ", "))
    } else {
      msg <- paste0(msg, sprintf("\n  At: %s (and %d more)",
                                 paste(at[1:5], collapse = ", "),
                                 length(at) - 5L))
    }
  }
  structure(
    class = c("restrictR_failure", "error", "condition"),
    list(message = msg, call = NULL,
         path = path, detail = message, found = found, at = at)
  )
}


#' Combine Several Validation Failures
#'
#' Aggregates the individual `restrictR_failure` conditions collected in
#' `.on_fail = "all"` mode into a single error whose message lists every
#' `path: message`. The component conditions are retained in `$failures` for
#' programmatic inspection.
#'
#' @param failures a list of `restrictR_failure` conditions.
#'
#' @return A condition of class `c("restrictR_failures", "error", "condition")`.
#'
#' @noRd
restrictR_failures <- function(failures) {
  n <- length(failures)
  header <- sprintf("%d validation failure%s:", n, if (n == 1L) "" else "s")
  body <- paste(vapply(failures, conditionMessage, character(1L)),
                collapse = "\n")
  structure(
    class = c("restrictR_failures", "error", "condition"),
    list(message = paste0(header, "\n", body), call = NULL,
         failures = failures)
  )
}


#' Evaluate a Formula in Explicit Context
#'
#' Evaluates the RHS of a formula using only the named arguments passed to the
#' validator. Never searches parent frames. The evaluation environment includes:
#' - All named `...` arguments from the validator call (e.g. `newdata`)
#' - `.value`: the value being validated
#' - `.name`: the restriction name
#'
#' @param formula a one-sided formula (e.g. `~ nrow(newdata)`).
#' @param value the value being validated.
#' @param name the restriction name.
#' @param ctx named list of context values passed as `...` to the validator.
#'
#' @return The evaluated result.
#'
#' @noRd
eval_formula <- function(formula, value, name, ctx) {
  expr <- formula[[2L]]
  env_data <- c(ctx, list(.value = value, .name = name))
  # Parent is the formula's own environment so functions (median, sd, package
  # exports) resolve from where the formula was written. Data names are not
  # silently picked up from it: every variable in the formula is a declared
  # dep, enforced present in `ctx` (the child env) before this runs, so the
  # explicit binding always shadows the parent.
  env <- list2env(env_data, parent = environment(formula) %||% baseenv())
  tryCatch(
    eval(expr, envir = env),
    error = function(e) {
      vars <- all.vars(expr)
      missing_vars <- vars[!vars %in% names(env_data)]
      hint <- if (length(missing_vars) > 0L) {
        sprintf(
          "; pass `%s` as a named argument to the validator",
          paste(missing_vars, collapse = "`, `")
        )
      } else {
        ""
      }
      fail(name, sprintf(
        "cannot evaluate `%s`: %s%s",
        deparse(expr), conditionMessage(e), hint
      ))
    }
  )
}


#' Format Column Path
#'
#' Creates a path-aware name like `newdata$x2`.
#'
#' @param name the validator name.
#' @param col the column name.
#'
#' @return character(1)
#'
#' @noRd
col_path <- function(name, col) {
  sprintf("%s$%s", name, col)
}


#' Extract a Data Frame Column with Path-Aware Guards
#'
#' Shared helper for all column-level checks. Confirms the value is a
#' data.frame and the column exists before returning the column, so callers
#' never index a non-data.frame and produce an opaque base-R error.
#'
#' @param value the value being validated.
#' @param col the column name.
#' @param name the validator name (used for error paths).
#'
#' @return the extracted column.
#'
#' @noRd
get_col <- function(value, col, name) {
  if (!is.data.frame(value)) {
    fail(name, sprintf('must be a data.frame to check column "%s", got %s',
                       col, class(value)[1L]))
  }
  x <- value[[col]]
  if (is.null(x)) {
    fail(name, sprintf('column "%s" does not exist', col))
  }
  x
}


#' Require Numeric Type
#'
#' Shared guard used by every check that compares with `<`/`>`/etc. Fails with
#' a clear type error before any comparison, so a non-numeric input never falls
#' through to R's coercion rules.
#'
#' @param x the value to check.
#' @param path the full path for error messages.
#'
#' @noRd
check_numeric <- function(x, path) {
  if (!is.numeric(x)) {
    fail(path, sprintf("must be numeric, got %s", class(x)[1L]))
  }
}


#' Check for NA Values
#'
#' Shared helper for NA checking across type and column validators.
#'
#' @param x the vector to check.
#' @param path the full path for error messages (e.g. `"x"` or `"newdata$x2"`).
#'
#' @noRd
check_no_na <- function(x, path) {
  na_pos <- which(is.na(x))
  if (length(na_pos) > 0L) {
    fail(path, "must not contain NA", at = na_pos)
  }
}


#' Check for NA and Non-Finite Values
#'
#' Shared helper used by `require_numeric()` and `require_col_numeric()`.
#'
#' @param x the numeric vector to check.
#' @param path the full path for error messages.
#' @param no_na logical; check for NA.
#' @param finite logical; check for non-finite values.
#'
#' @noRd
check_na_finite <- function(x, path, no_na, finite) {
  if (no_na) check_no_na(x, path)
  if (finite) {
    non_finite <- which(!is.finite(x))
    if (no_na) non_finite <- setdiff(non_finite, which(is.na(x)))
    if (length(non_finite) > 0L) {
      fail(path, "must be finite", at = non_finite)
    }
  }
}


#' Null-coalescing operator
#'
#' @noRd
`%||%` <- function(x, y) if (is.null(x)) y else x
