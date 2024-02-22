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
  | Ok _ ->
      ({ ok = true; error_code = None; description = None } : Response.t)
      |> Response.to_string
  | Error code ->
      Logs.err (fun m -> m "Error: %d" code);
      ({
         ok = false;
         error_code = Some code;
         description = Some "Something went wrong";
       }
        : Response.t)
      |> Response.to_string

let () = main ()
