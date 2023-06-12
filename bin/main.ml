open Avatar_bot

let set_logging () =
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Logs.Info)

let main () =
  set_logging ();

  let json_string = Sys.argv.(1) in

  Logs.info (fun m -> m "Input parameters: %s" json_string);

  match Result.ok @@ Printf.printf {|{"body": { "result":"%b"} }|} true with
  | Ok () -> ()
  | Error err ->
      Logs.err (fun m -> m "Error: %s." (Error.show_error err));
      Printf.printf {|{"body": { "result":"%b"} }|} false;
      Stdlib.exit 1

let () = main ()
