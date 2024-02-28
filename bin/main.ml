open Avatar_bot

let set_logging () =
  Logs.set_reporter @@ Logs_fmt.reporter ();
  Logs.set_level @@ Some Logs.Info

let main () =
  set_logging ();

  let port_opt = Option.bind (Sys.getenv_opt "PORT") int_of_string_opt in
  let port = if Option.is_none port_opt then 8080 else Option.get port_opt in

  let bot_token_opt = Sys.getenv_opt "BOT_TOKEN" in
  let bot_token =
    if Option.is_some bot_token_opt then Option.get bot_token_opt
    else (
      Logs.err (fun m -> m "BOT_TOKEN env was not found");
      exit 1)
  in

  Dream.run ~port @@ Dream.logger
  @@ fun request ->
  let ( let* ) = Lwt.bind in

  let* json_string = Dream.body request in
  Logs.info (fun m -> m "Input parameters: %s" json_string);

  let parameters = Input_parameters.of_string json_string in

  let command = Input_parameters.to_command bot_token parameters in

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
