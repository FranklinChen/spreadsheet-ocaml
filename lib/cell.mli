(** Reactive dataflow spreadsheet cells.

    This module implements a reactive dataflow system where cells hold cached
    computations that automatically track their dependencies. When a cell is
    updated via {!set}, all transitive dependents are recursively invalidated so
    that subsequent reads recompute fresh values.

    Build dependency graphs declaratively using the monadic interface
    ({!return}, {!val-(>>=)}, {!val-cell}, {!get}, {!set}, {!run}). *)

type 'a cell
(** A cell is a mutable container that holds a cached value of type ['a],
    together with its defining computation and dependency tracking information.
*)

type 'a exp
(** An expression is a computation that produces a value of type ['a] while
    recording which cells were read during evaluation. *)

val return : 'a -> 'a exp
(** [return v] is an expression that produces the value [v] without reading any
    cells. *)

val ( >>= ) : 'a exp -> ('a -> 'b exp) -> 'b exp
(** [e1 >>= f] sequences two computations: it first evaluates [e1] to obtain a
    value [v], then evaluates [f v]. The read sets of both computations are
    merged so that the resulting expression depends on every cell read by either
    sub-expression. *)

val cell : 'a exp -> 'a cell exp
(** [cell e] creates a new reactive cell whose value is defined by the
    expression [e]. The cell is initially unevaluated; its computation runs
    lazily the first time the cell is read via {!get}. *)

val get : 'a cell -> 'a exp
(** [get c] reads the current value of cell [c]. If the value is cached, it is
    returned immediately. Otherwise the cell's computation is evaluated, the
    result is cached, and [c] registers itself as an observer of every cell that
    was read during evaluation, establishing a dependency edge. *)

val set : 'a cell -> 'a exp -> unit
(** [set c e] replaces the computation of cell [c] with [e] and recursively
    invalidates all transitive dependents: their cached values are cleared and
    their observer registrations are removed, so the next {!get} will recompute.
*)

val run : 'a exp -> 'a
(** [run e] evaluates the expression [e] and returns its value, discarding the
    read set. Use this at the top level to extract a result without establishing
    any dependency tracking. *)

val reset : unit -> unit
(** [reset ()] resets the internal cell ID counter to zero. Call between tests
    for isolation. Not part of Neel's original code. *)
