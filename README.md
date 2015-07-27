# Spreadsheet simulation in OCaml

[![Build Status](https://travis-ci.org/FranklinChen/spreadsheet-ocaml.png)](https://travis-ci.org/FranklinChen/spreadsheet-ocaml)

This is a verbatim copy of the highly imperative dataflow system implemented in OCaml given in ["How to implement a spreadsheet"](http://semantic-domain.blogspot.com/2015/07/how-to-implement-spreadsheet.html), along with a test harness and a Travis build.

## How to build the project and run the tests

First, install OCaml and Opam.

```console
$ opam install ounit
```

Build the library and also run the tests.

```console
$ ocaml setup.ml -configure --enable-tests
$ make test
```
