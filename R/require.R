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
  lbl <- "must be a data.frame"
  add_step(restriction, new_step(
    lbl,
    fn = function(value, name, ctx) {
      if (!is.data.frame(value)) {
        fail(name, sprintf("%s, got %s", lbl, class(value)[1L]))
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

  add_step(restriction, new_step(
    lbl,
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
#' @details `Inf` and `-Inf` are not whole numbers and are rejected in both
#'   modes; `NaN` counts as `NA`.
#'
#' @return The modified `restriction` object.
#'
#' @family type checks
#' @export
require_integer <- function(restriction, no_na = FALSE, strict = FALSE) {
  lbl <- if (strict) "must be integer type" else "must be whole number"
  if (no_na) lbl <- paste0(lbl, " (no NA)")

  add_step(restriction, new_step(
    lbl,
    fields = list(no_na = no_na, strict = strict),
    fn = function(value, name, ctx) {
      if (strict) {
        check_type(value, name, is.integer, "integer type")
      } else {
        check_type(value, name, is.numeric, "numeric or integer")
        whole <- is.na(value) | (is.finite(value) & value == floor(value))
        bad <- which(!whole)
        if (length(bad) > 0L) {
          fail_values(name, "must be whole number", value, bad)
        }
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

  add_step(restriction, new_step(
    lbl,
    fields = list(no_na = no_na),
    fn = function(value, name, ctx) {
      check_character(value, name)
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

  add_step(restriction, new_step(
    lbl,
    fields = list(no_na = no_na),
    fn = function(value, name, ctx) {
      check_type(value, name, is.logical, "logical")
      if (no_na) check_no_na(value, name)
    }
  ))
}


#' Require a Specific Class
#'
#' Validates that the value belongs to a given class. One verb covers the
#' types without a dedicated check, including `factor`, `Date`, `POSIXct`,
#' `list`, `matrix`, `environment`, and fitted-model objects such as `lm`.
#'
#' @param restriction a `restriction` object.
#' @param class character(1) class name to require.
#' @param exact logical; if `TRUE`, requires `class(value)[1]` to equal
#'   `class` exactly. If `FALSE` (default), tests inheritance with
#'   [inherits()], so a subclass passes.
#'
#' @details A matrix is `require_class("matrix")` (`inherits()` is `TRUE` for
#'   matrices since R 4.0) and an environment is
#'   `require_class("environment")`; neither needs a dedicated step. Use
#'   [require_dim()] for the shape.
#'
#' @return The modified `restriction` object.
#'
#' @examples
#' restrict("d") |> require_class("Date")
#' restrict("f") |> require_class("factor")
#' restrict("model") |> require_class("lm")
#' restrict("m") |> require_class("matrix") |> require_dim(c(NA, 3))
#'
#' @family type checks
#' @export
require_class <- function(restriction, class, exact = FALSE) {
  lbl <- sprintf('must be of class "%s"', class)

  add_step(restriction, new_step(
    lbl,
    fields = list(class = class, exact = exact),
    fn = function(value, name, ctx) {
      observed <- base::class(value)
      ok <- if (exact) identical(observed[1L], class) else inherits(value, class)
      if (!ok) {
        fail(name, sprintf("%s, got %s", lbl, observed[1L]))
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
  lbl <- "must not be NULL"
  add_step(restriction, new_step(
    lbl,
    fn = function(value, name, ctx) {
      if (is.null(value)) fail(name, lbl)
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
  add_step(restriction, new_step(
    msg_no_na,
    fn = function(value, name, ctx) check_no_na(value, name)
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
  add_step(restriction, new_step(
    msg_finite,
    fn = function(value, name, ctx) {
      # NA positions belong to require_no_na()
      non_finite <- setdiff(which(!is.finite(value)), which(is.na(value)))
      if (length(non_finite) > 0L) {
        fail(name, msg_finite, at = non_finite)
      }
    }
  ))
}


# ---- Structure checks: length ----

#' Build a Step That Bounds a Count
#'
#' Shared constructor behind the length, row and column steps. `extent`
#' describes what is counted: `count(value)`, `describe(k)` for the `Found:`
#' line and `guard(value, name)` for the type guard.
#'
#' @param restriction a `restriction` object.
#' @param n the bound.
#' @param lbl step label, also the failure message.
#' @param violated `function(k)` returning `TRUE` when the count `k` fails.
#' @param extent list with `count`, `describe`, `guard`.
#'
#' @noRd
count_bound_step <- function(restriction, n, lbl, violated, extent) {
  add_step(restriction, new_step(
    lbl,
    fields = list(n = n),
    fn = function(value, name, ctx) {
      extent$guard(value, name)
      k <- extent$count(value)
      if (violated(k)) fail(name, lbl, found = extent$describe(k))
    }
  ))
}


#' Build a Step That Matches a Count to a Formula
#'
#' @param restriction a `restriction` object.
#' @param formula one-sided formula giving the expected count.
#' @param example example formula for the error message.
#' @param noun what is counted, as it starts the label (`"length"`, `"nrow"`).
#' @param extent list with `count`, `describe`, `guard`.
#'
#' @noRd
count_matches_step <- function(restriction, formula, example, noun, extent) {
  check_one_sided(formula, example)
  expr_text <- deparse(formula[[2L]])
  lbl <- sprintf("%s must match %s", noun, expr_text)

  add_step(restriction, new_step(
    lbl,
    deps = formula_deps(formula),
    fields = list(formula = formula),
    fn = function(value, name, ctx) {
      extent$guard(value, name)
      expected <- eval_count(formula, value, name, ctx, expr_text)
      actual <- extent$count(value)
      if (actual != expected) {
        fail(name, sprintf("%s (%d)", lbl, expected),
             found = extent$describe(actual))
      }
    }
  ))
}


length_extent <- list(
  count = length,
  describe = function(k) sprintf("length %d", k),
  guard = function(value, name) invisible(NULL)
)


#' Extent of the Rows or Columns of a Table
#'
#' @param axis 1 for rows, 2 for columns.
#'
#' @noRd
table_extent <- function(axis) {
  unit <- c("row", "column")[axis]
  what <- paste(unit, "count")
  list(
    count = function(x) dim(x)[axis],
    describe = function(k) count_noun(k, unit),
    guard = function(value, name) check_tabular(value, name, what),
    unit = unit,
    noun = c("nrow", "ncol")[axis]
  )
}


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
  count_bound_step(restriction, 1L, "must be scalar",
                   function(k) k != 1L, length_extent)
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
  lbl <- "must be named"
  add_step(restriction, new_step(
    lbl,
    fn = function(value, name, ctx) {
      nm <- names(value)
      if (is.null(nm)) fail(name, lbl)
      unnamed <- which(is.na(nm) | nm == "")
      if (length(unnamed) > 0L) {
        fail(name, paste(lbl, "(all elements)"), at = unnamed)
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
  count_bound_step(restriction, n, sprintf("must have length %d", n),
                   function(k) k != n, length_extent)
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
  count_bound_step(restriction, n, sprintf("must have length >= %d", n),
                   function(k) k < n, length_extent)
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
  count_bound_step(restriction, n, sprintf("must have length <= %d", n),
                   function(k) k > n, length_extent)
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
  count_matches_step(restriction, formula, "~ nrow(newdata)", "length",
                     length_extent)
}


# ---- Structure checks: rows, columns, dimensions ----

#' Require Minimum Number of Rows
#'
#' Validates that a data.frame or matrix has at least `n` rows.
#'
#' @param restriction a `restriction` object.
#' @param n integer(1) minimum row count.
#'
#' @return The modified `restriction` object.
#'
#' @family structure checks
#' @export
require_nrow_min <- function(restriction, n) {
  ext <- table_extent(1L)
  count_bound_step(restriction, n,
                   sprintf("must have at least %s", count_noun(n, ext$unit)),
                   function(k) k < n, ext)
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
  ext <- table_extent(1L)
  count_matches_step(restriction, formula, "~ nrow(reference)", ext$noun, ext)
}


#' Require Minimum Number of Columns
#'
#' Validates that a data.frame or matrix has at least `n` columns.
#'
#' @param restriction a `restriction` object.
#' @param n integer(1) minimum column count.
#'
#' @return The modified `restriction` object.
#'
#' @family structure checks
#' @export
require_ncol_min <- function(restriction, n) {
  ext <- table_extent(2L)
  count_bound_step(restriction, n,
                   sprintf("must have at least %s", count_noun(n, ext$unit)),
                   function(k) k < n, ext)
}


#' Require Column Count Matching an Expression
#'
#' Validates that `ncol(value)` equals the result of evaluating a formula.
#' The formula is evaluated using only explicitly passed context arguments,
#' plus `.value` (the validated value) and `.name` (the restriction name).
#'
#' @param restriction a `restriction` object.
#' @param formula a one-sided formula (e.g. `~ ncol(reference)`).
#'
#' @return The modified `restriction` object.
#'
#' @family structure checks
#' @export
require_ncol_matches <- function(restriction, formula) {
  ext <- table_extent(2L)
  count_matches_step(restriction, formula, "~ ncol(reference)", ext$noun, ext)
}


#' Require Exact Dimensions
#'
#' Validates `dim(value)` of a data.frame, matrix or array. `NA` entries in
#' `dims` match any extent.
#'
#' @param restriction a `restriction` object.
#' @param dims numeric vector of required extents, one per dimension; `NA`
#'   leaves that dimension unchecked.
#'
#' @return The modified `restriction` object.
#'
#' @examples
#' design <- restrict("X") |> require_class("matrix") |> require_dim(c(NA, 3))
#' design(matrix(0, 10, 3))
#' try(design(matrix(0, 10, 2)))
#'
#' @family structure checks
#' @export
require_dim <- function(restriction, dims) {
  known <- dims[!is.na(dims)]
  if (!is.numeric(dims) || length(dims) == 0L ||
      any(known < 0 | known != floor(known))) {
    stop("`dims` must be a numeric vector of non-negative whole numbers or NA",
         call. = FALSE)
  }
  show_dims <- function(d) paste0("(", paste(ifelse(is.na(d), "any", d),
                                             collapse = ", "), ")")
  lbl <- paste("must have dim", show_dims(dims))

  add_step(restriction, new_step(
    lbl,
    fields = list(dims = dims),
    fn = function(value, name, ctx) {
      observed <- dim(value)
      if (is.null(observed)) {
        fail_precondition(name, sprintf(
          "must be a data.frame, matrix or array to check dim, got %s",
          class(value)[1L]))
      }
      ok <- length(observed) == length(dims) &&
        all(is.na(dims) | dims == observed)
      if (!ok) fail(name, lbl, found = paste("dim", show_dims(observed)))
    }
  ))
}


# ---- Structure checks: order ----

#' Require Sorted Values
#'
#' Validates that the elements are in order and reports the position of the
#' first element that breaks it.
#'
#' @param restriction a `restriction` object.
#' @param decreasing logical; if `TRUE`, requires decreasing order.
#' @param strict logical; if `TRUE`, equal neighbours are a violation.
#'
#' @details Works on numeric, character, logical, `Date`, `POSIXct`,
#'   `difftime` and ordered-factor values; other input fails with a type
#'   error. Character values compare in the collation order of the session
#'   locale. `NA` elements are skipped; chain [require_no_na()] to reject
#'   them.
#'
#' @return The modified `restriction` object.
#'
#' @examples
#' ts_v <- restrict("time") |> require_sorted(strict = TRUE)
#' ts_v(c(1, 2, 5))
#' try(ts_v(c(1, 3, 2)))
#'
#' @family structure checks
#' @export
require_sorted <- function(restriction, decreasing = FALSE, strict = FALSE) {
  lbl <- sprintf("must be %s%s order", if (strict) "strictly " else "",
                 if (decreasing) "decreasing" else "increasing")
  violates <- if (decreasing) {
    if (strict) `>=` else `>`
  } else {
    if (strict) `<=` else `<`
  }

  add_step(restriction, new_step(
    lbl,
    fields = list(decreasing = decreasing, strict = strict),
    fn = function(value, name, ctx) {
      orderable <- is.character(value) || is.logical(value) ||
        !is.na(value_kind(value))
      if (!orderable) {
        fail_precondition(name, sprintf("must be orderable to check order, got %s",
                                        class(value)[1L]))
      }
      pos <- which(!is.na(value))
      v <- value[pos]
      if (length(v) < 2L) return(invisible(NULL))
      before <- v[-length(v)]
      after <- v[-1L]
      bad <- which(violates(after, before))
      if (length(bad) > 0L) {
        i <- bad[1L]
        fail(name, lbl,
             found = sprintf("%s after %s", format_value(after[i]),
                             format_value(before[i])),
             at = pos[i + 1L])
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
  lbl <- "must contain unique values"
  add_step(restriction, new_step(
    lbl,
    fn = function(value, name, ctx) {
      dupes <- which(duplicated(value))
      if (length(dupes) > 0L) {
        fail(name, lbl,
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
  rng <- sprintf("%s%s, %s%s", lb, format_value(lower), format_value(upper), ub)
  lbl <- paste("must be in", rng)

  add_step(restriction, new_step(
    lbl,
    fields = list(lower = lower, upper = upper,
                  exclusive_lower = exclusive_lower,
                  exclusive_upper = exclusive_upper),
    fn = function(value, name, ctx) {
      p <- check_comparable(value, lower, upper, name)
      bad <- range_violations(p, exclusive_lower, exclusive_upper)
      if (length(bad) > 0L) {
        fail_values(name, lbl, value, bad, found = format_value(value[bad[1L]]))
      }
    }
  ))
}


sign_rules <- list(
  positive = list(
    strict = list(label = "must be positive", violates = `<=`),
    loose = list(label = "must be non-negative", violates = `<`)),
  negative = list(
    strict = list(label = "must be negative", violates = `>=`),
    loose = list(label = "must be non-positive", violates = `>`))
)


#' Build a Sign Step
#'
#' Shared constructor behind `require_positive()` and `require_negative()`.
#' `rule$violates(value, 0)` marks the offending elements.
#'
#' @param restriction a `restriction` object.
#' @param sign `"positive"` or `"negative"`.
#' @param strict logical; whether zero is a violation.
#'
#' @noRd
sign_step <- function(restriction, sign, strict) {
  rule <- sign_rules[[sign]][[if (strict) "strict" else "loose"]]
  add_step(restriction, new_step(
    rule$label,
    fields = list(strict = strict),
    fn = function(value, name, ctx) {
      check_numeric(value, name)
      bad <- which(rule$violates(value, 0))
      if (length(bad) > 0L) fail_values(name, rule$label, value, bad)
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
  sign_step(restriction, "positive", strict)
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
  sign_step(restriction, "negative", strict)
}


#' Require Value from a Set
#'
#' Validates that all elements of the value are among the allowed values. For
#' a vector this is the subset test: every element must be one of `values`.
#'
#' @param restriction a `restriction` object.
#' @param values vector of allowed values.
#'
#' @details `NA` elements are skipped; chain [require_no_na()] to reject them.
#'   Use [require_contains()] for the reverse direction (the value must hold
#'   all of `values`) and [require_set_equal()] for both.
#'
#' @return The modified `restriction` object.
#'
#' @family value checks
#' @export
require_one_of <- function(restriction, values) {
  lbl <- sprintf("must be one of: %s", quoted(values))
  add_step(restriction, new_step(
    lbl,
    fields = list(values = values),
    fn = function(value, name, ctx) {
      bad <- which(!(value %in% values) & !is.na(value))
      if (length(bad) > 0L) {
        fail_values(name, lbl, value, bad, found = quoted(unique(value[bad])))
      }
    }
  ))
}
