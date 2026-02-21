# Spreadsheet simulation in OCaml

![CI](https://github.com/FranklinChen/spreadsheet-ocaml/actions/workflows/ci.yml/badge.svg)

This is an OCaml implementation of a dataflow-based spreadsheet simulation, based on the article ["How to implement a spreadsheet"](https://semantic-domain.blogspot.com/2015/07/how-to-implement-spreadsheet.html) by Neel Krishnaswami. The core implementation demonstrates reactive dataflow programming using mutable cells with automatic dependency tracking.

**Philosophy**: This repository preserves Neel's original code with minimal changes. The focus is on proper packaging, testing, and modern OCaml tooling rather than algorithmic modifications.

## How to build the project and run the tests

This project uses Dune 3.19+ as its build system.

```bash
# Build the library
dune build

# Run all tests
dune runtest

# Run a specific test
dune exec test/test_spreadsheet.exe
dune exec test/test_spreadsheet_extra.exe

# Format code (requires ocamlformat)
dune build @fmt --auto-promote

# Build documentation
dune build @doc
```

## How it works

The spreadsheet provides a monadic interface for building reactive computations:

```ocaml
open Spreadsheet.Cell

(* Create cells with dependencies *)
let computation =
  cell (return 1) >>= fun a ->        (* a = 1 *)
  cell (return 2) >>= fun b ->        (* b = 2 *)
  cell (                               (* c = a + b *)
    get a >>= fun aValue ->
    get b >>= fun bValue ->
    return (aValue + bValue)
  ) >>= fun c ->
  return (a, b, c)

let a, b, c = run computation

(* c automatically updates when dependencies change *)
let () = assert (run (get c) = 3)
let () = set a (return 100)
let () = assert (run (get c) = 102)  (* automatically recomputed! *)
```

When a cell is updated via `set`, all dependent cells are automatically invalidated and will recompute when next accessed.

## Changes from the original blog post

Only one bug fix was made to the original implementation (see commit 90c10c4):

**Bug fix in `union` function**: The original blog post had the base case returning `[]` instead of `ys`:
```ocaml
(* Original - incorrect *)
let rec union xs ys =
  match xs with
  | [] -> []  (* Bug: should return ys *)
  | x :: xs' -> ...

(* Fixed version *)
let rec union xs ys =
  match xs with
  | [] -> ys  (* Correct: return the remaining list *)
  | x :: xs' -> ...
```

This bug would cause the dependency tracking to drop dependencies when merging read sets in the bind operation (`>>=`).

A `reset` function was also added (not part of Neel's original code) to reset the internal ID counter between tests for isolation.

Other than these, the core algorithm is unchanged. The project has been modernized with Dune build system, GitHub Actions CI, and a comprehensive test suite using Alcotest.

## Known limitations

**Cycle Detection**: The implementation does not detect cycles in the dependency graph. Creating a cycle (e.g., `a = a + 1`) will cause infinite recursion and stack overflow when the cell is evaluated.

**Memory Management**: Cells hold strong references in their `observers` lists, which may prevent garbage collection of unreachable cells that are still in another cell's observer list.

**Thread Safety**: This implementation is not thread-safe. It uses mutable state (cell fields, global ID counter) without synchronization. Designed for single-threaded use only.

## Compare different implementations

- [OCaml](https://github.com/FranklinChen/spreadsheet-ocaml)
- [Scala](https://github.com/FranklinChen/spreadsheet-scala)
- [Haskell](https://github.com/FranklinChen/spreadsheet-haskell)
- [Ruby](https://github.com/FranklinChen/spreadsheet-ruby)
