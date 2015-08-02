module Cell : Spreadsheet.CELL = struct
  type 'a cell = {
    mutable code      : 'a exp;
    mutable value     : 'a option;
    mutable reads     : ecell list;
    mutable observers : ecell list;
    id                : int
  }
  and 'a exp = unit -> ('a * ecell list)
  and ecell = Pack : 'a cell -> ecell

  let id (Pack c) = c.id

  let rec union xs ys =
    match xs with
    | [] -> ys
    | x :: xs' ->
      if List.exists (fun y -> id x = id y) ys then
        union xs' ys
      else
        x :: (union xs' ys)

  let return v () = (v, [])
  let (>>=) cmd f () =
    let (a, cs) = cmd () in
    let (b, ds) = f a () in
    (b, union cs ds)

  let r = ref 0
  let new_id () = incr r; !r

  let cell exp () =
    let n = new_id() in
    let cell = {
      code = exp;
      value = None;
      reads = [];
      observers = [];
      id = n;
    } in
    (cell, [])

  let get c () =
    match c.value with
    | Some v -> (v, [Pack c])
    | None ->
      let (v, ds) = c.code ()  in
      c.value <- Some v;
      c.reads <- ds;
      List.iter (fun (Pack d) -> d.observers <- (Pack c) :: d.observers) ds;
      (v, [Pack c])

  let remove_observer o (Pack c) =
    c.observers <- List.filter (fun o' -> id o != id o') c.observers

  let rec invalidate (Pack c) =
    let os = c.observers in
    let rs = c.reads in
    c.observers <- [];
    c.value <- None;
    c.reads <- [];
    List.iter (remove_observer (Pack c)) rs;
    List.iter invalidate os

  let set c exp =
    c.code <- exp;
    invalidate (Pack c)

  let run cmd = fst (cmd ())
end
