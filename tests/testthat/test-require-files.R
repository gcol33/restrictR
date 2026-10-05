root <- normalizePath(tempfile("restrictR-files-"), winslash = "/", mustWork = FALSE)
dir.create(root)
csv_path <- file.path(root, "data.csv")
upper_path <- file.path(root, "DATA.CSV")
txt_path <- file.path(root, "notes.txt")
for (p in c(csv_path, upper_path, txt_path)) file.create(p)

test_that("require_file_exists() accepts files and rejects missing paths and directories", {
  v <- restrict("path") |> require_file_exists()
  expect_valid(v, csv_path)
  expect_valid(v, c(csv_path, txt_path))
  expect_invalid(v, file.path(root, "missing.csv"),
                 regexp = "path: must be an existing file")
  expect_invalid(v, root, regexp = "must be an existing file")
})

test_that("require_file_exists() reports the first offender and positions", {
  v <- restrict("path") |> require_file_exists()
  err <- validation_errors(v, c(csv_path, file.path(root, "a"), root))
  expect_match(err, paste0('Found: "', file.path(root, "a"), '"'), fixed = TRUE)
  expect_match(err, "At: 2, 3", fixed = TRUE)
})

test_that("Found: shows the normalized path of a relative path", {
  v <- restrict("path") |> require_file_exists()
  err <- validation_errors(v, "no_such_file.csv")
  expected <- file.path(normalizePath(getwd(), winslash = "/"),
                        "no_such_file.csv")
  expect_true(grepl(tolower(expected), tolower(err), fixed = TRUE))
})

test_that("require_file_exists(extension =) checks case-insensitively", {
  v <- restrict("path") |> require_file_exists(extension = ".csv")
  expect_valid(v, c(csv_path, upper_path))
  err <- validation_errors(v, txt_path)
  expect_match(err, 'path: must have extension "csv"', fixed = TRUE)
  expect_equal(nrow(steps(v)), 2L)

  multi <- restrict("path") |> require_file_exists(extension = c("csv", "TXT"))
  expect_valid(multi, c(csv_path, txt_path))
  expect_equal(steps(multi)$label[2], 'must have extension "csv" or "txt"')
  expect_error(restrict("p") |> require_file_exists(extension = NA_character_),
               "without NA")
})

test_that("file-system steps skip NA and reject non-character input", {
  v <- restrict("path") |> require_file_exists()
  expect_valid(v, c(csv_path, NA))
  expect_error(v(1), "path: must be character, got numeric",
               class = "restrictR_precondition")
  expect_error(restrict("p") |> require_dir_exists() |> (\(x) x(NULL))(),
               "got NULL")
})

test_that("require_dir_exists() accepts directories only", {
  v <- restrict("dir") |> require_dir_exists()
  expect_valid(v, root)
  expect_invalid(v, csv_path, regexp = "dir: must be an existing directory")
  expect_invalid(v, file.path(root, "nope"), regexp = "existing directory")
})

test_that("require_readable() needs an existing readable path", {
  v <- restrict("path") |> require_readable()
  expect_valid(v, csv_path)
  expect_valid(v, root)
  expect_invalid(v, file.path(root, "missing.csv"), regexp = "path: must be readable")
})

test_that("require_writable() accepts existing targets and new files in a writable directory", {
  v <- restrict("out") |> require_writable()
  expect_valid(v, root)
  expect_valid(v, csv_path)
  expect_valid(v, file.path(root, "new-result.csv"))
})

test_that("require_writable() rejects a path whose parent does not exist", {
  v <- restrict("out") |> require_writable()
  err <- validation_errors(v, file.path(root, "no-such-dir", "result.csv"))
  expect_match(err, "out: must be writable", fixed = TRUE)
  expect_match(err, "no-such-dir/result.csv", fixed = TRUE)
})

test_that("require_writable() rejects a read-only directory", {
  skip_on_os("windows")
  skip_if(identical(Sys.info()[["user"]], "root"))
  locked <- file.path(root, "locked")
  dir.create(locked)
  Sys.chmod(locked, "555")
  v <- restrict("out") |> require_writable()
  res <- list(dir = validation_errors(v, locked),
              file = validation_errors(v, file.path(locked, "x.csv")))
  Sys.chmod(locked, "755")
  expect_length(res$dir, 1L)
  expect_length(res$file, 1L)
})
