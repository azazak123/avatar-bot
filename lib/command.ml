type t =
  | Start of { token : string; chat_id : int }
  | TransformImage of { token : string; chat_id : int; file_id : string }
[@@deriving show]

let welcome token chat_id =
  Telegram_api.send_message token chat_id
    "Hi ! This bot can ukrainianize your avatar ! Just send a picture and you \
     will receive its copy with the Ukrainian flag as a round border !"

let process command =
  let ( let* ) = Lwt.bind in
  let* resp, _body =
    match command with
    | Start { token; chat_id } -> welcome token chat_id
    | TransformImage { token; chat_id; file_id = _ } -> welcome token chat_id
  in
  resp |> Cohttp.Response.status |> Cohttp.Code.code_of_status
  |> (function code when code >= 200 && code < 300 -> true | _ -> false)
  |> Lwt_io.printf {|{"body": { "result":"%b" } }|}
  |> Lwt.map Result.ok
