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
#' @examples
#' # Define a validator
#' require_positive <- restrict("x") |>
#'   require_numeric(no_na = TRUE) |>
#'   require_range(lower = 0, exclusive_lower = TRUE)
#'
#' # Use it
#' require_positive(5)   # passes silently
#'
#' # Compose with pipe
#' require_score <- restrict("score") |>
#'   require_numeric() |>
#'   require_length(1L) |>
#'   require_range(lower = 0, upper = 100)
#'
#' @export
restrict <- function(name) {
  if (!is.character(name) || length(name) != 1L || is.na(name)) {
    stop("`name` must be a single non-NA character string", call. = FALSE)
  }
  make_validator(name, list())
}


#' Build a Validator Closure
#'
#' Creates a new closure capturing `name` and `steps` in its environment.
#' The closure is the validator function itself.
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

  validator <- function(value, ...) {
    ctx <- list(...)
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
  cat(sprintf("<restriction: %s>\n", nm))

  if (length(steps) == 0L) {
    cat("\n  (no validation steps)\n")
  } else {
    cat("\n")
    for (i in seq_along(steps)) {
      cat(sprintf("  %d. %s\n", i, steps[[i]]$label))
    }
  }

  # Show dependencies
  deps <- unique(unlist(lapply(steps, function(s) s$deps)))
  if (length(deps) > 0L) {
    cat(sprintf("\n  Depends on: %s\n", paste(deps, collapse = ", ")))
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
