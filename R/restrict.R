#' Create a Composable Validator
#'
#' Creates a callable validation object that accumulates checks via the base
#' pipe operator `|>`. The resulting object behaves like a function: call it
#' with a value to validate.
#'
#' @param name character(1) name used in error messages (e.g. `"newdata"`).
#'
#' @return A `restriction` object (callable function) with no validation steps.
#'
#' @section Calling convention:
#'
#' Validators accept `value` as the first argument, plus context via named
#' arguments in `...` or as a named list in `.ctx`:
#'
#' ```
#' require_pred(out, newdata = df)
#' require_pred(out, .ctx = list(newdata = df))
#' ```
#'
#' Named arguments in `...` take precedence over `.ctx` entries with the
#' same name. If a step declares dependencies (e.g. `require_length_matches(~
#' nrow(newdata))`), the validator checks that all required context is present
#' before running any steps and errors early if not.
#'
#' By default a validator is fail-fast: the first failing step stops with its
#' error. Pass `.on_fail = "all"` to run every step and report all violations
#' in one aggregated error:
#'
#' ```
#' require_pred(out, .on_fail = "all")
#' ```
#'
#' In `"all"` mode a type or structure guard (wrong type, not a data.frame,
#' missing column) is reported once per path: later steps that fail the same
#' guard on the same path are not repeated. Independent value failures are all
#' reported.
#'
#' For a non-throwing result, use [is_valid()] or [validation_errors()].
#'
#' @examples
#' # Define a validator
#' require_positive <- restrict("x") |>
#'   require_numeric(no_na = TRUE) |>
#'   require_between(lower = 0, exclusive_lower = TRUE)
#'
#' # Use it
#' require_positive(5)   # passes silently
#'
#' # Compose with pipe
#' require_score <- restrict("score") |>
#'   require_numeric() |>
#'   require_length(1L) |>
#'   require_between(lower = 0, upper = 100)
#'
#' @family core
#' @export
restrict <- function(name) {
  if (!is.character(name) || length(name) != 1L || is.na(name)) {
    stop("`name` must be a single non-NA character string", call. = FALSE)
  }
  make_validator(name, list())
}


#' Build a Validator Closure
#'
#' Creates a new closure capturing `name`, `steps`, and `all_deps` in its
#' environment. The closure is the validator function itself.
#'
#' @param name character(1) validator name.
#' @param steps list of step objects (each with `label`, `deps`, `fields`,
#'   `fn`).
#'
#' @return A `restriction` object (callable function).
#'
#' @noRd
make_validator <- function(name, steps) {
  force(name)
  force(steps)

  # Precompute union of all deps for early context checking
  all_deps <- unique(unlist(lapply(steps, function(s) s$deps)))
  null_ok <- any(vapply(steps, function(s) isTRUE(s$null_ok), logical(1L)))

  validator <- function(value, ..., .ctx = NULL,
                        .on_fail = c("first", "all")) {
    on_fail <- match.arg(.on_fail)
    if (null_ok && is.null(value)) return(invisible(value))
    ctx <- c(list(...), .ctx %||% list())
    # Deduplicate: ... wins over .ctx
    ctx <- ctx[!duplicated(names(ctx))]

    # Enforce deps early
    if (length(all_deps) > 0L) {
      missing_deps <- setdiff(all_deps, names(ctx))
      if (length(missing_deps) > 0L) {
        stop(sprintf(
          "`%s` depends on: %s. Pass %s when calling the validator.",
          name,
          paste(missing_deps, collapse = ", "),
          paste(sprintf("%s = ...", missing_deps), collapse = ", ")
        ), call. = FALSE)
      }
    }

    failures <- run_steps(steps, value, name, ctx, on_fail)
    if (length(failures) > 0L) {
      stop(restrictR_failures(failures))
    }
    invisible(value)
  }

  class(validator) <- "restriction"
  validator
}


#' Run Validation Steps
#'
#' The single runner behind validators and the combinators that apply
#' validators to parts of a value (`require_col()`, `require_each()`, ...).
#'
#' In `"first"` mode the first failing step raises its `restrictR_failure`.
#' In `"all"` mode every step runs and the failures are returned as a list;
#' only the first precondition failure per path is kept, so one wrong type is
#' not repeated once per step. A step may supply `collect`, a function
#' `(value, name, ctx)` returning a list of failures, when it runs nested steps
#' and needs to report each inner failure separately.
#'
#' @param steps list of step objects.
#' @param value the value being validated.
#' @param name path used in error messages.
#' @param ctx named list of context values.
#' @param on_fail `"first"` or `"all"`.
#'
#' @return A list of `restrictR_failure` conditions (always empty in `"first"`
#'   mode, which raises instead).
#'
#' @noRd
run_steps <- function(steps, value, name, ctx, on_fail) {
  if (on_fail == "first") {
    for (s in steps) s$fn(value, name, ctx)
    return(list())
  }
  failures <- list()
  precondition_paths <- character(0L)
  for (s in steps) {
    found <- if (is.null(s$collect)) {
      tryCatch({
        s$fn(value, name, ctx)
        list()
      }, restrictR_failure = function(f) list(f))
    } else {
      s$collect(value, name, ctx)
    }
    for (f in found) {
      if (inherits(f, "restrictR_precondition")) {
        if (f$path %in% precondition_paths) next
        precondition_paths <- c(precondition_paths, f$path)
      }
      failures[[length(failures) + 1L]] <- f
    }
  }
  failures
}


#' Add a Validation Step to a Restriction
#'
#' Returns a new validator closure with the step appended. Never mutates
#' the original.
#'
#' @param restriction a `restriction` object.
#' @param step a step list built by `new_step()`.
#'
#' @return A new `restriction` object with the step appended.
#'
#' @noRd
add_step <- function(restriction, step) {
  if (!inherits(restriction, "restriction")) {
    stop("first argument must be a `restriction` object created by restrict()",
         call. = FALSE)
  }
  add_steps(restriction, list(step))
}


#' Append Several Steps to a Restriction
#'
#' @param restriction a `restriction` object.
#' @param steps list of step objects.
#'
#' @return A new `restriction` object.
#'
#' @noRd
add_steps <- function(restriction, steps) {
  make_validator(restriction_name(restriction),
                 c(restriction_steps(restriction), steps))
}


#' Validate a Restriction Argument
#'
#' @param x the object to check.
#' @param arg argument name for the error message.
#'
#' @noRd
check_restriction <- function(x, arg = "validator") {
  if (!inherits(x, "restriction")) {
    stop(sprintf("`%s` must be a restriction object created by restrict()",
                 arg), call. = FALSE)
  }
}


#' Access Validator Name
#'
#' @param x a `restriction` object.
#'
#' @return character(1) the validator name.
#'
#' @noRd
restriction_name <- function(x) {
  environment(x)$name
}


#' Access Validator Steps
#'
#' @param x a `restriction` object.
#'
#' @return list of step objects.
#'
#' @noRd
restriction_steps <- function(x) {
  environment(x)$steps
}


#' Access Validator Context Dependencies
#'
#' @param x a `restriction` object.
#'
#' @return character vector of context names.
#'
#' @noRd
restriction_deps <- function(x) {
  environment(x)$all_deps %||% character(0L)
}


#' Whether a Validator Accepts NULL
#'
#' @param x a `restriction` object.
#'
#' @return logical(1).
#'
#' @noRd
restriction_null_ok <- function(x) {
  isTRUE(environment(x)$null_ok)
}


#' Constraint Labels of a Validator
#'
#' The step labels, without the `allow_null()` marker.
#'
#' @param x a `restriction` object.
#'
#' @return character vector.
#'
#' @noRd
constraint_labels <- function(x) {
  steps <- Filter(function(s) !isTRUE(s$null_ok), restriction_steps(x))
  vapply(steps, function(s) s$label, character(1L))
}


#' @export
print.restriction <- function(x, ...) {
  nm <- restriction_name(x)
  steps <- restriction_steps(x)
  cat(sprintf("<restriction %s>\n", nm))

  if (length(steps) == 0L) {
    cat("  (no steps)\n")
  } else {
    for (i in seq_along(steps)) {
      cat(sprintf("  %d. %s\n", i, steps[[i]]$label))
    }
  }

  all_deps <- environment(x)$all_deps
  if (length(all_deps) > 0L) {
    cat(sprintf("  Depends on: %s\n", paste(all_deps, collapse = ", ")))
  }

  invisible(x)
}


#' List the Steps of a Validator
#'
#' Returns the steps of a validator as a data.frame, one row per step in the
#' order they run, for introspection and tooling. It shows the same steps as
#' `print()`.
#'
#' @param x a `restriction` object.
#'
#' @return A data.frame with the columns `step` (position), `label` (the
#'   description shown by `print()`), `deps` (list column: context names the
#'   step needs) and `fields` (list column: the parameters the step was built
#'   with, `NULL` when it has none).
#'
#' @examples
#' v <- restrict("x") |> require_numeric(no_na = TRUE) |> require_between(0, 1)
#' steps(v)
#' steps(v)$fields[[2]]
#'
#' @family core
#' @export
steps <- function(x) {
  check_restriction(x, "x")
  s <- restriction_steps(x)
  out <- data.frame(step = seq_along(s),
                    label = vapply(s, function(st) st$label, character(1L)),
                    stringsAsFactors = FALSE)
  out$deps <- lapply(s, function(st) st$deps)
  out$fields <- lapply(s, function(st) st$fields)
  out
}


#' Convert a Validator to Plain Text
#'
#' Produces a single-line text summary suitable for roxygen `@param`
#' documentation. Use with inline R code in roxygen: `` `r
#' as_contract_text(validator)` ``.
#'
#' @param x a `restriction` object.
#'
#' @return A character(1) string describing the validation contract.
#'
#' @examples
#' v <- restrict("x") |> require_numeric(no_na = TRUE) |> require_length(1L)
#' as_contract_text(v)
#'
#' @family core
#' @export
as_contract_text <- function(x) {
  if (!inherits(x, "restriction")) {
    stop("`x` must be a restriction object", call. = FALSE)
  }
  labels <- constraint_labels(x)
  null_ok <- restriction_null_ok(x)
  if (length(labels) == 0L) {
    return(if (null_ok) "May be NULL." else "No validation constraints.")
  }
  # Capitalize each sentence
  labels <- paste0(
    toupper(substring(labels, 1L, 1L)),
    substring(labels, 2L)
  )
  text <- paste0(paste(labels, collapse = ". "), ".")
  if (null_ok) paste0("NULL, or: ", text) else text
}


#' Convert a Validator to a Multi-Line Block
#'
#' Produces a multi-line text summary suitable for roxygen `@details`
#' documentation. Each step appears on its own line as a bullet point.
#'
#' @param x a `restriction` object.
#'
#' @return A character(1) string with one step per line.
#'
#' @examples
#' v <- restrict("x") |> require_numeric(no_na = TRUE) |> require_length(1L)
#' as_contract_block(v)
#'
#' @family core
#' @export
as_contract_block <- function(x) {
  if (!inherits(x, "restriction")) {
    stop("`x` must be a restriction object", call. = FALSE)
  }
  labels <- constraint_labels(x)
  null_ok <- restriction_null_ok(x)
  if (length(labels) == 0L) {
    return(if (null_ok) "- may be NULL" else "No validation constraints.")
  }
  if (null_ok) {
    return(paste(c("- may be NULL; otherwise:", paste0("  - ", labels)),
                 collapse = "\n"))
  }
  paste0("- ", labels, collapse = "\n")
}


#' Create a Custom Validation Step
#'
#' Allows advanced users to define their own validation step without
#' growing the package's built-in API surface. The step function receives
#' `(value, name, ctx)` and should call [fail()] on validation failure.
#'
#' @param restriction a `restriction` object.
#' @param label character(1) human-readable description for printing.
#' @param fn a function with signature `function(value, name, ctx)` that
#'   calls [fail()] on validation failure. It must be callable with three
#'   positional arguments (see [require_function()]).
#' @param deps character vector of context names this step requires
#'   (default: none).
#'
#' @return A new `restriction` object with the custom step appended.
#'
#' @examples
#' # Custom step: require all values to be unique
#' require_unique_id <- restrict("id") |>
#'   require_custom(
#'     label = "must contain unique values",
#'     fn = function(value, name, ctx) {
#'       dupes <- which(duplicated(value))
#'       if (length(dupes) > 0L) {
#'         fail(name, "contains duplicates", at = dupes)
#'       }
#'     }
#'   )
#'
#' @family core
#' @export
require_custom <- function(restriction, label, fn, deps = character(0L)) {
  restrict("fn") |> require_function(nargs = 3L) |> (\(v) v(fn))()
  add_step(restriction, new_step(label, fn, deps = deps,
                                 fields = list(custom = TRUE)))
}
