(** Copyright 2024-2025, Ksenia Kotelnikova <xeniia.ka@gmail.com>, Gleb Nasretdinov <gleb.nasretdinov@proton.me> *)

(** SPDX-License-Identifier: LGPL-3.0-or-later *)

open FSharpActivePatterns.AstPrinter
open FSharpActivePatterns.Parser
open FSharpActivePatterns.Inferencer
open FSharpActivePatterns.TypesPp
open Stdlib

type input =
  | Input of string
  | EOF

type 'a run_result =
  | Result of 'a
  | Fail
  | Empty
  | End

let input_upto_sep sep ic =
  let sep_len = String.length sep in
  let take_line () = In_channel.input_line ic in
  let rec fill_buffer b =
    let line = take_line () in
    match line with
    | None -> EOF
    | Some line ->
      let line = String.trim line in
      let len = String.length line in
      (match String.ends_with ~suffix:sep line with
       | true ->
         Buffer.add_substring b line 0 (len - sep_len);
         Buffer.add_string b "\n";
         Input (Buffer.contents b)
       | false ->
         Buffer.add_string b line;
         Buffer.add_string b "\n";
         fill_buffer b)
  in
  let buffer = Buffer.create 1024 in
  fill_buffer buffer
;;

let run_single ic =
  match input_upto_sep ";;" ic with
  | EOF -> End
  | Input input ->
    let trimmed_input = String.trim input in
    if trimmed_input = ""
    then Empty
    else (
      match parse trimmed_input with
      | Some ast -> Result ast
      | None -> Fail)
;;

let run_repl dump_parsetree input_file =
  let ic =
    match input_file with
    | None -> stdin
    | Some n -> open_in n
  in
  let rec run_repl_helper run env state =
    let open Format in
    match run ic with
    | Fail -> fprintf err_formatter "Error occured\n"
    | Empty ->
      fprintf std_formatter "\n";
      print_flush ();
      run_repl_helper run env state
    | End -> ()
    | Result ast ->
      let result = infer ast env state in
      (match result with
       | new_state, Error err ->
         fprintf err_formatter "Type checking failed: %a\n" pp_error err;
         print_flush ();
         run_repl_helper run env new_state
       | new_state, Ok (env, types) ->
         (match dump_parsetree with
          | true -> print_construction std_formatter ast
          | false ->
            List.iter
              (fun t ->
                fprintf std_formatter "- : ";
                pp_typ std_formatter t)
              types;
            print_flush ());
         run_repl_helper run env new_state)
  in
  run_repl_helper run_single TypeEnvironment.empty 0
;;

type opts =
  { mutable dump_parsetree : bool
  ; mutable input_file : string option
  }

let () =
  let opts = { dump_parsetree = false; input_file = None } in
  let open Stdlib.Arg in
  let speclist =
    [ ( "-dparsetree"
      , Unit (fun _ -> opts.dump_parsetree <- true)
      , "Dump parse tree, don't evaluate anything" )
    ; ( "-fromfile"
      , String (fun filename -> opts.input_file <- Some filename)
      , "Input file name" )
    ]
  in
  let anon_func _ =
    Stdlib.Format.eprintf "Positioned arguments are not supported\n";
    Stdlib.exit 1
  in
  let usage_msg = "Read-Eval-Print-Loop for F# with Active Patterns" in
  let () = parse speclist anon_func usage_msg in
  run_repl opts.dump_parsetree opts.input_file
;;
