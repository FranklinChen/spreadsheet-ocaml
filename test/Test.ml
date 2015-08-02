module Test (Cell : Spreadsheet.CELL) =
  struct
    open OUnit2
    open Cell

    (* Example of propagating changes. *)
    let test1 test_ctxt =
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

        return (a, b, c) in

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

      assert_equal (3, 102, 20) (c3, c102, c20)

    (* Example of propagating changes when cells are different types. *)
    let test2 test_ctxt =
      (* Example of a graph of cells. *)
      let three_cells : (string cell * int cell * int cell) exp =
        (* a = "hello" *)
        cell (return "hello") >>= fun a ->

        (* b = 2 *)
        cell (return 2) >>= fun b ->

        (* c = String.length a + b *)
        cell (
            get a >>= fun aValue ->
            get b >>= fun bValue ->
            return (String.length aValue + bValue)
          ) >>= fun c ->

        return (a, b, c) in

      let (a, b, c) = run three_cells in

      (* c = String.length a + b = 5 + 2 = 7 *)
      let c7 = run (get c) in

      (* b = 3 *)
      set b (return 3);

      (* a = "no"
         So c = String.length a + b = 2 + 3 = 5
       *)
      set a (return "no");
      let c5 = run (get c) in

      assert_equal (7, 5) (c7, c5)

    let suite =
      "spreadsheet test suite" >:::
        [
          "cell depending on two cells" >:: test1;
          "cell depending on two cells of different types" >:: test2
        ]
  end

module DefaultTest = Test (DefaultSpreadsheet.Cell)

open OUnit2

let () =
  run_test_tt_main DefaultTest.suite
