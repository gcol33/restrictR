# ---- Character checks ----

#' Build a Step That Tests Each String
#'
#' Shared constructor behind the character steps. `violates(value)` returns
#' the positions of the offending non-`NA` elements; `NA` elements are never
#' offenders, and the type guard runs first.
#'
#' @param restriction a `restriction` object.
#' @param lbl step label, also the failure message.
#' @param fields step parameters.
#' @param violates `function(value)` returning offending positions.
#' @param found `function(value, i)` formatting the offender at position `i`.
#'
#' @noRd
string_step <- function(restriction, lbl, fields, violates,
                        found = function(value, i) quoted(value[i])) {
  add_step(restriction, new_step(
    lbl,
    fields = fields,
    fn = function(value, name, ctx) {
      check_character(value, name)
      bad <- violates(value)
      if (length(bad) > 0L) {
        fail_values(name, lbl, value, bad, found = found(value, bad[1L]))
      }
    }
  ))
}


#' Require Strings Matching a Pattern
#'
#' Validates that every non-`NA` element of a character value matches a
#' regular expression. `Found:` shows the first element that does not match
#' and `At:` lists every offender.
#'
#' @param restriction a `restriction` object.
#' @param regex character(1) regular expression (extended syntax, as in
#'   [grepl()]).
#' @param fixed logical; if `TRUE`, `regex` is a literal substring.
#' @param ignore_case logical; if `TRUE`, matching ignores case. Not available
#'   with `fixed = TRUE`.
#'
#' @details A match anywhere in the string counts; anchor the pattern with `^`
#'   and `$` to match the whole string. Non-character input fails with a type
#'   error. `NA` elements are skipped; chain [require_no_na()] to reject them.
#'
#' @return The modified `restriction` object.
#'
#' @examples
#' code <- restrict("code") |> require_character() |> require_pattern("^[A-Z]{3}$")
#' code(c("ABC", "XYZ"))
#' try(code(c("ABC", "xy")))
#'
#' @family character checks
#' @export
require_pattern <- function(restriction, regex, fixed = FALSE,
                            ignore_case = FALSE) {
  flag <- function(x) is.logical(x) && length(x) == 1L && !is.na(x)
  if (!is.character(regex) || length(regex) != 1L || is.na(regex)) {
    stop("`regex` must be a single non-NA character string", call. = FALSE)
  }
  if (!flag(fixed) || !flag(ignore_case)) {
    stop("`fixed` and `ignore_case` must be TRUE or FALSE", call. = FALSE)
  }
  if (fixed && ignore_case) {
    stop("`ignore_case` cannot be combined with `fixed = TRUE`", call. = FALSE)
  }
  matches <- function(x) grepl(regex, x, fixed = fixed, ignore.case = ignore_case)
  tryCatch(matches(""), condition = function(e) {
    stop(sprintf("`regex` is not a valid regular expression: %s",
                 conditionMessage(e)), call. = FALSE)
  })

  lbl <- if (fixed) {
    sprintf('must contain "%s"', regex)
  } else {
    sprintf('must match pattern "%s"%s', regex,
            if (ignore_case) " (ignoring case)" else "")
  }
  string_step(restriction, lbl,
              fields = list(regex = regex, fixed = fixed,
                            ignore_case = ignore_case),
              violates = function(value) which(!is.na(value) & !matches(value)))
}


#' Require String Length
#'
#' Validates the number of characters of every non-`NA` element of a
#' character value.
#'
#' @param restriction a `restriction` object.
#' @param min minimum number of characters (default 0).
#' @param max maximum number of characters (default `Inf`).
#'
#' @details Length is counted in characters, not bytes. Non-character input
#'   fails with a type error. `NA` elements are skipped; chain
#'   [require_no_na()] to reject them.
#'
#' @return The modified `restriction` object.
#'
#' @examples
#' initials <- restrict("initials") |> require_nchar(min = 2, max = 3)
#' initials(c("AB", "ABC"))
#' try(initials("A"))
#'
#' @family character checks
#' @export
require_nchar <- function(restriction, min = 0, max = Inf) {
  count <- function(x) {
    is.numeric(x) && length(x) == 1L && !is.na(x) && x >= 0 &&
      (is.infinite(x) || x == floor(x))
  }
  if (!count(min) || !count(max) || min > max) {
    stop("`min` and `max` must be single whole numbers with 0 <= min <= max",
         call. = FALSE)
  }
  lbl <- if (min == max) {
    sprintf("must have exactly %s", count_noun(min, "character"))
  } else if (is.infinite(max)) {
    sprintf("must have at least %s", count_noun(min, "character"))
  } else if (min == 0) {
    sprintf("must have at most %s", count_noun(max, "character"))
  } else {
    sprintf("must have between %d and %d characters", min, max)
  }

  string_step(restriction, lbl,
              fields = list(min = min, max = max),
              violates = function(value) {
                n <- nchar(value, type = "chars", allowNA = TRUE)
                which(!is.na(value) & (is.na(n) | n < min | n > max))
              },
              found = function(value, i) {
                n <- nchar(value[i], type = "chars", allowNA = TRUE)
                if (is.na(n)) quoted(value[i]) else
                  sprintf('%s (%s)', quoted(value[i]), count_noun(n, "character"))
              })
}


#' Require Non-Blank Strings
#'
#' Validates that no non-`NA` element of a character value is empty or made of
#' whitespace only.
#'
#' @param restriction a `restriction` object.
#'
#' @details Non-character input fails with a type error. `NA` elements are
#'   skipped; chain [require_no_na()] to reject them.
#'
#' @return The modified `restriction` object.
#'
#' @examples
#' label <- restrict("label") |> require_nonempty()
#' label(c("a", "b"))
#' try(label(c("a", " ")))
#'
#' @family character checks
#' @export
require_nonempty <- function(restriction) {
  string_step(restriction, "must not contain blank strings",
              fields = NULL,
              violates = function(value) {
                which(!is.na(value) & grepl("^[[:space:]]*$", value))
              })
}
