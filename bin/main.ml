open Avatar_bot

let main () =
  Dream.run @@ Dream.logger
  @@ fun request ->
  let ( let* ) = Lwt.bind in

  let* json_string = Dream.body request in
  Logs.info (fun m -> m "Input parameters: %s" json_string);

  let parameters = Input_parameters.of_string json_string in

  let command = Input_parameters.to_command parameters in
  
  Logs.info (fun m -> m "Command: %s" (Command.show command));

  let* res = Command.process command in

  Dream.json
  @@
  match res with
  | Ok () -> Printf.sprintf {|{"body": { "result":"%b"} }|} true
  | Error err ->
      Logs.err (fun m -> m "Error: %s." (Error.show err));
      Printf.sprintf {|{"body": { "result":"%b"} }|} false

let () = main ()
