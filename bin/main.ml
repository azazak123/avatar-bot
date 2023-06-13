open Avatar_bot

let set_logging () =
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Logs.Info)

let main () =
  set_logging ();

  let json_string = Sys.argv.(1) in

  Logs.info (fun m -> m "Input parameters: %s" json_string);

  let json = Yojson.Safe.from_string json_string in

  match
    let ( let* ) = Result.bind in
    let* parameters =
      Input_parameters.of_yojson json
      |> Result.map_error (fun s -> Error.FieldNotExist s)
    in

    Lwt_main.run @@ Command.process
    @@ Command.Start (parameters.bot_token, parameters.message.chat.id)
  with
  | Ok () -> ()
  | Error err ->
      Logs.err (fun m -> m "Error: %s." (Error.show err));
      Printf.printf {|{"body": { "result":"%b"} }|} false;
      Stdlib.exit 1

let () = main ()
