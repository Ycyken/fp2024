(** Copyright 2024-2025, Friend-zva, RodionovMaxim05 *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

open Ocaml_printf_lib.Ast
open Ocaml_printf_lib.Parser
open Ocaml_printf_lib.Inferencer
open Ocaml_printf_lib.Pprinter
open Stdio

type opts =
  { mutable dump_parsetree : bool
  ; mutable input_file : string option
  }

let run_single dump_parsetree input_source =
  let text =
    match input_source with
    | Some file_name -> In_channel.read_all file_name |> String.trim
    | None -> In_channel.input_all stdin |> String.trim
  in
  let ast = parse text in
  match ast with
  | Error error -> print_endline error
  | Ok ast ->
    if dump_parsetree
    then print_endline (show_structure ast)
    else (
      match run_inferencer ast env_with_print_int with
      | Ok out_list ->
        List.iter
          (function
            | Some id, type' -> Format.printf "val %s : %a\n" id pp_core_type type'
            | None, type' -> Format.printf "- : %a\n" pp_core_type type')
          out_list
      | Error e -> Format.printf "Infer error: %a\n" pp_error e)
;;

let () =
  let options = { dump_parsetree = false; input_file = None } in
  let () =
    let open Arg in
    parse
      [ ( "-dparsetree"
        , Unit (fun () -> options.dump_parsetree <- true)
        , "Dump parse tree, don't evaluate anything" )
      ; ( "-fromfile"
        , String (fun filename -> options.input_file <- Some filename)
        , "Read code from the file" )
      ]
      (fun _ ->
        Format.eprintf "Positional arguments are not supported\n";
        exit 1)
      "Read-Eval-Print-Loop for custom language"
  in
  run_single options.dump_parsetree options.input_file
;;
