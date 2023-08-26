open Avatar_bot

let set_logging () =
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Logs.Info)

let main () =
  set_logging ();

  let json_string = Sys.argv.(1) in

  Logs.info (fun m -> m "Input parameters: %s" json_string);

  match
    let parameters = Input_parameters.of_string json_string in
    let command = Input_parameters.to_command parameters in

    Logs.info (fun m -> m "Command: %s" (Command.show command));

    Lwt_main.run @@ Command.process command
  with
  | Ok () -> ()
  | Error err ->
      Logs.err (fun m -> m "Error: %s." (Error.show err));
      Printf.printf {|{"body": { "result":"%b"} }|} false;
      Stdlib.exit 1

let () = main ()
