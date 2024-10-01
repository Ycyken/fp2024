(** Copyright 2024, Ksenia Kotelnikova <xeniia.ka@gmail.com>, Gleb Nasretdinov <gleb.nasretdinov@proton.me> *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

open Fsharp_active_patterns_lib.AST
open Fsharp_active_patterns_lib.PrintAST

let() = 
  let factorial =
    Function
      ( Rec
      , Some "factorial"
      , [ Variable (Ident "n") ]
      , [ If_then_else
            ( Bin_expr
                ( Logical_or
                , Bin_expr (Binary_equal, Variable (Ident "n"), Const (Int_lt 0))
                , Bin_expr (Binary_equal, Variable (Ident "n"), Const (Int_lt 1)) )
            , [ Const (Int_lt 1) ]
            , Some([ Bin_expr
                  ( Binary_multiply
                  , Variable (Ident "n")
                  , Function_call
                      ( "factorial"
                      , [ Bin_expr (Binary_subtract, Variable (Ident "n"), Const (Int_lt 1)) ] ) )
              ]) )
        ] )
  in
  let program =
    [ Let (Ident "a", Const (Int_lt 10))
    ; factorial
    ; Function_call ("factorial", [ Variable (Ident "a") ])
    ]
  in
  List.iter (print_expr 0) program
;;