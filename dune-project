(lang dune 3.19)

(name spreadsheet)

(generate_opam_files true)

(source
 (github FranklinChen/spreadsheet-ocaml))

(authors "Franklin Chen <franklinchen@franklinchen.com>")

(maintainers "Franklin Chen <franklinchen@franklinchen.com>")

(license BSD-3-clause)

(documentation https://github.com/FranklinChen/spreadsheet-ocaml)

(package
 (name spreadsheet)
 (synopsis "Spreadsheet demo in OCaml")
 (description "Simulate a spreadsheet using OCaml")
 (depends
  (ocamlformat :with-dev-setup)
  (alcotest :with-test))
)
 
; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
