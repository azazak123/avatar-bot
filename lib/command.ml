type t =
  | Start of { token : string; chat_id : int }
  | TransformImage of { token : string; chat_id : int; file_id : string }
[@@deriving show]

let welcome token chat_id =
  Telegram_api.send_message token chat_id
    "Hi ! This bot can ukrainianize your avatar ! Just send a picture and you \
     will receive its copy with the Ukrainian flag as a round border !"

let transform_image token chat_id file_id =
  let ( let* ) = Lwt.bind in

  Logs.info (fun m -> m "Get file with file_id: %s" file_id);
  let* file = Telegram_api.get_file token file_id in

  Logs.info (fun m -> m "Download file with file_path: %s" file.file_path);
  let* binary = Telegram_api.download_file token file.file_path in

  Logs.info (fun m -> m "Send file %s to the chat %d" file_id chat_id);
  Telegram_api.send_photo token chat_id binary

let process command =
  let ( let* ) = Lwt.bind in
  let* resp, _body =
    match command with
    | Start { token; chat_id } -> welcome token chat_id
    | TransformImage { token; chat_id; file_id } ->
        transform_image token chat_id file_id
  in
  resp |> Cohttp.Response.status |> Cohttp.Code.code_of_status
  |> (function code when code >= 200 && code < 300 -> true | _ -> false)
  |> Lwt_io.printf {|{"body": { "result":"%b" } }|}
  |> Lwt.map Result.ok
