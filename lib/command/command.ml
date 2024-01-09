type t =
  | Start of { token : string; [@opaque] chat_id : int }
  | TransformImage of {
      token : string; [@opaque]
      chat_id : int;
      file_id : string;
    }
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

  let binary = Image_processing.ukrainianize binary in

  Logs.info (fun m -> m "Send photo to the chat %d" chat_id);
  let* _res, _body = Telegram_api.send_photo token chat_id binary in

  Logs.info (fun m -> m "Send document to the chat %d" chat_id);
  Telegram_api.send_document token chat_id binary "image.png" "image/png"

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
