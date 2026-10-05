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
#' @return No return value. Called for its side effect: it signals a classed
#'   `restrictR_failure` condition (an error) carrying `path`, `message`, and
#'   the optional `found` and `at` details.
#'
#' @examples
#' # fail() signals an error; wrap in try() to show the formatted message
#' try(fail("x", "must be positive", found = -3, at = 2L))
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
#' @param precondition logical; if `TRUE` the condition also inherits from
#'   `restrictR_precondition`: a type or structure guard that other steps on the
#'   same path rely on. In `.on_fail = "all"` mode only the first precondition
#'   failure per path is reported.
#'
#' @return A condition of class `c("restrictR_failure", "error", "condition")`,
#'   prefixed with `"restrictR_precondition"` for precondition failures.
#'
#' @noRd
restrictR_failure <- function(path, message, found = NULL, at = NULL,
                              precondition = FALSE) {
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
    class = c(if (precondition) "restrictR_precondition",
              "restrictR_failure", "error", "condition"),
    list(message = msg, call = NULL,
         path = path, detail = message, found = found, at = at)
  )
}


#' Signal a Precondition Failure
#'
#' Like [fail()], for type and structure guards that value-level steps depend
#' on. Used by the shared guards and the built-in type steps.
#'
#' @inheritParams fail
#'
#' @noRd
fail_precondition <- function(path, message, found = NULL, at = NULL) {
  stop(restrictR_failure(path, message, found = found, at = at,
                         precondition = TRUE))
}


#' Combine Several Validation Failures
#'
#' Aggregates the individual `restrictR_failure` conditions collected in
#' `.on_fail = "all"` mode into a single error whose message lists every
#' `path: message`. The component conditions are retained in `$failures` for
#' programmatic inspection.
#'
#' @param failures a list of `restrictR_failure` conditions.
#' @param max_shown maximum number of failures written into the message; the
#'   condition keeps all of them in `$failures`.
#'
#' @return A condition of class `c("restrictR_failures", "error", "condition")`.
#'
#' @noRd
restrictR_failures <- function(failures, max_shown = 20L) {
  n <- length(failures)
  header <- sprintf("%d validation failure%s:", n, if (n == 1L) "" else "s")
  shown <- failures[seq_len(min(n, max_shown))]
  body <- paste(vapply(shown, conditionMessage, character(1L)),
                collapse = "\n")
  if (n > max_shown) {
    body <- paste0(body, sprintf("\n... and %d more", n - max_shown))
  }
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


#' Require a Data Frame
#'
#' Shared guard for every check that indexes rows or columns. Fails with a
#' path-aware precondition error so a non-data.frame input never reaches
#' `nrow()` or `[[`.
#'
#' @param value the value being validated.
#' @param name the validator name (used for error paths).
#' @param what what is being checked, e.g. `"row count"` or `'column "x"'`.
#'
#' @noRd
check_df <- function(value, name, what) {
  if (!is.data.frame(value)) {
    fail_precondition(name, sprintf("must be a data.frame to check %s, got %s",
                                    what, class(value)[1L]))
  }
}


#' Evaluate a Formula to a Single Count
#'
#' Evaluates `formula` via `eval_formula()` and requires a single non-NA
#' number, so the comparison in the calling step is always well-defined.
#'
#' @inheritParams eval_formula
#' @param expr_text deparsed formula body, for the error message.
#'
#' @return the evaluated number.
#'
#' @noRd
eval_count <- function(formula, value, name, ctx, expr_text) {
  expected <- eval_formula(formula, value, name, ctx)
  if (!is.numeric(expected) || length(expected) != 1L || is.na(expected)) {
    fail(name, sprintf("`%s` must evaluate to a single non-NA number", expr_text),
         found = if (is.null(expected)) "NULL" else
           sprintf("%s of length %d", class(expected)[1L], length(expected)))
  }
  expected
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
    fail_precondition(path, sprintf("must be numeric, got %s", class(x)[1L]))
  }
}


#' Kind of an Ordered Value
#'
#' @param x a vector.
#'
#' @return one of `"numeric"`, `"Date"`, `"POSIXct"`, `"difftime"`,
#'   `"ordered factor"`, or `NA_character_` when `x` has no usable order.
#'
#' @noRd
value_kind <- function(x) {
  if (inherits(x, "POSIXct")) return("POSIXct")
  if (inherits(x, "Date")) return("Date")
  if (inherits(x, "difftime")) return("difftime")
  if (is.ordered(x)) return("ordered factor")
  if (is.numeric(x)) return("numeric")
  NA_character_
}


#' Whether a Range Bound Is Unset
#'
#' `-Inf` / `Inf` are the defaults of the range steps and mean "no bound".
#'
#' @noRd
is_open_bound <- function(b) {
  is.numeric(b) && !inherits(b, "difftime") && length(b) == 1L && is.infinite(b)
}


#' Kind Shared by the Bounds of a Range
#'
#' Validates the bounds when a range step is built.
#'
#' @param lower,upper the range bounds.
#'
#' @return the common kind of the set bounds, or `NULL` when both are open.
#'
#' @noRd
bounds_kind <- function(lower, upper) {
  kinds <- character(0L)
  for (b in list(lower, upper)) {
    if (is_open_bound(b)) next
    kb <- value_kind(b)
    if (is.na(kb) || length(b) != 1L || is.na(b)) {
      stop("range bounds must be single non-NA numbers, Dates, POSIXct, ",
           "difftimes or ordered factor levels", call. = FALSE)
    }
    kinds <- c(kinds, kb)
  }
  if (length(unique(kinds)) > 1L) {
    stop(sprintf("range bounds must be of the same kind, got %s",
                 paste(kinds, collapse = " and ")), call. = FALSE)
  }
  if (length(kinds) == 0L) NULL else kinds[[1L]]
}


#' Format a Range Bound for Messages
#'
#' @noRd
format_bound <- function(b) {
  if (is.ordered(b)) as.character(b)
  else if (is.numeric(b)) as.character(b)
  else format(b)
}


#' Check a Value Is Comparable With Range Bounds
#'
#' Shared guard for the range steps. Accepts numeric, `Date`, `POSIXct`,
#' `difftime` and ordered-factor values, and requires the value and the set
#' bounds to be the same kind, so a `Date` bound never meets a numeric value
#' through R's coercion rules.
#'
#' @param x the value to check.
#' @param lower,upper the range bounds.
#' @param path the full path for error messages.
#'
#' @return A list `x`, `lower`, `upper` ready for `<` / `>` (ordered factors as
#'   level positions; unset bounds of non-numeric kinds as `NULL`).
#'
#' @noRd
check_comparable <- function(x, lower, upper, path) {
  want <- bounds_kind(lower, upper)
  kind <- value_kind(x)
  if (is.na(kind) || (!is.null(want) && kind != want)) {
    fail_precondition(path, sprintf("must be %s, got %s",
                                    want %||% "numeric", class(x)[1L]))
  }
  prep <- function(b) {
    if (kind == "numeric") return(b)
    if (is_open_bound(b)) return(NULL)
    if (kind == "POSIXct") return(as.numeric(b))
    if (kind == "ordered factor") {
      if (!identical(levels(b), levels(x))) {
        fail_precondition(path, "must have the same levels as the range bounds")
      }
      return(as.integer(b))
    }
    b
  }
  list(x = switch(kind, "ordered factor" = as.integer(x),
                  POSIXct = as.numeric(x), x),
       lower = prep(lower), upper = prep(upper))
}


#' Positions Outside a Range
#'
#' @param p result of `check_comparable()`.
#' @param exclusive_lower,exclusive_upper whether each bound is exclusive.
#'
#' @return integer positions of elements outside the range (`NA` skipped).
#'
#' @noRd
range_violations <- function(p, exclusive_lower, exclusive_upper) {
  too_low <- if (is.null(p$lower)) FALSE else
    if (exclusive_lower) p$x <= p$lower else p$x < p$lower
  too_high <- if (is.null(p$upper)) FALSE else
    if (exclusive_upper) p$x >= p$upper else p$x > p$upper
  which(too_low | too_high)
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
#' Shared helper used by `require_numeric()`.
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
