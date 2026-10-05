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
      check_numeric(value, name)
      check_na_finite(value, name, no_na, finite)
    }
  ))
}


#' Require Integer Values
#'
#' Validates that the value contains whole numbers. By default accepts both
#' `integer` and `numeric` types as long as all values are whole
#' (`x == floor(x)`). Set `strict = TRUE` to require the R `integer` type.
#'
#' @param restriction a `restriction` object.
#' @param no_na logical; if `TRUE`, rejects NA values.
#' @param strict logical; if `TRUE`, requires R `integer` type.
#'   If `FALSE` (default), accepts any numeric value that is a whole number.
#'
#' @return The modified `restriction` object.
#'
#' @family type checks
#' @export
require_integer <- function(restriction, no_na = FALSE, strict = FALSE) {
  if (strict) {
    lbl <- if (no_na) "must be integer type (no NA)" else "must be integer type"
    add_step(restriction, list(
      label = lbl,
      deps = character(0L),
      fields = list(no_na = no_na, strict = strict),
      fn = function(value, name, ctx) {
        if (!is.integer(value)) {
          fail_precondition(name, sprintf("must be integer type, got %s",
                                          class(value)[1L]))
        }
        if (no_na) check_no_na(value, name)
      }
    ))
  } else {
    lbl <- if (no_na) "must be whole number (no NA)" else "must be whole number"
    add_step(restriction, list(
      label = lbl,
      deps = character(0L),
      fields = list(no_na = no_na, strict = strict),
      fn = function(value, name, ctx) {
        if (!is.numeric(value) && !is.integer(value)) {
          fail_precondition(name, sprintf("must be numeric or integer, got %s",
                                          class(value)[1L]))
        }
        non_na <- which(!is.na(value))
        bad <- non_na[value[non_na] != floor(value[non_na])]
        if (length(bad) > 0L) {
          fail(name, "must be whole number",
               found = value[bad[1L]],
               at = if (length(value) > 1L) bad)
        }
        if (no_na) check_no_na(value, name)
      }
    ))
  }
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
        fail_precondition(name, sprintf("must be character, got %s",
                                        class(value)[1L]))
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
        fail_precondition(name, sprintf("must be logical, got %s",
                                        class(value)[1L]))
      }
      if (no_na) check_no_na(value, name)
    }
  ))
}


#' Require a Specific Class
#'
#' Validates that the value belongs to a given class. One verb covers the
#' types without a dedicated check, including `factor`, `Date`, `POSIXct`,
#' `list`, and fitted-model objects such as `lm`.
#'
#' @param restriction a `restriction` object.
#' @param class character(1) class name to require.
#' @param exact logical; if `TRUE`, requires `class(value)[1]` to equal
#'   `class` exactly. If `FALSE` (default), tests inheritance with
#'   [inherits()], so a subclass passes.
#'
#' @return The modified `restriction` object.
#'
#' @examples
#' restrict("d") |> require_class("Date")
#' restrict("f") |> require_class("factor")
#' restrict("model") |> require_class("lm")
#'
#' @family type checks
#' @export
require_class <- function(restriction, class, exact = FALSE) {
  lbl <- sprintf('must be of class "%s"', class)

  add_step(restriction, list(
    label = lbl,
    deps = character(0L),
    fields = list(class = class, exact = exact),
    fn = function(value, name, ctx) {
      observed <- base::class(value)
      ok <- if (exact) identical(observed[1L], class) else inherits(value, class)
      if (!ok) {
        fail(name, sprintf('must be of class "%s", got %s',
                           class, observed[1L]))
      }
    }
  ))
}


# ---- Null checks ----

#' Require Non-NULL Value
#'
#' Validates that the value is not `NULL`. Place this step first in the
#' pipeline when `NULL` is a possible input.
#'
#' @param restriction a `restriction` object.
#'
#' @return The modified `restriction` object.
#'
#' @family missingness checks
#' @export
require_not_null <- function(restriction) {
  add_step(restriction, list(
    label = "must not be NULL",
    deps = character(0L),
    fields = NULL,
    fn = function(value, name, ctx) {
      if (is.null(value)) {
        fail(name, "must not be NULL")
      }
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

#' Require Scalar Value
#'
#' Validates that the value has length 1. Rejects `NULL`, zero-length vectors,
#' and vectors with more than one element.
#'
#' @param restriction a `restriction` object.
#'
#' @return The modified `restriction` object.
#'
#' @family structure checks
#' @export
require_scalar <- function(restriction) {
  add_step(restriction, list(
    label = "must be scalar",
    deps = character(0L),
    fields = NULL,
    fn = function(value, name, ctx) {
      if (length(value) != 1L) {
        fail(name, "must be scalar (length 1)",
             found = sprintf("length %d", length(value)))
      }
    }
  ))
}


#' Require Named Value
#'
#' Validates that the value is fully named: every element has a non-empty,
#' non-`NA` name. A partially-named value (e.g. `c(a = 1, 2)`) fails and the
#' positions of the unnamed elements are reported.
#'
#' @param restriction a `restriction` object.
#'
#' @return The modified `restriction` object.
#'
#' @family structure checks
#' @export
require_named <- function(restriction) {
  add_step(restriction, list(
    label = "must be named",
    deps = character(0L),
    fields = NULL,
    fn = function(value, name, ctx) {
      nm <- names(value)
      if (is.null(nm)) {
        fail(name, "must be named")
      }
      unnamed <- which(is.na(nm) | nm == "")
      if (length(unnamed) > 0L) {
        fail(name, "must be named (all elements)", at = unnamed)
      }
    }
  ))
}


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
      expected <- eval_count(formula, value, name, ctx, expr_text)
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
      check_df(value, name, "row count")
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
      check_df(value, name, "row count")
      expected <- eval_count(formula, value, name, ctx, expr_text)
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


# ---- Uniqueness checks ----

#' Require Unique Values
#'
#' Validates that the value contains no duplicates. Reports the positions
#' of duplicated elements.
#'
#' @param restriction a `restriction` object.
#'
#' @return The modified `restriction` object.
#'
#' @family value checks
#' @export
require_unique <- function(restriction) {
  add_step(restriction, list(
    label = "must contain unique values",
    deps = character(0L),
    fields = NULL,
    fn = function(value, name, ctx) {
      dupes <- which(duplicated(value))
      if (length(dupes) > 0L) {
        fail(name, "contains duplicate values",
             found = paste0(deparse(unique(value[dupes])), collapse = ", "),
             at = dupes)
      }
    }
  ))
}


# ---- Value checks ----

#' Require Value in Range
#'
#' Validates that all elements of a value fall within a specified range. The
#' value can be numeric, `Date`, `POSIXct`, `difftime` or an ordered factor.
#'
#' @param restriction a `restriction` object.
#' @param lower lower bound (default `-Inf`, no lower bound).
#' @param upper upper bound (default `Inf`, no upper bound).
#' @param exclusive_lower logical; if `TRUE`, lower bound is exclusive.
#' @param exclusive_upper logical; if `TRUE`, upper bound is exclusive.
#'
#' @details The value and the bounds must be the same kind: a `Date` bound
#'   against a numeric value fails with a type error. Ordered-factor bounds are
#'   single values of a factor with the same levels as the validated value.
#'   Other input fails with a type error. `NA` elements are skipped; chain
#'   [require_no_na()] to reject them.
#'
#' @return The modified `restriction` object.
#'
#' @examples
#' period <- restrict("start") |>
#'   require_between(as.Date("2020-01-01"), as.Date("2020-12-31"))
#' period(as.Date("2020-06-15"))
#' try(period(as.Date("2021-01-01")))
#'
#' @family value checks
#' @export
require_between <- function(restriction, lower = -Inf, upper = Inf,
                            exclusive_lower = FALSE, exclusive_upper = FALSE) {
  bounds_kind(lower, upper)
  lb <- if (exclusive_lower) "(" else "["
  ub <- if (exclusive_upper) ")" else "]"
  rng <- sprintf("%s%s, %s%s", lb, format_bound(lower), format_bound(upper), ub)
  lbl <- paste("must be in", rng)

  add_step(restriction, list(
    label = lbl,
    deps = character(0L),
    fields = list(lower = lower, upper = upper,
                  exclusive_lower = exclusive_lower,
                  exclusive_upper = exclusive_upper),
    fn = function(value, name, ctx) {
      p <- check_comparable(value, lower, upper, name)
      bad <- range_violations(p, exclusive_lower, exclusive_upper)

      if (length(bad) > 0L) {
        first <- value[bad[1L]]
        fail(name, lbl,
             found = if (is.numeric(first)) first else format(first),
             at = if (length(value) > 1L) bad)
      }
    }
  ))
}


#' Require Positive Values
#'
#' Validates that all elements are positive. By default uses `>= 0`
#' (non-negative); set `strict = TRUE` for `> 0`.
#'
#' @param restriction a `restriction` object.
#' @param strict logical; if `TRUE`, requires `> 0`.
#'   If `FALSE` (default), requires `>= 0`.
#'
#' @details Non-numeric input fails with a type error. `NA` elements are
#'   skipped; chain [require_no_na()] to reject them.
#'
#' @return The modified `restriction` object.
#'
#' @family value checks
#' @export
require_positive <- function(restriction, strict = FALSE) {
  if (strict) {
    lbl <- "must be positive"
    add_step(restriction, list(
      label = lbl,
      deps = character(0L),
      fields = list(strict = strict),
      fn = function(value, name, ctx) {
        check_numeric(value, name)
        bad <- which(value <= 0)
        if (length(bad) > 0L) {
          fail(name, lbl, found = value[bad[1L]],
               at = if (length(value) > 1L) bad)
        }
      }
    ))
  } else {
    lbl <- "must be non-negative"
    add_step(restriction, list(
      label = lbl,
      deps = character(0L),
      fields = list(strict = strict),
      fn = function(value, name, ctx) {
        check_numeric(value, name)
        bad <- which(value < 0)
        if (length(bad) > 0L) {
          fail(name, lbl, found = value[bad[1L]],
               at = if (length(value) > 1L) bad)
        }
      }
    ))
  }
}


#' Require Negative Values
#'
#' Validates that all elements are negative. By default uses `<= 0`
#' (non-positive); set `strict = TRUE` for `< 0`.
#'
#' @param restriction a `restriction` object.
#' @param strict logical; if `TRUE`, requires `< 0`.
#'   If `FALSE` (default), requires `<= 0`.
#'
#' @details Non-numeric input fails with a type error. `NA` elements are
#'   skipped; chain [require_no_na()] to reject them.
#'
#' @return The modified `restriction` object.
#'
#' @family value checks
#' @export
require_negative <- function(restriction, strict = FALSE) {
  if (strict) {
    lbl <- "must be negative"
    add_step(restriction, list(
      label = lbl,
      deps = character(0L),
      fields = list(strict = strict),
      fn = function(value, name, ctx) {
        check_numeric(value, name)
        bad <- which(value >= 0)
        if (length(bad) > 0L) {
          fail(name, lbl, found = value[bad[1L]],
               at = if (length(value) > 1L) bad)
        }
      }
    ))
  } else {
    lbl <- "must be non-positive"
    add_step(restriction, list(
      label = lbl,
      deps = character(0L),
      fields = list(strict = strict),
      fn = function(value, name, ctx) {
        check_numeric(value, name)
        bad <- which(value > 0)
        if (length(bad) > 0L) {
          fail(name, lbl, found = value[bad[1L]],
               at = if (length(value) > 1L) bad)
        }
      }
    ))
  }
}


#' Require Value from a Set
#'
#' Validates that all elements of the value are among the allowed values.
#'
#' @param restriction a `restriction` object.
#' @param values vector of allowed values.
#'
#' @details `NA` elements are skipped; chain [require_no_na()] to reject them.
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
      bad <- which(!(value %in% values) & !is.na(value))
      if (length(bad) > 0L) {
        fail(name, sprintf(
          'must be one of [%s]',
          paste0('"', values, '"', collapse = ", ")
        ), found = paste0('"', unique(value[bad]), '"', collapse = ", "),
        at = if (length(value) > 1L) bad)
      }
    }
  ))
}
