open Cohttp_lwt_unix

type 'a tg_response = { ok : bool; result : 'a }
[@@deriving of_yojson] [@@yojson.allow_extra_fields]

type file = { file_path : string }
[@@deriving of_yojson] [@@yojson.allow_extra_fields]

let send_message token chat_id text =
  Client.get @@ Uri.of_string
  @@ Printf.sprintf
       "https://api.telegram.org/bot%s/sendMessage?chat_id=%d&text=%s" token
       chat_id text

let get_file token file_id =
  let ( let* ) = Lwt.bind in
  let* _resp, body =
    Client.get @@ Uri.of_string
    @@ Printf.sprintf "https://api.telegram.org/bot%s/getFile?file_id=%s" token
         file_id
  in
  let* tg_response_json = Cohttp_lwt.Body.to_string body in
  let tg_response =
    tg_response_json |> Yojson.Safe.from_string
    |> tg_response_of_yojson file_of_yojson
  in
  Lwt.return tg_response.result
