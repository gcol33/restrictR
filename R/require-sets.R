# ---- Set relations: names, columns, levels, values ----

#' Describe What Is Compared
#'
#' `noun` names one element in messages; `verb` completes "must ... <nouns>".
#'
#' @noRd
set_kinds <- list(
  names = list(noun = "name", verb = "have"),
  columns = list(noun = "column", verb = "have"),
  levels = list(noun = "level", verb = "have"),
  values = list(noun = "value", verb = "contain")
)


#' Label of a Set Step
#'
#' @param kind entry of `set_kinds`.
#' @param mode one of `"identical"`, `"permutation"`, `"equal"`, `"subset"`,
#'   `"superset"`.
#' @param want the reference set.
#'
#' @noRd
set_label <- function(kind, mode, want) {
  w <- quoted(want)
  switch(mode,
    superset = sprintf("must %s %ss: %s", kind$verb, kind$noun, w),
    subset = sprintf("%ss must be among: %s", kind$noun, w),
    identical = sprintf("%ss must be exactly: %s", kind$noun, w),
    permutation = sprintf("%ss must be a permutation of: %s", kind$noun, w),
    equal = sprintf("%ss must be exactly the set: %s", kind$noun, w)
  )
}


#' Compare a Set With Its Reference
#'
#' The single comparison behind `require_names()`, `require_has_cols()`,
#' `require_levels()`, `require_contains()` and `require_set_equal()`.
#'
#' @param have the observed elements.
#' @param want the reference elements.
#' @inheritParams set_label
#'
#' @return `NULL` when the relation holds, otherwise a list with the failure
#'   `message` and an optional `found` line.
#'
#' @noRd
set_mismatch <- function(have, want, mode, kind) {
  plural <- function(k) if (k == 1L) kind$noun else paste0(kind$noun, "s")
  absent <- unique(want[!(want %in% have)])
  extra <- unique(have[!(have %in% want)])

  parts <- character(0L)
  if (mode != "subset" && length(absent) > 0L) {
    parts <- c(parts, sprintf("missing required %s: %s",
                              plural(length(absent)), quoted(absent)))
  }
  if (mode != "superset" && length(extra) > 0L) {
    parts <- c(parts, sprintf("unexpected %s: %s",
                              plural(length(extra)), quoted(extra)))
  }
  if (length(parts) > 0L) {
    return(list(message = paste(parts, collapse = "; ")))
  }
  if (mode %in% c("identical", "permutation") &&
      !identical(sort(have), sort(want))) {
    return(list(message = sprintf("%ss differ in how often they occur",
                                  kind$noun),
                found = quoted(have, max = 10L)))
  }
  if (mode == "identical" && !identical(have, want)) {
    return(list(message = sprintf("%ss are in a different order", kind$noun),
                found = quoted(have, max = 10L)))
  }
  NULL
}


#' Build a Set Relation Step
#'
#' @param restriction a `restriction` object.
#' @param want the reference set.
#' @param mode set relation, see `set_label()`.
#' @param kind name of an entry of `set_kinds`.
#' @param have `function(value)` returning the observed elements.
#' @param guard `function(value, name)` type guard.
#'
#' @noRd
set_step <- function(restriction, want, mode, kind, have,
                     guard = function(value, name) invisible(NULL)) {
  spec <- set_kinds[[kind]]
  lbl <- set_label(spec, mode, want)

  add_step(restriction, new_step(
    lbl,
    fields = structure(list(want, mode), names = c(kind, "mode")),
    fn = function(value, name, ctx) {
      guard(value, name)
      mismatch <- set_mismatch(have(value), want, mode, spec)
      if (!is.null(mismatch)) {
        fail(name, mismatch$message, found = mismatch$found)
      }
    }
  ))
}


#' Validate a Character Reference Set
#'
#' @param x the argument.
#' @param arg argument name for the error message.
#'
#' @noRd
check_reference <- function(x, arg) {
  if (!is.character(x) || anyNA(x)) {
    stop(sprintf("`%s` must be a character vector without NA", arg),
         call. = FALSE)
  }
}


#' Observed Names
#'
#' @noRd
names_of <- function(value) names(value) %||% character(0L)


#' Observed Distinct Values
#'
#' @noRd
distinct_values <- function(value) {
  v <- as.vector(value)
  unique(v[!is.na(v)])
}


check_atomic <- function(value, name) {
  if (!is.null(value) && !is.atomic(value)) {
    fail_precondition(name, sprintf("must be an atomic vector, got %s",
                                    class(value)[1L]))
  }
}


# ---- Names ----

#' Require Specific Columns
#'
#' Validates that a data.frame contains all specified columns. Equivalent to
#' `require_names(cols, mode = "superset")` with column wording in the
#' message.
#'
#' @param restriction a `restriction` object.
#' @param cols character vector of required column names.
#'
#' @return The modified `restriction` object.
#'
#' @family structure checks
#' @export
require_has_cols <- function(restriction, cols) {
  check_reference(cols, "cols")
  set_step(restriction, cols, "superset", "columns", have = names_of)
}


#' Require Names
#'
#' Compares `names(value)` with a reference. One verb covers "exactly these
#' names in this order", "only allowed names" and "at least these names".
#'
#' @param restriction a `restriction` object.
#' @param names character vector of reference names.
#' @param mode how the observed names relate to `names`:
#'   * `"identical"`: the same names in the same order;
#'   * `"subset"`: every observed name is in `names` (no unexpected names);
#'   * `"superset"`: every name in `names` is present (nothing missing);
#'   * `"permutation"`: the same names in any order, each occurring as often.
#'
#' @details A value without names has no names: it fails every mode except
#'   `"subset"`. The failure lists the missing and the unexpected names.
#'
#' @return The modified `restriction` object.
#'
#' @examples
#' cfg <- restrict("cfg") |> require_names(c("alpha", "beta"), mode = "subset")
#' cfg(list(alpha = 1))
#' try(cfg(list(alpha = 1, gamma = 2)))
#'
#' @family structure checks
#' @export
require_names <- function(restriction, names,
                          mode = c("identical", "subset", "superset",
                                   "permutation")) {
  mode <- match.arg(mode)
  check_reference(names, "names")
  set_step(restriction, names, mode, "names", have = names_of)
}


#' Require Unique Names
#'
#' Validates that no name occurs twice. Unnamed elements are ignored; use
#' [require_named()] to reject them.
#'
#' @param restriction a `restriction` object.
#'
#' @return The modified `restriction` object.
#'
#' @family structure checks
#' @export
require_unique_names <- function(restriction) {
  lbl <- "names must be unique"
  add_step(restriction, new_step(
    lbl,
    fn = function(value, name, ctx) {
      nm <- names(value)
      dupes <- which(duplicated(nm) & !is.na(nm) & nzchar(nm))
      if (length(dupes) > 0L) {
        fail(name, lbl, found = quoted(unique(nm[dupes]), max = 10L), at = dupes)
      }
    }
  ))
}


# ---- Values ----

#' Require All of a Set of Values
#'
#' Validates that the value contains every element of `values`. Extra
#' elements are allowed.
#'
#' @param restriction a `restriction` object.
#' @param values vector of values that must be present.
#'
#' @details `NA` elements of the validated value are ignored. A factor is
#'   compared by its labels. For the opposite direction (every element must be
#'   one of `values`) use [require_one_of()].
#'
#' @return The modified `restriction` object.
#'
#' @family value checks
#' @export
require_contains <- function(restriction, values) {
  set_step(restriction, as.vector(values), "superset", "values",
           have = distinct_values, guard = check_atomic)
}


#' Require the Same Set of Values
#'
#' Validates that the value and `values` hold the same distinct elements.
#' Order and duplicates are ignored.
#'
#' @inheritParams require_contains
#'
#' @return The modified `restriction` object.
#'
#' @family value checks
#' @export
require_set_equal <- function(restriction, values) {
  set_step(restriction, as.vector(values), "equal", "values",
           have = distinct_values, guard = check_atomic)
}


#' Require Values Disjoint From Context
#'
#' Validates that no element of the value occurs in the vector a formula
#' evaluates to, for example that train and test ids do not overlap. The
#' formula is evaluated using only explicitly passed context arguments, plus
#' `.value` and `.name`.
#'
#' @param restriction a `restriction` object.
#' @param formula a one-sided formula (e.g. `~ test_ids`).
#'
#' @details `NA` elements are ignored. A factor is compared by its labels.
#'
#' @return The modified `restriction` object.
#'
#' @examples
#' train_ids <- restrict("train_ids") |> require_disjoint(~ test_ids)
#' train_ids(1:3, test_ids = 4:6)
#' try(train_ids(1:3, test_ids = 3:6))
#'
#' @family value checks
#' @export
require_disjoint <- function(restriction, formula) {
  check_one_sided(formula, "~ test_ids")
  expr_text <- deparse(formula[[2L]])
  lbl <- sprintf("must not share values with %s", expr_text)

  add_step(restriction, new_step(
    lbl,
    deps = formula_deps(formula),
    fields = list(formula = formula),
    fn = function(value, name, ctx) {
      check_atomic(value, name)
      other <- eval_vector(formula, value, name, ctx, expr_text)
      bad <- which(value %in% other & !is.na(value))
      if (length(bad) > 0L) {
        fail_values(name, lbl, value, bad,
                    found = quoted(unique(value[bad]), max = 10L))
      }
    }
  ))
}


# ---- Factor levels ----

#' Require Factor Levels
#'
#' Compares `levels(value)` of a factor with a reference. The classic
#' `predict(newdata)` failure, a factor with a level the model has not seen,
#' is `require_levels(levels(train$f), mode = "subset")`.
#'
#' @param restriction a `restriction` object.
#' @param levels character vector of reference levels.
#' @param mode how the observed levels relate to `levels`:
#'   * `"identical"`: the same levels in the same order;
#'   * `"subset"`: every observed level is in `levels`;
#'   * `"superset"`: every level in `levels` is present.
#'
#' @details The levels of the factor are compared, whether or not a level
#'   occurs in the data. Non-factor input fails with a type error.
#'
#' @return The modified `restriction` object.
#'
#' @examples
#' f_v <- restrict("f") |> require_levels(c("a", "b"), mode = "subset")
#' f_v(factor(c("a", "b")))
#' try(f_v(factor(c("a", "z"))))
#'
#' @family value checks
#' @export
require_levels <- function(restriction, levels,
                           mode = c("identical", "subset", "superset")) {
  mode <- match.arg(mode)
  check_reference(levels, "levels")
  set_step(restriction, levels, mode, "levels", have = base::levels,
           guard = function(value, name) {
             check_type(value, name, is.factor, "a factor")
           })
}
