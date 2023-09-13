open Cohttp_lwt_unix
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type 'a tg_response = { ok : bool; result : 'a }
[@@deriving of_yojson] [@@yojson.allow_extra_fields]

type file = { file_path : string }
[@@deriving of_yojson] [@@yojson.allow_extra_fields]

let send_message token chat_id text =
  Client.get @@ Uri.of_string
  @@ Printf.sprintf
       "https://api.telegram.org/bot%s/sendMessage?chat_id=%d&text=%s" token
       chat_id text

let send_item chat_id param_name filename mime_type binary url =
  Random.self_init ();
  let boundary = ( ^ ) "-----" @@ Int64.to_string @@ Random.bits64 () in
  let body =
    Cohttp_lwt.Body.of_string
    @@ Printf.sprintf
         "--%s\r\n\
          Content-Disposition: form-data; name=\"chat_id\"\r\n\
          \r\n\
          %d\r\n\
          --%s\r\n\
          Content-Disposition: form-data; name=\"%s\"; filename=\"%s\"\r\n\
          Content-Type: %s\r\n\
          \r\n\
          %s\r\n\
          --%s--\r\n"
         boundary chat_id boundary param_name filename mime_type binary boundary
  in
  let headers =
    Cohttp.Header.add (Cohttp.Header.init ()) "Content-Type"
    @@ "multipart/form-data; boundary=" ^ boundary
  in
  Client.post ~body ~headers url

let send_photo token chat_id photo =
  send_item chat_id "photo" "image.png" "image/png" photo
  @@ Uri.of_string
  @@ Printf.sprintf "https://api.telegram.org/bot%s/sendPhoto" token

let send_document token chat_id document filename mime_type =
  send_item chat_id "document" filename mime_type document
  @@ Uri.of_string
  @@ Printf.sprintf "https://api.telegram.org/bot%s/sendDocument" token

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

let download_file token file_path =
  let ( let* ) = Lwt.bind in
  let* _resp, body =
    Client.get @@ Uri.of_string
    @@ Printf.sprintf "https://api.telegram.org/file/bot%s/%s" token file_path
  in
  Cohttp_lwt.Body.to_string body
