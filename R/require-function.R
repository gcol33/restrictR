# ---- Function checks ----

#' Argument Names of a Function
#'
#' @param f a function.
#'
#' @return list with `names` (all formals) and `required` (formals without a
#'   default, `...` excluded). A primitive without a recorded signature
#'   counts as `function(...)`.
#'
#' @noRd
function_formals <- function(f) {
  sig <- args(f)
  if (is.null(sig)) return(list(names = "...", required = character(0L)))
  fmls <- formals(sig)
  has_default <- vapply(fmls, function(d) !identical(d, quote(expr = )),
                        logical(1L))
  list(names = names(fmls),
       required = setdiff(names(fmls)[!has_default], "..."))
}


#' Require a Function
#'
#' Validates that the value is a function, optionally with named arguments or
#' a call signature. Meant for callback arguments.
#'
#' @param restriction a `restriction` object.
#' @param args optional character vector of argument names the function must
#'   declare.
#' @param nargs optional whole number: the function must be callable with
#'   exactly this many positional arguments, so it declares at least that many
#'   (or `...`) and requires no more.
#'
#' @details `args` looks at the declared formals only: a function declaring
#'   `...` does not satisfy a named argument.
#'
#' @return The modified `restriction` object.
#'
#' @examples
#' callback <- restrict("fn") |> require_function(nargs = 2L)
#' callback(function(x, y) x + y)
#' try(callback(function(x) x))
#'
#' @family function checks
#' @export
require_function <- function(restriction, args = NULL, nargs = NULL) {
  if (!is.null(args) &&
      (!is.character(args) || anyNA(args) || anyDuplicated(args) > 0L)) {
    stop("`args` must be a character vector of unique argument names",
         call. = FALSE)
  }
  if (!is.null(nargs) &&
      (!is.numeric(nargs) || length(nargs) != 1L || is.na(nargs) ||
       nargs < 0 || nargs != floor(nargs))) {
    stop("`nargs` must be a single non-negative whole number", call. = FALSE)
  }
  lbl <- "must be a function"
  if (!is.null(args)) lbl <- sprintf("%s with arguments %s", lbl, quoted(args))
  if (!is.null(nargs)) {
    lbl <- sprintf("%s%s callable with %s", lbl,
                   if (is.null(args)) "" else ",", count_noun(nargs, "positional argument"))
  }

  add_step(restriction, new_step(
    lbl,
    fields = list(args = args, nargs = nargs),
    fn = function(value, name, ctx) {
      check_type(value, name, is.function, "a function")
      f <- function_formals(value)
      signature <- sprintf("function(%s)", paste(f$names, collapse = ", "))
      if (!all(args %in% f$names)) {
        fail(name, lbl, found = signature)
      }
      if (!is.null(nargs)) {
        ok <- length(f$required) <= nargs &&
          ("..." %in% f$names || nargs <= length(f$names))
        if (!ok) fail(name, lbl, found = signature)
      }
    }
  ))
}
