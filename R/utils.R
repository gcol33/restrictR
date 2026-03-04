#' Format a Validation Error
#'
#' Produces a consistently formatted error message and stops execution.
#' Format: `path: message`, with optional `Found:` and `At:` lines.
#'
#' @param path the full path (e.g. `"x"` or `"newdata$x2"`).
#' @param message the specific failure message.
#' @param found optional value to show on a `Found:` line.
#' @param at optional integer positions to show on an `At:` line.
#'
#' @noRd
fail <- function(path, message, found = NULL, at = NULL) {
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
  stop(msg, call. = FALSE)
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
  env <- list2env(env_data, parent = baseenv())
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
