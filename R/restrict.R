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

  validator <- function(value, ..., .ctx = NULL) {
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

    s <- steps
    nm <- name
    for (i in seq_along(s)) {
      s[[i]]$fn(value, nm, ctx)
    }
    invisible(value)
  }

  class(validator) <- "restriction"
  validator
}


#' Add a Validation Step to a Restriction
#'
#' Returns a new validator closure with the step appended. Never mutates
#' the original.
#'
#' @param restriction a `restriction` object.
#' @param step a list with `label` (character), `deps` (character vector),
#'   `fields` (named list or NULL), and `fn` (function(value, name, ctx)).
#'
#' @return A new `restriction` object with the step appended.
#'
#' @noRd
add_step <- function(restriction, step) {
  if (!inherits(restriction, "restriction")) {
    stop("first argument must be a `restriction` object created by restrict()",
         call. = FALSE)
  }
  old_name <- restriction_name(restriction)
  old_steps <- restriction_steps(restriction)
  make_validator(old_name, c(old_steps, list(step)))
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
  steps <- restriction_steps(x)
  if (length(steps) == 0L) return("No validation constraints.")
  labels <- vapply(steps, function(s) s$label, character(1L))
  # Capitalize first, collapse with periods
  labels[1L] <- paste0(
    toupper(substring(labels[1L], 1L, 1L)),
    substring(labels[1L], 2L)
  )
  paste0(paste(labels, collapse = ". "), ".")
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
  steps <- restriction_steps(x)
  if (length(steps) == 0L) return("No validation constraints.")
  labels <- vapply(steps, function(s) s$label, character(1L))
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
#'   calls `stop()` or `restrictR:::fail()` on failure.
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
#'         stop(sprintf("%s: contains %d duplicate value(s)",
#'                      name, length(dupes)), call. = FALSE)
#'       }
#'     }
#'   )
#'
#' @family core
#' @export
require_custom <- function(restriction, label, fn, deps = character(0L)) {
  if (!is.function(fn)) {
    stop("`fn` must be a function with signature function(value, name, ctx)",
         call. = FALSE)
  }
  add_step(restriction, list(
    label = label,
    deps = deps,
    fields = list(custom = TRUE),
    fn = fn
  ))
}
