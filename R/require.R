# ---- Type checks ----

#' Require a Data Frame
#'
#' Validates that the value is a `data.frame`.
#'
#' @param restriction a `restriction` object.
#'
#' @return The modified `restriction` object.
#'
#' @family type checks
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
#' @family type checks
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


#' Require Integer Type
#'
#' Validates that the value is integer (not just numeric with integer values).
#' Optionally checks for NA values.
#'
#' @param restriction a `restriction` object.
#' @param no_na logical; if `TRUE`, rejects NA values.
#'
#' @return The modified `restriction` object.
#'
#' @family type checks
#' @export
require_integer <- function(restriction, no_na = FALSE) {
  lbl <- if (no_na) "must be integer (no NA)" else "must be integer"

  add_step(restriction, list(
    label = lbl,
    deps = character(0L),
    fields = list(no_na = no_na),
    fn = function(value, name, ctx) {
      if (!is.integer(value)) {
        fail(name, sprintf("must be integer, got %s", class(value)[1L]))
      }
      if (no_na) check_no_na(value, name)
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
#' @family type checks
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


#' Require Logical Type
#'
#' Validates that the value is logical. Optionally checks for NA values.
#'
#' @param restriction a `restriction` object.
#' @param no_na logical; if `TRUE`, rejects NA values.
#'
#' @return The modified `restriction` object.
#'
#' @family type checks
#' @export
require_logical <- function(restriction, no_na = FALSE) {
  lbl <- if (no_na) "must be logical (no NA)" else "must be logical"

  add_step(restriction, list(
    label = lbl,
    deps = character(0L),
    fields = list(no_na = no_na),
    fn = function(value, name, ctx) {
      if (!is.logical(value)) {
        fail(name, sprintf("must be logical, got %s", class(value)[1L]))
      }
      if (no_na) check_no_na(value, name)
    }
  ))
}


# ---- Missingness / finiteness ----

#' Require No NA Values
#'
#' Validates that the value contains no `NA` values. Works on any atomic type.
#'
#' @param restriction a `restriction` object.
#'
#' @return The modified `restriction` object.
#'
#' @family missingness checks
#' @export
require_no_na <- function(restriction) {
  add_step(restriction, list(
    label = "must not contain NA",
    deps = character(0L),
    fields = NULL,
    fn = function(value, name, ctx) {
      check_no_na(value, name)
    }
  ))
}


#' Require Finite Values
#'
#' Validates that a numeric value contains no `Inf`, `-Inf`, or `NaN` values.
#' Does not check for `NA` (use [require_no_na()] for that).
#'
#' @param restriction a `restriction` object.
#'
#' @return The modified `restriction` object.
#'
#' @family missingness checks
#' @export
require_finite <- function(restriction) {
  add_step(restriction, list(
    label = "must be finite",
    deps = character(0L),
    fields = NULL,
    fn = function(value, name, ctx) {
      non_finite <- which(!is.finite(value))
      # Don't report NA positions here; require_no_na handles that
      non_finite <- setdiff(non_finite, which(is.na(value)))
      if (length(non_finite) > 0L) {
        fail(name, "must be finite", at = non_finite)
      }
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
#' @family structure checks
#' @export
require_length <- function(restriction, n) {
  add_step(restriction, list(
    label = sprintf("must have length %d", n),
    deps = character(0L),
    fields = list(n = n),
    fn = function(value, name, ctx) {
      if (length(value) != n) {
        fail(name, sprintf("must have length %d", n),
             found = sprintf("length %d", length(value)))
      }
    }
  ))
}


#' Require Minimum Length
#'
#' Validates that the value has at least length `n`.
#'
#' @param restriction a `restriction` object.
#' @param n integer(1) minimum length.
#'
#' @return The modified `restriction` object.
#'
#' @family structure checks
#' @export
require_length_min <- function(restriction, n) {
  add_step(restriction, list(
    label = sprintf("must have length >= %d", n),
    deps = character(0L),
    fields = list(n = n),
    fn = function(value, name, ctx) {
      if (length(value) < n) {
        fail(name, sprintf("must have length >= %d", n),
             found = sprintf("length %d", length(value)))
      }
    }
  ))
}


#' Require Maximum Length
#'
#' Validates that the value has at most length `n`.
#'
#' @param restriction a `restriction` object.
#' @param n integer(1) maximum length.
#'
#' @return The modified `restriction` object.
#'
#' @family structure checks
#' @export
require_length_max <- function(restriction, n) {
  add_step(restriction, list(
    label = sprintf("must have length <= %d", n),
    deps = character(0L),
    fields = list(n = n),
    fn = function(value, name, ctx) {
      if (length(value) > n) {
        fail(name, sprintf("must have length <= %d", n),
             found = sprintf("length %d", length(value)))
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
#' @family structure checks
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
        fail(name, sprintf("length must match %s (%d)", expr_text, expected),
             found = sprintf("length %d", actual))
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
#' @family structure checks
#' @export
require_nrow_min <- function(restriction, n) {
  add_step(restriction, list(
    label = sprintf("must have at least %d row%s", n,
                    if (n == 1L) "" else "s"),
    deps = character(0L),
    fields = list(n = n),
    fn = function(value, name, ctx) {
      if (nrow(value) < n) {
        fail(name, sprintf("must have at least %d row%s",
                           n, if (n == 1L) "" else "s"),
             found = sprintf("%d row%s", nrow(value),
                             if (nrow(value) == 1L) "" else "s"))
      }
    }
  ))
}


#' Require Row Count Matching an Expression
#'
#' Validates that `nrow(value)` equals the result of evaluating a formula.
#' The formula is evaluated using only explicitly passed context arguments,
#' plus `.value` (the validated value) and `.name` (the restriction name).
#'
#' @param restriction a `restriction` object.
#' @param formula a one-sided formula (e.g. `~ nrow(reference)`).
#'
#' @return The modified `restriction` object.
#'
#' @family structure checks
#' @export
require_nrow_matches <- function(restriction, formula) {
  if (!inherits(formula, "formula") || length(formula) != 2L) {
    stop("`formula` must be a one-sided formula (e.g. ~ nrow(reference))",
         call. = FALSE)
  }
  expr_text <- deparse(formula[[2L]])
  deps <- all.vars(formula)

  add_step(restriction, list(
    label = sprintf("nrow must match %s", expr_text),
    deps = deps,
    fields = list(formula = formula),
    fn = function(value, name, ctx) {
      expected <- eval_formula(formula, value, name, ctx)
      actual <- nrow(value)
      if (actual != expected) {
        fail(name, sprintf("nrow must match %s (%d)", expr_text, expected),
             found = sprintf("%d row%s", actual,
                             if (actual == 1L) "" else "s"))
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
#' @family structure checks
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
#' path-aware error messages (e.g. `newdata$x2: must be numeric`).
#'
#' @param restriction a `restriction` object.
#' @param col character(1) column name.
#' @param no_na logical; if `TRUE`, rejects NA values in the column.
#' @param finite logical; if `TRUE`, rejects non-finite values in the column.
#'
#' @return The modified `restriction` object.
#'
#' @family column checks
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
        fail(name, sprintf('column "%s" does not exist', col))
      }
      if (!is.numeric(x)) {
        fail(path, sprintf("must be numeric, got %s", class(x)[1L]))
      }
      check_na_finite(x, path, no_na, finite)
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
#' @family column checks
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
        fail(name, sprintf('column "%s" does not exist', col))
      }
      if (!is.character(x)) {
        fail(path, sprintf("must be character, got %s", class(x)[1L]))
      }
      if (no_na) check_no_na(x, path)
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
#' @family column checks
#' @export
require_col_between <- function(restriction, col, lower = -Inf, upper = Inf,
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
        fail(name, sprintf('column "%s" does not exist', col))
      }

      too_low <- if (exclusive_lower) x <= lower else x < lower
      too_high <- if (exclusive_upper) x >= upper else x > upper
      bad <- which(too_low | too_high)
      bad <- bad[!is.na(bad)]

      if (length(bad) > 0L) {
        fail(path, sprintf(
          "must be %s %s%s",
          if (exclusive_lower) ">" else ">=", lower,
          if (is.finite(upper)) sprintf(" and %s %s",
            if (exclusive_upper) "<" else "<=", upper) else ""
        ), found = x[bad[1L]], at = bad)
      }
    }
  ))
}


#' Require Column Values from a Set
#'
#' Validates that all values in a column are among the allowed values.
#'
#' @param restriction a `restriction` object.
#' @param col character(1) column name.
#' @param values vector of allowed values.
#'
#' @return The modified `restriction` object.
#'
#' @family column checks
#' @export
require_col_one_of <- function(restriction, col, values) {
  add_step(restriction, list(
    label = sprintf('$%s must be one of: %s', col,
                    paste0('"', values, '"', collapse = ", ")),
    deps = character(0L),
    fields = list(col = col, values = values),
    fn = function(value, name, ctx) {
      path <- col_path(name, col)
      x <- value[[col]]

      if (is.null(x)) {
        fail(name, sprintf('column "%s" does not exist', col))
      }

      bad <- which(!x %in% values)
      if (length(bad) > 0L) {
        fail(path, sprintf(
          'must be one of [%s]',
          paste0('"', values, '"', collapse = ", ")
        ), found = paste0('"', unique(x[bad]), '"', collapse = ", "),
        at = bad)
      }
    }
  ))
}


# ---- Value checks ----

#' Require Value in Range
#'
#' Validates that all elements of a numeric value fall within a specified range.
#'
#' @param restriction a `restriction` object.
#' @param lower numeric(1) lower bound (default `-Inf`).
#' @param upper numeric(1) upper bound (default `Inf`).
#' @param exclusive_lower logical; if `TRUE`, lower bound is exclusive.
#' @param exclusive_upper logical; if `TRUE`, upper bound is exclusive.
#'
#' @return The modified `restriction` object.
#'
#' @family value checks
#' @export
require_between <- function(restriction, lower = -Inf, upper = Inf,
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
      too_low <- if (exclusive_lower) value <= lower else value < lower
      too_high <- if (exclusive_upper) value >= upper else value > upper
      bad <- which(too_low | too_high)
      bad <- bad[!is.na(bad)]

      if (length(bad) > 0L) {
        fail(name, sprintf("must be in %s%s, %s%s", lb, lower, upper, ub),
             found = value[bad[1L]], at = bad)
      }
    }
  ))
}


#' Require Value from a Set
#'
#' Validates that all elements of the value are among the allowed values.
#'
#' @param restriction a `restriction` object.
#' @param values vector of allowed values.
#'
#' @return The modified `restriction` object.
#'
#' @family value checks
#' @export
require_one_of <- function(restriction, values) {
  add_step(restriction, list(
    label = sprintf('must be one of: %s',
                    paste0('"', values, '"', collapse = ", ")),
    deps = character(0L),
    fields = list(values = values),
    fn = function(value, name, ctx) {
      bad <- which(!value %in% values)
      if (length(bad) > 0L) {
        fail(name, sprintf(
          'must be one of [%s]',
          paste0('"', values, '"', collapse = ", ")
        ), found = paste0('"', unique(value[bad]), '"', collapse = ", "),
        at = bad)
      }
    }
  ))
}
