#' Format a Validation Error
#'
#' Produces a consistently formatted error message and stops execution.
#'
#' @param name the validator name (or path like `newdata$x2`).
#' @param message the specific failure message.
#'
#' @noRd
fail <- function(name, message) {
  stop(
    sprintf("`%s` failed validation\n  \u2716 %s", name, message),
    call. = FALSE
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
  env <- list2env(env_data, parent = baseenv())
  tryCatch(
    eval(expr, envir = env),
    error = function(e) {
      vars <- all.vars(expr)
      missing_vars <- vars[!vars %in% names(env_data)]
      hint <- if (length(missing_vars) > 0L) {
        sprintf(
          "\n  \u2139 pass `%s` as a named argument to the validator",
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
#' @param name the validator name (used in `fail()` header).
#' @param prefix optional prefix for the message body (e.g. `"newdata$x2"`).
#'   If `NULL`, message starts directly with "must".
#'
#' @noRd
check_no_na <- function(x, name, prefix = NULL) {
  na_count <- sum(is.na(x))
  if (na_count > 0L) {
    pos <- which(is.na(x))
    pos_msg <- if (length(pos) <= 5L) {
      paste("at position", paste(pos, collapse = ", "))
    } else {
      sprintf("at positions %s, ... (%d total)",
              paste(pos[1:5], collapse = ", "), na_count)
    }
    pfx <- if (!is.null(prefix)) paste0(prefix, " ") else ""
    fail(name, sprintf("%smust not contain NA values (%d NA found %s)",
                       pfx, na_count, pos_msg))
  }
}


#' Check for NA and Non-Finite Values
#'
#' Shared helper used by `require_numeric()` and `require_col_numeric()`.
#'
#' @param x the numeric vector to check.
#' @param name the validator name (used in `fail()` header).
#' @param no_na logical; check for NA.
#' @param finite logical; check for non-finite values.
#' @param prefix optional prefix for the message body (e.g. `"newdata$x2"`).
#'
#' @noRd
check_na_finite <- function(x, name, no_na, finite, prefix = NULL) {
  if (no_na) check_no_na(x, name, prefix)
  if (finite) {
    non_finite <- which(!is.finite(x))
    if (no_na) non_finite <- setdiff(non_finite, which(is.na(x)))
    if (length(non_finite) > 0L) {
      pos_msg <- if (length(non_finite) <= 5L) {
        paste("at position", paste(non_finite, collapse = ", "))
      } else {
        sprintf("at positions %s, ... (%d total)",
                paste(non_finite[1:5], collapse = ", "),
                length(non_finite))
      }
      pfx <- if (!is.null(prefix)) paste0(prefix, " ") else ""
      fail(name, sprintf(
        "%smust be finite (%d non-finite value %s)",
        pfx, length(non_finite), pos_msg
      ))
    }
  }
}


#' Null-coalescing operator
#'
#' @noRd
`%||%` <- function(x, y) if (is.null(x)) y else x
