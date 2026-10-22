# Story: restrictR

## Claim
Composable runtime contracts for R: argument validators built once from `require_*()` steps with the base pipe and called at the top of any function.

## Audience
R package and script authors who write input checks by hand (`if (!is.numeric(x)) stop(...)`) and repeat them across functions.

## Relation
- to: none; checkmate is the neighbouring package
- phrase: none
- home: vignettes/restrictR.Rmd, "Relation to checkmate"; README "Compared with checkmate" states it in a paragraph and links there

## Arcs

### A1 One contract, many functions
- question: "how do I stop copying the same checks into every function?"
- answer: a validator is a named function built once; pipes return new validators, so bases branch without change
- evidence: R/restrict.R (`add_step()`, `make_validator()`), tests
- home: vignette, Reusable Schemas and Composing Validators
- also: README (Usage, One rule for many functions)

### A2 Dependent rules
- question: "how do I check one argument against another?"
- answer: one-sided formulas, context passed explicitly at call time
- home: vignette, Dependent Validation
- also: README

### A3 Errors and documentation from the same steps
- question: "will the error tell me what is wrong, and can the docs follow the check?"
- answer: `path: message` with Found/At lines; print and `as_contract_text()`
- home: vignette, Self-Documentation and Using Contracts in Packages
- also: README

### A4 Checks without stopping, tests
- answer: `is_valid()`, `validation_errors()`, `.on_fail = "all"`, `expect_valid()` / `expect_invalid()`
- home: vignette, Checking Without Stopping and Testing Validators
- also: README supports list

## Non-goals
No domain-specific language, no operator overloading (DESCRIPTION).

## Documents
- DESCRIPTION: claim, A1 to A3
- README / landing: claim, first validator, one section per A1 to A3, checkmate paragraph, routing
- Runtime Contracts for R Functions (restrictR.Rmd): Get started and the only article; all arcs

## Open
- The only article doubles as Get started; a separate comparison article for checkmate does not exist yet.
