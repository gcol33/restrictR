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
    description = "must be a data.frame",
    depends_on = character(0L),
    check = function(value, name, ctx) {
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
  desc_parts <- "must be numeric"
  if (no_na) desc_parts <- paste0(desc_parts, ", no NA")
  if (finite) desc_parts <- paste0(desc_parts, ", finite")

  add_step(restriction, list(
    description = desc_parts,
    depends_on = character(0L),
    check = function(value, name, ctx) {
      if (!is.numeric(value)) {
        fail(name, sprintf("must be numeric, got %s", class(value)[1L]))
      }
      if (no_na) {
        na_count <- sum(is.na(value))
        if (na_count > 0L) {
          pos <- which(is.na(value))
          pos_msg <- if (length(pos) <= 5L) {
            paste("at position", paste(pos, collapse = ", "))
          } else {
            sprintf("at positions %s, ... (%d total)",
                    paste(pos[1:5], collapse = ", "), na_count)
          }
          fail(name, sprintf("must not contain NA values (%d NA found %s)",
                             na_count, pos_msg))
        }
      }
      if (finite) {
        non_finite <- which(!is.finite(value))
        if (no_na) non_finite <- setdiff(non_finite, which(is.na(value)))
        if (length(non_finite) > 0L) {
          pos_msg <- if (length(non_finite) <= 5L) {
            paste("at position", paste(non_finite, collapse = ", "))
          } else {
            sprintf("at positions %s, ... (%d total)",
                    paste(non_finite[1:5], collapse = ", "),
                    length(non_finite))
          }
          fail(name, sprintf(
            "must be finite (%d non-finite value %s)",
            length(non_finite), pos_msg
          ))
        }
      }
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
  desc <- if (no_na) "must be character (no NA)" else "must be character"

  add_step(restriction, list(
    description = desc,
    depends_on = character(0L),
    check = function(value, name, ctx) {
      if (!is.character(value)) {
        fail(name, sprintf("must be character, got %s", class(value)[1L]))
      }
      if (no_na) {
        na_count <- sum(is.na(value))
        if (na_count > 0L) {
          pos <- which(is.na(value))
          pos_msg <- if (length(pos) <= 5L) {
            paste("at position", paste(pos, collapse = ", "))
          } else {
            sprintf("at positions %s, ... (%d total)",
                    paste(pos[1:5], collapse = ", "), na_count)
          }
          fail(name, sprintf("must not contain NA values (%d NA found %s)",
                             na_count, pos_msg))
        }
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
#' @export
require_length <- function(restriction, n) {
  add_step(restriction, list(
    description = sprintf("must have length %d", n),
    depends_on = character(0L),
    check = function(value, name, ctx) {
      if (length(value) != n) {
        fail(name, sprintf("must have length %d, got %d", n, length(value)))
      }
    }
  ))
}


#' Require Length Matching an Expression
#'
#' Validates that `length(value)` equals the result of evaluating a formula.
#' The formula is evaluated using only explicitly passed context arguments.
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
    description = sprintf("length must match %s", expr_text),
    depends_on = deps,
    check = function(value, name, ctx) {
      expected <- eval_formula(formula, ctx, name)
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
    description = sprintf("must have at least %d row%s", n,
                          if (n == 1L) "" else "s"),
    depends_on = character(0L),
    check = function(value, name, ctx) {
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
    description = sprintf('must have columns: %s',
                          paste0('"', cols, '"', collapse = ", ")),
    depends_on = character(0L),
    check = function(value, name, ctx) {
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
  desc_parts <- sprintf("$%s must be numeric", col)
  if (no_na) desc_parts <- paste0(desc_parts, " (no NA")
  if (finite) {
    desc_parts <- if (no_na) paste0(desc_parts, ", finite)") else
      paste0(desc_parts, " (finite)")
  } else if (no_na) {
    desc_parts <- paste0(desc_parts, ")")
  }

  add_step(restriction, list(
    description = desc_parts,
    depends_on = character(0L),
    check = function(value, name, ctx) {
      path <- col_path(name, col)
      x <- value[[col]]

      if (is.null(x)) {
        fail(name, sprintf("column \"%s\" does not exist", col))
        return(invisible(NULL))
      }

      if (!is.numeric(x)) {
        fail(name, sprintf("%s must be numeric, got %s",
                           path, class(x)[1L]))
      }
      if (no_na) {
        na_count <- sum(is.na(x))
        if (na_count > 0L) {
          pos <- which(is.na(x))
          pos_msg <- if (length(pos) <= 5L) {
            paste("at position", paste(pos, collapse = ", "))
          } else {
            sprintf("at positions %s, ... (%d total)",
                    paste(pos[1:5], collapse = ", "), na_count)
          }
          fail(name, sprintf(
            "%s must not contain NA values (%d NA found %s)",
            path, na_count, pos_msg
          ))
        }
      }
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
          fail(name, sprintf(
            "%s must be finite (%d non-finite value %s)",
            path, length(non_finite), pos_msg
          ))
        }
      }
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
  desc <- sprintf("$%s must be character", col)
  if (no_na) desc <- paste0(desc, " (no NA)")

  add_step(restriction, list(
    description = desc,
    depends_on = character(0L),
    check = function(value, name, ctx) {
      path <- col_path(name, col)
      x <- value[[col]]

      if (is.null(x)) {
        fail(name, sprintf("column \"%s\" does not exist", col))
        return(invisible(NULL))
      }

      if (!is.character(x)) {
        fail(name, sprintf("%s must be character, got %s",
                           path, class(x)[1L]))
      }
      if (no_na) {
        na_count <- sum(is.na(x))
        if (na_count > 0L) {
          pos <- which(is.na(x))
          pos_msg <- if (length(pos) <= 5L) {
            paste("at position", paste(pos, collapse = ", "))
          } else {
            sprintf("at positions %s, ... (%d total)",
                    paste(pos[1:5], collapse = ", "), na_count)
          }
          fail(name, sprintf(
            "%s must not contain NA values (%d NA found %s)",
            path, na_count, pos_msg
          ))
        }
      }
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
  desc <- sprintf("$%s must be in %s, %s", col, lb, ub)

  add_step(restriction, list(
    description = desc,
    depends_on = character(0L),
    check = function(value, name, ctx) {
      path <- col_path(name, col)
      x <- value[[col]]

      if (is.null(x)) {
        fail(name, sprintf("column \"%s\" does not exist", col))
        return(invisible(NULL))
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
  desc <- sprintf("must be in %s%s, %s%s", lb, lower, upper, ub)

  add_step(restriction, list(
    description = desc,
    depends_on = character(0L),
    check = function(value, name, ctx) {
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
    description = sprintf('must be one of: %s',
                          paste0('"', values, '"', collapse = ", ")),
    depends_on = character(0L),
    check = function(value, name, ctx) {
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
