#' Format a Validation Error
#'
#' Produces a consistently formatted error message and stops execution.
#'
#' @param name the validator name.
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
#' validator. Never searches parent frames.
#'
#' @param formula a one-sided formula (e.g. `~ nrow(newdata)`).
#' @param ctx named list of context values passed as `...` to the validator.
#' @param name validator name (for error messages).
#'
#' @return The evaluated result.
#'
#' @noRd
eval_formula <- function(formula, ctx, name) {
  expr <- formula[[2L]]
  env <- list2env(ctx, parent = baseenv())
  tryCatch(
    eval(expr, envir = env),
    error = function(e) {
      # Extract variable names from expression to hint at missing context
      vars <- all.vars(expr)
      missing_vars <- vars[!vars %in% names(ctx)]
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
