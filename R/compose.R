# ---- Combinators: apply or combine whole validators ----

#' Build a Step That Runs a Validator on Parts of the Value
#'
#' Shared constructor for `require_col()`, `require_each()` and
#' `require_fields()`. `targets(value, name, ctx)` resolves the parts: it
#' returns a list whose elements are either
#' `list(value, path, validator)` (run `validator` on `value` under `path`) or
#' `list(failure = <restrictR_failure>)` (a failure found while resolving, such
#' as a missing required field). It raises a failure itself when the value
#' cannot be split at all (for example, not a data.frame).
#'
#' In `"first"` mode the first inner failure is raised. In `"all"` mode every
#' inner failure is reported individually through the step's `collect` hook.
#'
#' @param label step label.
#' @param deps context names required by the inner validators.
#' @param fields step parameters for introspection.
#' @param targets function `(value, name, ctx)` returning the parts to check.
#'
#' @return A step list for `add_step()`.
#'
#' @noRd
scoped_step <- function(label, deps, fields, targets) {
  run <- function(value, name, ctx, on_fail) {
    failures <- list()
    for (t in targets(value, name, ctx)) {
      if (!is.null(t$failure)) {
        if (on_fail == "first") stop(t$failure)
        failures[[length(failures) + 1L]] <- t$failure
        next
      }
      if (is.null(t$value) && restriction_null_ok(t$validator)) next
      failures <- c(failures,
                    run_steps(restriction_steps(t$validator), t$value, t$path,
                              ctx, on_fail))
    }
    failures
  }
  new_step(
    label, deps = deps, fields = fields,
    fn = function(value, name, ctx) {
      run(value, name, ctx, "first")
      invisible(NULL)
    },
    collect = function(value, name, ctx) {
      tryCatch(run(value, name, ctx, "all"),
               restrictR_failure = function(f) list(f))
    }
  )
}


#' Describe a Validator Inside a Step Label
#'
#' @param validator a `restriction` object.
#'
#' @return character(1).
#'
#' @noRd
inner_label <- function(validator) {
  labels <- constraint_labels(validator)
  text <- if (length(labels) == 0L) "any value" else paste(labels, collapse = "; ")
  if (restriction_null_ok(validator)) paste0("NULL or ", text) else text
}


# ---- Optional values ----

#' Allow NULL
#'
#' Marks a validator as accepting `NULL`: a `NULL` value passes without running
#' any step, and every other value is validated by all steps as usual. Use it
#' for optional arguments such as `weights = NULL`.
#'
#' @param restriction a `restriction` object.
#'
#' @details The marker is order-independent: it can sit anywhere in the pipe.
#'   A `NULL` value returns before the context check, so context a step needs
#'   (e.g. `data` in `require_length_matches(~ nrow(data))`) is not required
#'   when the value is `NULL`. A validator that allows `NULL` also accepts a
#'   `NULL` (or absent) element when it is lifted with [require_col()],
#'   [require_each()], [require_fields()] or [require_valid()].
#'
#' @return The modified `restriction` object.
#'
#' @examples
#' weights_v <- restrict("weights") |>
#'   require_numeric(no_na = TRUE) |>
#'   require_positive() |>
#'   allow_null()
#' weights_v(NULL)         # passes
#' weights_v(c(1, 2))      # passes
#' is_valid(weights_v, -1) # FALSE
#'
#' @family composition
#' @export
allow_null <- function(restriction) {
  check_restriction(restriction, "restriction")
  if (restriction_null_ok(restriction)) return(restriction)
  add_step(restriction, new_step(
    "may be NULL",
    fn = function(value, name, ctx) invisible(NULL),
    fields = list(null_ok = TRUE),
    null_ok = TRUE
  ))
}


# ---- Lifting a validator onto parts of a value ----

#' Validate a Data Frame Column with a Validator
#'
#' Lifts any validator onto one column of a data.frame. Errors keep the
#' column path (e.g. `newdata$age: must be in [0, 120]`), so one set of steps
#' serves both a standalone argument and a column.
#'
#' @param restriction a `restriction` object.
#' @param col character(1) column name.
#' @param validator a `restriction` object applied to the column.
#'
#' @details The value must be a data.frame containing `col`, unless
#'   `validator` allows `NULL` (see [allow_null()]), in which case a missing
#'   column passes. Context passed to the outer validator is visible to formula
#'   steps in `validator`. With `.on_fail = "all"` each inner failure is
#'   reported on its own.
#'
#' @return The modified `restriction` object.
#'
#' @examples
#' age <- restrict("age") |>
#'   require_integer(no_na = TRUE) |>
#'   require_between(0, 120)
#'
#' newdata_v <- restrict("newdata") |>
#'   require_df() |>
#'   require_col("age", age) |>
#'   require_col("sex", restrict("sex") |> require_one_of(c("f", "m")))
#'
#' newdata_v(data.frame(age = 30L, sex = "f"))
#' validation_errors(newdata_v, data.frame(age = 130L, sex = "x"))
#'
#' @family composition
#' @export
require_col <- function(restriction, col, validator) {
  if (!is.character(col) || length(col) != 1L || is.na(col)) {
    stop("`col` must be a single non-NA character string", call. = FALSE)
  }
  check_restriction(validator)
  add_step(restriction, scoped_step(
    label = sprintf("$%s: %s", col, inner_label(validator)),
    deps = restriction_deps(validator),
    fields = list(col = col, validator = validator),
    targets = function(value, name, ctx) {
      check_df(value, name, sprintf('column "%s"', col))
      x <- value[[col]]
      if (is.null(x) && !restriction_null_ok(validator)) {
        fail_precondition(name, sprintf('column "%s" does not exist', col))
      }
      list(list(value = x, path = col_path(name, col), validator = validator))
    }
  ))
}


#' Validate Every Element of a List
#'
#' Applies a validator to each element of a list: list arguments, list-columns,
#' collected `...`, configuration lists. Errors carry the element path,
#' `layers[[2]]` for unnamed elements and `layers$key` for named ones.
#'
#' @param restriction a `restriction` object.
#' @param validator a `restriction` object applied to every element.
#'
#' @details The value must be a list. An empty list passes. In fail-first mode
#'   the first invalid element stops the check; with `.on_fail = "all"` every
#'   failing element is reported.
#'
#' @return The modified `restriction` object.
#'
#' @examples
#' layer <- restrict("layer") |> require_class("data.frame")
#' layers_v <- restrict("layers") |> require_class("list") |> require_each(layer)
#' layers_v(list(data.frame(a = 1), data.frame(b = 2)))
#' try(layers_v(list(data.frame(a = 1), "oops")))
#'
#' @family composition
#' @export
require_each <- function(restriction, validator) {
  check_restriction(validator)
  add_step(restriction, scoped_step(
    label = sprintf("each element: %s", inner_label(validator)),
    deps = restriction_deps(validator),
    fields = list(validator = validator),
    targets = function(value, name, ctx) {
      check_list(value, name, "each element")
      keys <- names(value)
      lapply(seq_along(value), function(i) {
        list(value = value[[i]], path = element_path(name, keys, i),
             validator = validator)
      })
    }
  ))
}


#' Validate Named Fields of a List
#'
#' Applies a different validator to each named element of a list, for
#' heterogeneous configuration or argument lists. Errors carry the field path,
#' e.g. `opts$alpha`.
#'
#' @param restriction a `restriction` object.
#' @param ... named `restriction` objects, one per field.
#' @param .required logical; if `TRUE` (default) a missing field is a failure.
#'   If `FALSE`, a missing field passes. A field whose validator allows `NULL`
#'   (see [allow_null()]) may always be missing.
#'
#' @return The modified `restriction` object.
#'
#' @examples
#' opts_v <- restrict("opts") |>
#'   require_class("list") |>
#'   require_fields(
#'     alpha = restrict("alpha") |> require_numeric() |> require_between(0, 1),
#'     label = restrict("label") |> require_character()
#'   )
#' opts_v(list(alpha = 0.05, label = "a"))
#' validation_errors(opts_v, list(alpha = 2))
#'
#' @family composition
#' @export
require_fields <- function(restriction, ..., .required = TRUE) {
  specs <- list(...)
  keys <- names(specs)
  if (length(specs) == 0L || is.null(keys) || anyNA(keys) ||
      any(!nzchar(keys)) || anyDuplicated(keys) > 0L) {
    stop("`...` must be uniquely named restriction objects", call. = FALSE)
  }
  for (k in keys) check_restriction(specs[[k]], k)
  if (!is.logical(.required) || length(.required) != 1L || is.na(.required)) {
    stop("`.required` must be TRUE or FALSE", call. = FALSE)
  }

  labels <- vapply(keys, function(k) {
    sprintf("$%s%s: %s", k, if (.required) "" else " (optional)",
            inner_label(specs[[k]]))
  }, character(1L))

  add_step(restriction, scoped_step(
    label = paste(labels, collapse = "; "),
    deps = unique(unlist(lapply(specs, restriction_deps))),
    fields = list(fields = specs, required = .required),
    targets = function(value, name, ctx) {
      check_list(value, name, "fields")
      lapply(keys, function(k) {
        v <- specs[[k]]
        path <- col_path(name, k)
        if (k %in% names(value)) {
          list(value = value[[k]], path = path, validator = v)
        } else if (.required && !restriction_null_ok(v)) {
          list(failure = restrictR_failure(path, "is required but missing"))
        } else {
          list(value = NULL, path = path, validator = allow_null(v))
        }
      })
    }
  ))
}


#' Require a List
#'
#' Shared guard for the list combinators.
#'
#' @param value the value being validated.
#' @param name the validator name.
#' @param what what is being checked, e.g. `"each element"`.
#'
#' @noRd
check_list <- function(value, name, what) {
  if (!is.list(value)) {
    fail_precondition(name, sprintf("must be a list to check %s, got %s",
                                    what, class(value)[1L]))
  }
}


#' Path of a List Element
#'
#' @param name the validator name.
#' @param keys `names(value)`, possibly `NULL`.
#' @param i element position.
#'
#' @noRd
element_path <- function(name, keys, i) {
  if (!is.null(keys) && !is.na(keys[i]) && nzchar(keys[i])) {
    col_path(name, keys[i])
  } else {
    sprintf("%s[[%d]]", name, i)
  }
}


# ---- Combining validators ----

#' Include Another Validator's Steps
#'
#' Splices the steps of `validator` into `restriction`, so two independently
#' defined validators combine into one. Splicing happens when the validator is
#' built: `print()` shows one flat list of steps and there is no nesting at
#' run time.
#'
#' @param restriction a `restriction` object.
#' @param validator a `restriction` object whose steps are appended.
#'
#' @details If `validator` allows `NULL` (see [allow_null()]), its steps are
#'   skipped for a `NULL` value and the combined validator does not itself
#'   become `NULL`-tolerant.
#'
#' @return The modified `restriction` object.
#'
#' @examples
#' id_v <- restrict("id") |> require_integer(no_na = TRUE)
#' pos_v <- restrict("x") |> require_positive(strict = TRUE)
#' restrict("id") |> require_valid(id_v) |> require_valid(pos_v)
#'
#' @family composition
#' @export
require_valid <- function(restriction, validator) {
  check_restriction(restriction, "restriction")
  check_restriction(validator)
  steps <- Filter(function(s) !isTRUE(s$null_ok), restriction_steps(validator))
  if (restriction_null_ok(validator)) steps <- lapply(steps, skip_null)
  add_steps(restriction, steps)
}


#' Skip a Step for NULL Values
#'
#' @param step a step list.
#'
#' @return the step, passing `NULL` values unchecked.
#'
#' @noRd
skip_null <- function(step) {
  fn <- step$fn
  collect <- step$collect
  step$label <- paste0("if not NULL, ", step$label)
  step$fn <- function(value, name, ctx) {
    if (!is.null(value)) fn(value, name, ctx)
    invisible(NULL)
  }
  if (!is.null(collect)) {
    step$collect <- function(value, name, ctx) {
      if (is.null(value)) list() else collect(value, name, ctx)
    }
  }
  step
}


#' Require at Least One of Several Validators
#'
#' Passes when the value satisfies at least one of the alternative validators.
#' When none passes, the error lists the first failure of every alternative.
#'
#' @param restriction a `restriction` object.
#' @param ... `restriction` objects, the alternatives.
#' @param .label optional character(1) description for `print()` and contract
#'   text; defaults to the alternatives' own labels.
#'
#' @details Each alternative runs in fail-first mode. Context needed by any
#'   alternative is required from the caller, like for any other step. Missing
#'   context is a usage error, not an alternative failing. In `.on_fail =
#'   "all"` mode the step reports a single failure.
#'
#' @return The modified `restriction` object.
#'
#' @examples
#' num_or_df <- restrict("x") |>
#'   require_any(
#'     restrict("x") |> require_numeric(),
#'     restrict("x") |> require_df() |> require_has_cols("value")
#'   )
#' num_or_df(1:3)
#' num_or_df(data.frame(value = 1))
#' try(num_or_df("a"))
#'
#' @family composition
#' @export
require_any <- function(restriction, ..., .label = NULL) {
  check_restriction(restriction, "restriction")
  alts <- list(...)
  if (length(alts) == 0L) {
    stop("`require_any()` needs at least one alternative", call. = FALSE)
  }
  for (a in alts) check_restriction(a, "...")
  if (!is.null(.label) &&
      (!is.character(.label) || length(.label) != 1L || is.na(.label))) {
    stop("`.label` must be a single non-NA character string", call. = FALSE)
  }

  lbl <- .label %||% sprintf(
    "must satisfy one of: %s",
    paste(sprintf("(%s)", vapply(alts, inner_label, character(1L))),
          collapse = " | ")
  )

  add_step(restriction, new_step(
    lbl,
    deps = unique(unlist(lapply(alts, restriction_deps))),
    fields = list(alternatives = alts),
    fn = function(value, name, ctx) {
      lines <- character(0L)
      for (a in alts) {
        if (is.null(value) && restriction_null_ok(a)) return(invisible(NULL))
        f <- tryCatch({
          run_steps(restriction_steps(a), value, name, ctx, "first")
          return(invisible(NULL))
        }, restrictR_failure = function(f) f)
        lines <- c(lines, if (identical(f$path, name)) f$detail else
          sprintf("%s: %s", f$path, f$detail))
      }
      fail(name, paste0("must satisfy one of:\n",
                        paste0("  - ", lines, collapse = "\n")))
    }
  ))
}
