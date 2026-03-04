# ---- Type checks ----

#' Require a Data Frame
#'
#' Validates that the value is a `data.frame`.
#'
#' @param restriction a `restriction` object.
#'
#' @return The modified `restriction` object.
#'
#' @export
require_df <- function(restriction) {
  add_step(restriction, list(
    label = "must be a data.frame",
    deps = character(0L),
    fields = NULL,
    fn = function(value, name, ctx) {
      if (!is.data.frame(value)) {
        fail(name, sprintf("must be a data.frame, got %s", class(value)[1L]))
      }
    }
  ))
}


#' Require Numeric Type
#'
#' Validates that the value is numeric. Optionally checks for NA and
#' non-finite values.
#'
#' @param restriction a `restriction` object.
#' @param no_na logical; if `TRUE`, rejects NA values.
#' @param finite logical; if `TRUE`, rejects `Inf`/`-Inf`/`NaN`.
#'
#' @return The modified `restriction` object.
#'
#' @export
require_numeric <- function(restriction, no_na = FALSE, finite = FALSE) {
  lbl <- "must be numeric"
  if (no_na) lbl <- paste0(lbl, ", no NA")
  if (finite) lbl <- paste0(lbl, ", finite")

  add_step(restriction, list(
    label = lbl,
    deps = character(0L),
    fields = list(no_na = no_na, finite = finite),
    fn = function(value, name, ctx) {
      if (!is.numeric(value)) {
        fail(name, sprintf("must be numeric, got %s", class(value)[1L]))
      }
      check_na_finite(value, name, no_na, finite)
    }
  ))
}


#' Require Character Type
#'
#' Validates that the value is character. Optionally checks for NA values.
#'
#' @param restriction a `restriction` object.
#' @param no_na logical; if `TRUE`, rejects NA values.
#'
#' @return The modified `restriction` object.
#'
#' @export
require_character <- function(restriction, no_na = FALSE) {
  lbl <- if (no_na) "must be character (no NA)" else "must be character"

  add_step(restriction, list(
    label = lbl,
    deps = character(0L),
    fields = list(no_na = no_na),
    fn = function(value, name, ctx) {
      if (!is.character(value)) {
        fail(name, sprintf("must be character, got %s", class(value)[1L]))
      }
      if (no_na) check_no_na(value, name)
    }
  ))
}


# ---- Structure checks ----

#' Require Specific Length
#'
#' Validates that the value has exact length `n`.
#'
#' @param restriction a `restriction` object.
#' @param n integer(1) required length.
#'
#' @return The modified `restriction` object.
#'
#' @export
require_length <- function(restriction, n) {
  add_step(restriction, list(
    label = sprintf("must have length %d", n),
    deps = character(0L),
    fields = list(n = n),
    fn = function(value, name, ctx) {
      if (length(value) != n) {
        fail(name, sprintf("must have length %d, got %d", n, length(value)))
      }
    }
  ))
}


#' Require Length Matching an Expression
#'
#' Validates that `length(value)` equals the result of evaluating a formula.
#' The formula is evaluated using only explicitly passed context arguments,
#' plus `.value` (the validated value) and `.name` (the restriction name).
#'
#' @param restriction a `restriction` object.
#' @param formula a one-sided formula (e.g. `~ nrow(newdata)`).
#'
#' @return The modified `restriction` object.
#'
#' @export
require_length_matches <- function(restriction, formula) {
  if (!inherits(formula, "formula") || length(formula) != 2L) {
    stop("`formula` must be a one-sided formula (e.g. ~ nrow(newdata))",
         call. = FALSE)
  }
  expr_text <- deparse(formula[[2L]])
  deps <- all.vars(formula)

  add_step(restriction, list(
    label = sprintf("length must match %s", expr_text),
    deps = deps,
    fields = list(formula = formula),
    fn = function(value, name, ctx) {
      expected <- eval_formula(formula, value, name, ctx)
      actual <- length(value)
      if (actual != expected) {
        fail(name, sprintf(
          "length must match %s (%d), got %d",
          expr_text, expected, actual
        ))
      }
    }
  ))
}


#' Require Minimum Number of Rows
#'
#' Validates that a data.frame has at least `n` rows.
#'
#' @param restriction a `restriction` object.
#' @param n integer(1) minimum row count.
#'
#' @return The modified `restriction` object.
#'
#' @export
require_nrow_min <- function(restriction, n) {
  add_step(restriction, list(
    label = sprintf("must have at least %d row%s", n,
                    if (n == 1L) "" else "s"),
    deps = character(0L),
    fields = list(n = n),
    fn = function(value, name, ctx) {
      if (nrow(value) < n) {
        fail(name, sprintf("must have at least %d row%s, got %d",
                           n, if (n == 1L) "" else "s", nrow(value)))
      }
    }
  ))
}


#' Require Specific Columns
#'
#' Validates that a data.frame contains all specified columns.
#'
#' @param restriction a `restriction` object.
#' @param cols character vector of required column names.
#'
#' @return The modified `restriction` object.
#'
#' @export
require_has_cols <- function(restriction, cols) {
  add_step(restriction, list(
    label = sprintf('must have columns: %s',
                    paste0('"', cols, '"', collapse = ", ")),
    deps = character(0L),
    fields = list(cols = cols),
    fn = function(value, name, ctx) {
      missing_cols <- setdiff(cols, names(value))
      if (length(missing_cols) > 0L) {
        fail(name, sprintf(
          'missing required column%s: %s',
          if (length(missing_cols) > 1L) "s" else "",
          paste0('"', missing_cols, '"', collapse = ", ")
        ))
      }
    }
  ))
}


# ---- Column-level checks ----

#' Require Numeric Column
#'
#' Validates that a specific column in a data.frame is numeric. Produces
#' path-aware error messages (e.g. `newdata$x2 must be numeric`).
#'
#' @param restriction a `restriction` object.
#' @param col character(1) column name.
#' @param no_na logical; if `TRUE`, rejects NA values in the column.
#' @param finite logical; if `TRUE`, rejects non-finite values in the column.
#'
#' @return The modified `restriction` object.
#'
#' @export
require_col_numeric <- function(restriction, col, no_na = FALSE,
                                finite = FALSE) {
  lbl <- sprintf("$%s must be numeric", col)
  if (no_na) lbl <- paste0(lbl, " (no NA")
  if (finite) {
    lbl <- if (no_na) paste0(lbl, ", finite)") else paste0(lbl, " (finite)")
  } else if (no_na) {
    lbl <- paste0(lbl, ")")
  }

  add_step(restriction, list(
    label = lbl,
    deps = character(0L),
    fields = list(col = col, no_na = no_na, finite = finite),
    fn = function(value, name, ctx) {
      path <- col_path(name, col)
      x <- value[[col]]

      if (is.null(x)) {
        fail(name, sprintf("column \"%s\" does not exist", col))
      }
      if (!is.numeric(x)) {
        fail(name, sprintf("%s must be numeric, got %s", path, class(x)[1L]))
      }
      check_na_finite(x, name, no_na, finite, prefix = path)
    }
  ))
}


#' Require Character Column
#'
#' Validates that a specific column in a data.frame is character. Produces
#' path-aware error messages.
#'
#' @param restriction a `restriction` object.
#' @param col character(1) column name.
#' @param no_na logical; if `TRUE`, rejects NA values in the column.
#'
#' @return The modified `restriction` object.
#'
#' @export
require_col_character <- function(restriction, col, no_na = FALSE) {
  lbl <- sprintf("$%s must be character", col)
  if (no_na) lbl <- paste0(lbl, " (no NA)")

  add_step(restriction, list(
    label = lbl,
    deps = character(0L),
    fields = list(col = col, no_na = no_na),
    fn = function(value, name, ctx) {
      path <- col_path(name, col)
      x <- value[[col]]

      if (is.null(x)) {
        fail(name, sprintf("column \"%s\" does not exist", col))
      }
      if (!is.character(x)) {
        fail(name, sprintf("%s must be character, got %s",
                           path, class(x)[1L]))
      }
      if (no_na) check_no_na(x, name, prefix = path)
    }
  ))
}


#' Require Column Values in Range
#'
#' Validates that all values in a column fall within a specified range.
#'
#' @param restriction a `restriction` object.
#' @param col character(1) column name.
#' @param lower numeric(1) lower bound (default `-Inf`).
#' @param upper numeric(1) upper bound (default `Inf`).
#' @param exclusive_lower logical; if `TRUE`, lower bound is exclusive.
#' @param exclusive_upper logical; if `TRUE`, upper bound is exclusive.
#'
#' @return The modified `restriction` object.
#'
#' @export
require_col_range <- function(restriction, col, lower = -Inf, upper = Inf,
                              exclusive_lower = FALSE,
                              exclusive_upper = FALSE) {
  lb <- if (exclusive_lower) sprintf("(%s", lower) else sprintf("[%s", lower)
  ub <- if (exclusive_upper) sprintf("%s)", upper) else sprintf("%s]", upper)
  lbl <- sprintf("$%s must be in %s, %s", col, lb, ub)

  add_step(restriction, list(
    label = lbl,
    deps = character(0L),
    fields = list(col = col, lower = lower, upper = upper,
                  exclusive_lower = exclusive_lower,
                  exclusive_upper = exclusive_upper),
    fn = function(value, name, ctx) {
      path <- col_path(name, col)
      x <- value[[col]]

      if (is.null(x)) {
        fail(name, sprintf("column \"%s\" does not exist", col))
      }

      too_low <- if (exclusive_lower) x <= lower else x < lower
      too_high <- if (exclusive_upper) x >= upper else x > upper
      bad <- which(too_low | too_high)
      bad <- bad[!is.na(bad)]

      if (length(bad) > 0L) {
        fail(name, sprintf(
          "%s must be %s %s%s, got %s at position %d",
          path,
          if (exclusive_lower) ">" else ">=", lower,
          if (is.finite(upper)) sprintf(" and %s %s",
            if (exclusive_upper) "<" else "<=", upper) else "",
          x[bad[1L]], bad[1L]
        ))
      }
    }
  ))
}


# ---- Value checks ----

#' Require Value in Range
#'
#' Validates that a numeric value falls within a specified range.
#'
#' @param restriction a `restriction` object.
#' @param lower numeric(1) lower bound (default `-Inf`).
#' @param upper numeric(1) upper bound (default `Inf`).
#' @param exclusive_lower logical; if `TRUE`, lower bound is exclusive.
#' @param exclusive_upper logical; if `TRUE`, upper bound is exclusive.
#'
#' @return The modified `restriction` object.
#'
#' @export
require_range <- function(restriction, lower = -Inf, upper = Inf,
                          exclusive_lower = FALSE, exclusive_upper = FALSE) {
  lb <- if (exclusive_lower) "(" else "["
  ub <- if (exclusive_upper) ")" else "]"
  lbl <- sprintf("must be in %s%s, %s%s", lb, lower, upper, ub)

  add_step(restriction, list(
    label = lbl,
    deps = character(0L),
    fields = list(lower = lower, upper = upper,
                  exclusive_lower = exclusive_lower,
                  exclusive_upper = exclusive_upper),
    fn = function(value, name, ctx) {
      too_low <- if (exclusive_lower) {
        any(value <= lower, na.rm = TRUE)
      } else {
        any(value < lower, na.rm = TRUE)
      }
      too_high <- if (exclusive_upper) {
        any(value >= upper, na.rm = TRUE)
      } else {
        any(value > upper, na.rm = TRUE)
      }

      if (too_low || too_high) {
        bad_val <- if (too_low) {
          idx <- if (exclusive_lower) which(value <= lower) else
            which(value < lower)
          value[idx[1L]]
        } else {
          idx <- if (exclusive_upper) which(value >= upper) else
            which(value > upper)
          value[idx[1L]]
        }
        fail(name, sprintf(
          "must be in %s%s, %s%s, got %s",
          lb, lower, upper, ub, bad_val
        ))
      }
    }
  ))
}


#' Require Value from a Set
#'
#' Validates that the value is one of the allowed values.
#'
#' @param restriction a `restriction` object.
#' @param values vector of allowed values.
#'
#' @return The modified `restriction` object.
#'
#' @export
require_one_of <- function(restriction, values) {
  add_step(restriction, list(
    label = sprintf('must be one of: %s',
                    paste0('"', values, '"', collapse = ", ")),
    deps = character(0L),
    fields = list(values = values),
    fn = function(value, name, ctx) {
      if (!all(value %in% values)) {
        bad <- value[!value %in% values]
        fail(name, sprintf(
          'must be one of [%s], got %s',
          paste0('"', values, '"', collapse = ", "),
          paste0('"', bad, '"', collapse = ", ")
        ))
      }
    }
  ))
}
