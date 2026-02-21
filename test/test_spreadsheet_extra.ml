open Spreadsheet.Cell

(* Test that a cycle in the dependency graph leads to an infinite loop. *)
let test_cycle () =
  reset ();
  let a = run (cell (return 1)) in
  set a (get a >>= fun aValue -> return (aValue + 1));
  Alcotest.check_raises "raises" Stack_overflow (fun () ->
      ignore (run (get a)))

(* Test that the `set` function correctly updates the value of a cell even if the cell has not been evaluated yet. *)
let test_set_unevaluated () =
  reset ();
  let a = run (cell (return 1)) in
  set a (return 2);
  Alcotest.(check int) "equal" 2 (run (get a))

(* Test that the `set` function correctly updates the value of a cell that is read by multiple other cells. *)
let test_set_multiple_readers () =
  reset ();
  let a = run (cell (return 1)) in
  let b = run (cell (get a >>= fun aValue -> return (aValue + 1))) in
  let c = run (cell (get a >>= fun aValue -> return (aValue + 2))) in
  set a (return 2);
  Alcotest.(check int) "equal" 3 (run (get b));
  Alcotest.(check int) "equal" 4 (run (get c))

(* Test that the `set` function correctly updates the value of a cell that is read by a chain of other cells. *)
let test_set_chain () =
  reset ();
  let a = run (cell (return 1)) in
  let b = run (cell (get a >>= fun aValue -> return (aValue + 1))) in
  let c = run (cell (get b >>= fun bValue -> return (bValue + 1))) in
  set a (return 2);
  Alcotest.(check int) "equal" 4 (run (get c))

(* Test diamond dependency: A->B, A->C, B+C->D. Setting A propagates through both paths. *)
let test_diamond_dependency () =
  reset ();
  let a = run (cell (return 1)) in
  let b = run (cell (get a >>= fun v -> return (v + 10))) in
  let c = run (cell (get a >>= fun v -> return (v + 100))) in
  let d =
    run
      (cell
         (get b >>= fun bv -> get c >>= fun cv -> return (bv + cv)))
  in
  Alcotest.(check int) "initial" 112 (run (get d));
  set a (return 2);
  Alcotest.(check int) "after set" 114 (run (get d))

(* Test dynamic dependency change: a cell conditionally reads different cells based on a flag. *)
let test_dynamic_dependency_change () =
  reset ();
  let flag = run (cell (return true)) in
  let x = run (cell (return 10)) in
  let y = run (cell (return 20)) in
  let c =
    run
      (cell
         (get flag >>= fun f ->
          if f then get x >>= fun v -> return v
          else get y >>= fun v -> return v))
  in
  Alcotest.(check int) "reads x" 10 (run (get c));
  set flag (return false);
  Alcotest.(check int) "reads y" 20 (run (get c));
  set y (return 99);
  Alcotest.(check int) "y updated" 99 (run (get c))

(* Test reading the same cell twice in one expression. *)
let test_read_same_cell_twice () =
  reset ();
  let a = run (cell (return 5)) in
  let b =
    run
      (cell (get a >>= fun x -> get a >>= fun y -> return (x + y)))
  in
  Alcotest.(check int) "double read" 10 (run (get b));
  set a (return 3);
  Alcotest.(check int) "after set" 6 (run (get b))

(* Test multiple sets without intermediate gets — should return the last value. *)
let test_multiple_sets_without_gets () =
  reset ();
  let a = run (cell (return 1)) in
  let b = run (cell (get a >>= fun v -> return (v * 10))) in
  ignore (run (get b));
  set a (return 2);
  set a (return 3);
  set a (return 4);
  Alcotest.(check int) "last value" 40 (run (get b))

let () =
  let open Alcotest in
  run "spreadsheet-extra"
    [
      ( "tests",
        [
          test_case "cycle" `Quick test_cycle;
          test_case "set unevaluated" `Quick test_set_unevaluated;
          test_case "set multiple readers" `Quick test_set_multiple_readers;
          test_case "set chain" `Quick test_set_chain;
          test_case "diamond dependency" `Quick test_diamond_dependency;
          test_case "dynamic dependency change" `Quick
            test_dynamic_dependency_change;
          test_case "read same cell twice" `Quick test_read_same_cell_twice;
          test_case "multiple sets without gets" `Quick
            test_multiple_sets_without_gets;
        ] );
    ]
