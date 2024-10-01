(** Copyright 2024, Ksenia Kotelnikova <xeniia.ka@gmail.com>, Gleb Nasretdinov <gleb.nasretdinov@proton.me> *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

open AST

let rec print_expr indent = function
  | Const (Int_lt i) -> Printf.printf "%s| Const(Int: %d)\n" (String.make indent '-') i
  | Const (Bool_lt b) -> Printf.printf "%s| Const(Bool: %b)\n" (String.make indent '-') b
  | Const (String_lt s) ->
    Printf.printf "%s| Const(String: \"%s\")\n" (String.make indent '-') s
  | Const Unit_lt -> Printf.printf "%s| Const(Unit)\n" (String.make indent '-')
  | Tuple list -> List.iter (print_expr indent) list
  | Variable (Ident name) ->
    Printf.printf "%s| Variable(%s)\n" (String.make indent '-') name
  | Bin_expr (op, left, right) ->
    Printf.printf "%s| Binary expr(\n" (String.make indent '-');
    print_bin_op indent op;
    print_expr (indent + 2) left;
    print_expr (indent + 2) right
  | If_then_else (cond, then_body, else_body) ->
    Printf.printf "%s| If Then Else(\n" (String.make indent '-');
    Printf.printf "%sCONDITION\n" (String.make indent ' ');
    print_expr (indent + 2) cond;
    Printf.printf "%sTHEN BRANCH\n" (String.make (indent + 2) ' ');
    List.iter (print_expr (indent + 4)) then_body;
    Printf.printf "%sELSE BRANCH\n" (String.make (indent + 2) ' ');
    (match else_body with
     | Some body -> List.iter (print_expr (indent + 4)) body
     | None -> Printf.printf "No else body")
  | Function_def (flag, name, args, body) ->
    Printf.printf
      "%s| %s Function(%s):\n"
      (String.make indent '-')
      (match flag with
       | None -> ""
       | Rec -> "Rec")
      (match name with
       | Some n -> n
       | None -> "Anonymous");
    Printf.printf "%sARGS\n" (String.make (indent + 2) ' ');
    List.iter (print_expr (indent + 4)) args;
    Printf.printf "%sBODY\n" (String.make (indent + 2) ' ');
    List.iter (print_expr (indent + 4)) body
  | Function_dec (flag, name, args) ->
    Printf.printf
      "%s| %s Function Declaration(%s):\n"
      (String.make indent '-')
      (match flag with
       | None -> ""
       | Rec -> "Rec")
      name;
    Printf.printf "%sARGS\n" (String.make (indent + 2) ' ');
    List.iter (print_expr (indent + 2)) args
  | Function_call (name, args) ->
    Printf.printf "%s| Function Call(%s):\n" (String.make indent '-') name;
    Printf.printf "%sARGS\n" (String.make (indent + 2) ' ');
    List.iter (print_expr (indent + 2)) args
  | Let (Ident name, value) ->
    Printf.printf "%s| Let %s =\n" (String.make indent '-') name;
    print_expr (indent + 2) value

and print_bin_op indent = function
  | Binary_equal -> Printf.printf "%s| Binary Equal\n" (String.make indent '-')
  | Binary_unequal -> Printf.printf "%s| Binary Unequal\n" (String.make indent '-')
  | Binary_less -> Printf.printf "%s| Binary Less\n" (String.make indent '-')
  | Binary_less_or_equal ->
    Printf.printf "%s| Binary Less Or Equal\n" (String.make indent ' ')
  | Binary_greater -> Printf.printf "%s| Binary Greater\n" (String.make indent '-')
  | Binary_greater_or_equal ->
    Printf.printf "%s| Binary Greater Or Equal\n" (String.make indent '-')
  | Binary_add -> Printf.printf "%s| Binary Add\n" (String.make indent '-')
  | Binary_subtract -> Printf.printf "%s| Binary Subtract\n" (String.make indent '-')
  | Binary_multiply -> Printf.printf "%s| Binary Multiply\n" (String.make indent '-')
  | Logical_or -> Printf.printf "%s| Logical Or\n" (String.make indent '-')
  | Logical_and -> Printf.printf "%s| Logical And\n" (String.make indent '-')
  | Binary_divide -> Printf.printf "%s| Binary Divide\n" (String.make indent '-')
  | Binary_or_bitwise -> Printf.printf "%s| Binary Or Bitwise\n" (String.make indent '-')
  | Binary_xor_bitwise ->
    Printf.printf "%s| Binary Xor Bitwise\n" (String.make indent '-')
  | Binary_and_bitwise ->
    Printf.printf "%s| Binary And Bitwise\n" (String.make indent '-')
;;
