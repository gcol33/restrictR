# ---- File-system checks ----

#' Build a File-System Step
#'
#' Shared constructor behind the file-system steps. `ok(paths)` returns a
#' logical vector, one entry per path; `NA` paths are skipped. The `Found:`
#' line shows the normalized path.
#'
#' @param restriction a `restriction` object.
#' @param lbl step label, also the failure message.
#' @param ok `function(paths)` returning `TRUE` for each acceptable path.
#' @param fields step parameters.
#'
#' @noRd
path_step <- function(restriction, lbl, ok, fields = NULL) {
  add_step(restriction, new_step(
    lbl,
    fields = fields,
    fn = function(value, name, ctx) {
      check_character(value, name)
      bad <- which(!is.na(value) & !ok(value))
      if (length(bad) > 0L) {
        fail_values(name, lbl, value, bad,
                    found = quoted(absolute_path(value[bad[1L]])))
      }
    }
  ))
}


#' Extension of a Path
#'
#' @noRd
path_extension <- function(p) {
  base <- basename(p)
  ifelse(grepl(".", base, fixed = TRUE), sub(".*\\.", "", base), "")
}


#' Whether a Path Can Be Written
#'
#' An existing file or directory must itself be writable; a path that does not
#' exist yet needs a writable parent directory.
#'
#' @noRd
is_writable <- function(p) {
  vapply(p, function(x) {
    target <- if (file.exists(x)) x else dirname(x)
    file.exists(target) && file.access(target, 2L) == 0L
  }, logical(1L), USE.NAMES = FALSE)
}


#' Require Existing Files
#'
#' Validates that every path of a character value exists and is a file.
#' `Found:` shows the normalized path of the first offender, so a relative
#' path resolved against the wrong working directory is visible.
#'
#' @param restriction a `restriction` object.
#' @param extension optional character vector of accepted extensions, with or
#'   without the leading dot, compared case-insensitively. Adds a second step
#'   that checks the extension.
#'
#' @details Non-character input fails with a type error. `NA` paths are
#'   skipped; chain [require_no_na()] to reject them.
#'
#' @return The modified `restriction` object.
#'
#' @examples
#' csv_in <- restrict("path") |> require_file_exists(extension = "csv")
#' tmp <- tempfile(fileext = ".csv")
#' invisible(file.create(tmp))
#' csv_in(tmp)
#' try(csv_in(file.path(tempdir(), "missing.csv")))
#'
#' @family file checks
#' @export
require_file_exists <- function(restriction, extension = NULL) {
  out <- path_step(restriction, "must be an existing file",
                   function(p) file.exists(p) & !dir.exists(p))
  if (is.null(extension)) return(out)
  if (!is.character(extension) || length(extension) == 0L || anyNA(extension)) {
    stop("`extension` must be a character vector without NA", call. = FALSE)
  }
  ext <- tolower(sub("^\\.", "", extension))
  path_step(out,
            sprintf("must have extension %s", paste0('"', ext, '"', collapse = " or ")),
            function(p) tolower(path_extension(p)) %in% ext,
            fields = list(extension = ext))
}


#' Require Existing Directories
#'
#' Validates that every path of a character value exists and is a directory.
#'
#' @param restriction a `restriction` object.
#'
#' @inherit require_file_exists details
#'
#' @return The modified `restriction` object.
#'
#' @family file checks
#' @export
require_dir_exists <- function(restriction) {
  path_step(restriction, "must be an existing directory", dir.exists)
}


#' Require Readable Paths
#'
#' Validates that every path of a character value exists and can be read,
#' judged by [file.access()].
#'
#' @param restriction a `restriction` object.
#'
#' @inherit require_file_exists details
#'
#' @return The modified `restriction` object.
#'
#' @family file checks
#' @export
require_readable <- function(restriction) {
  path_step(restriction, "must be readable",
            function(p) file.access(p, 4L) == 0L)
}


#' Require Writable Paths
#'
#' Validates that every path of a character value can be written: an existing
#' file or directory must be writable, and a path that does not exist yet
#' needs a writable parent directory. Use it for output files and
#' directories.
#'
#' @param restriction a `restriction` object.
#'
#' @details Writability is judged by [file.access()]. On Windows it reflects
#'   the read-only attribute and not access control lists, so a directory
#'   that is denied by permissions can still pass. The check cannot tell
#'   whether the disk has room.
#'
#' @inherit require_file_exists details
#'
#' @return The modified `restriction` object.
#'
#' @examples
#' out_dir <- restrict("out") |> require_writable()
#' out_dir(tempdir())
#' out_dir(file.path(tempdir(), "result.csv"))
#'
#' @family file checks
#' @export
require_writable <- function(restriction) {
  path_step(restriction, "must be writable", is_writable)
}
