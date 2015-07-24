module Test (Cell : Spreadsheet.CELL) =
  struct
    open Cell

    (* Example of a graph of cells. *)
    let three_cells : (int cell * int cell * int cell) exp =
      (* a = 1 *)
      cell (return 1) >>= fun a ->

      (* b = 2 *)
      cell (return 2) >>= fun b ->

      (* c = a + b *)
      cell (
          get a >>= fun aValue ->
          get b >>= fun bValue ->
          return (aValue + bValue)
        ) >>= fun c ->

      return (a, b, c)

    (* Example of propagating changes. *)
    let change_dependencies : int * int * int =
      let (a, b, c) = run three_cells in

      (* c = a + b = 1 + 2 = 3 *)
      let c3 = run (get c) in

      (* a = 100
         So c = a + b = 100 + 2 = 102
       *)
      set a (return 100);
      let c102 = run (get c) in

      (* a = b*b
         b = 4
         So c = a + b = 4*4 + 4 = 20
       *)
      set a (
            get b >>= fun bValue ->
            return (bValue * bValue)
          );

      set b (return 4);
      let c20 = run (get c) in

      (c3, c102, c20)
  end

module DefaultTest = Test (DefaultSpreadsheet.Cell)

open OUnit2

let test1 test_ctxt =
  assert_equal (3, 102, 20) DefaultTest.change_dependencies

let suite =
  "spreadsheet test suite" >:::
    ["test1">:: test1]

let () =
  run_test_tt_main suite
