open Avatar_bot

let set_logging () =
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Logs.Info)

let get_token json =
  let open Yojson.Basic.Util in
  json |> path [ "bot_token" ] |> Option.map to_string

let get_chat_id json =
  let open Yojson.Basic.Util in
  json |> path [ "message"; "chat"; "id" ] |> Option.map to_int

let main () =
  set_logging ();

  let json_string = Sys.argv.(1) in

  Logs.info (fun m -> m "Input parameters: %s" json_string);

  let json = Yojson.Basic.from_string json_string in

  match
    let ( let* ) = Stdlib.Result.bind in
    let* token =
      get_token json |> Option.to_result ~none:Error.BotTokenNotExist
    in
    let* chat_id =
      get_chat_id json |> Option.to_result ~none:Error.ChatIdNotExist
    in

    Lwt_main.run @@ Command.process @@ Command.Start (token, chat_id)
  with
  | Ok () -> ()
  | Error err ->
      Logs.err (fun m -> m "Error: %s." (Error.show err));
      Printf.printf {|{"body": { "result":"%b"} }|} false;
      Stdlib.exit 1

let () = main ()
