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

  validator <- function(value, ...) {
    steps <- attr(sys.function(), "steps")
    nm <- attr(sys.function(), "restriction_name")
    ctx <- list(...)
    for (step in steps) {
      step$check(value, name = nm, ctx = ctx)
    }
    invisible(value)
  }

  structure(
    validator,
    class = "restriction",
    restriction_name = name,
    steps = list()
  )
}


#' Add a Validation Step to a Restriction
#'
#' Internal helper. Appends a step to the restriction's step list.
#'
#' @param restriction a `restriction` object.
#' @param step a list with `description` (character) and `check` (function).
#'
#' @return The modified `restriction` object.
#'
#' @noRd
add_step <- function(restriction, step) {
  if (!inherits(restriction, "restriction")) {
    stop("first argument must be a `restriction` object created by restrict()",
         call. = FALSE)
  }
  steps <- attr(restriction, "steps")
  steps <- c(steps, list(step))
  attr(restriction, "steps") <- steps
  restriction
}


#' @export
print.restriction <- function(x, ...) {
  nm <- attr(x, "restriction_name")
  steps <- attr(x, "steps")
  cat(sprintf("<restriction: %s>\n", nm))

  if (length(steps) == 0L) {
    cat("\n  (no validation steps)\n")
  } else {
    cat("\n")
    for (i in seq_along(steps)) {
      cat(sprintf("  %d. %s\n", i, steps[[i]]$description))
    }
  }

  # Show dependencies
  deps <- unique(unlist(lapply(steps, function(s) s$depends_on)))
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
  steps <- attr(x, "steps")
  if (length(steps) == 0L) return("No validation constraints.")
  descriptions <- vapply(steps, function(s) s$description, character(1L))
  # Capitalize first, collapse with periods
  descriptions[1L] <- paste0(
    toupper(substring(descriptions[1L], 1L, 1L)),
    substring(descriptions[1L], 2L)
  )
  paste0(paste(descriptions, collapse = ". "), ".")
}
