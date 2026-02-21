# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OCaml implementation of a dataflow-based spreadsheet simulation, based on Neel Krishnaswami's ["How to implement a spreadsheet"](https://semantic-domain.blogspot.com/2015/07/how-to-implement-spreadsheet.html).

**Philosophy**: This repository preserves Neel's original code with minimal changes. The focus is on proper packaging, testing, and modern OCaml tooling rather than algorithmic modifications. Only one bug fix was made (commit 90c10c4): the `union` function's base case was corrected from `[] -> []` to `[] -> ys` in `lib/cell.ml`.

## Build Commands

```bash
dune build                          # Build the library
dune runtest                        # Run all tests
dune exec test/test_spreadsheet.exe # Run a specific test suite
dune build @fmt --auto-promote      # Format code (ocamlformat 0.27.0, conventional profile)
```

## Architecture

The library is a single module: `Spreadsheet.Cell` (public name `spreadsheet`, source in `lib/cell.ml` with interface `lib/cell.mli`).

Three key types form the reactive dataflow system:

- **`'a cell`** - Mutable container with cached value, computation (`code`), dependency list (`reads`), and reverse-dependency list (`observers`). Each cell has a unique `id` from a global counter (`lib/cell.ml:28`).
- **`'a exp`** - A computation `unit -> 'a * ecell list` that returns a value and the list of cells it read during evaluation.
- **`ecell`** - Existentially wrapped cell (`Pack : 'a cell -> ecell`) enabling heterogeneous cell lists.

The dependency tracking works through two operations:
- **`get`** - If uncached, evaluates the cell's computation, caches the result, records which cells were read, and registers this cell as an observer of each dependency.
- **`set`** / **`invalidate`** - Recursively clears cached values and observer relationships for all transitive dependents.

The monadic interface (`return`, `>>=`, `cell`, `get`, `set`, `run`) lets users build dependency graphs declaratively. See test files for usage examples.

## Known Limitations

- **No cycle detection**: Cycles cause `Stack_overflow` (tested in `test/test_spreadsheet_extra.ml`).
- **Not thread-safe**: Global mutable state, no synchronization. Single-threaded use only.
- **Observer lists hold strong references**: May prevent GC of unreachable cells.

## Dependencies

- **alcotest** - Testing framework
- **ocamlformat** - Code formatting (version 0.27.0, conventional profile, parse-docstrings enabled)
