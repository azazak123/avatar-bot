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

let send_photo token chat_id file =
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
          Content-Disposition: form-data; name=\"photo\"; \
          filename=\"image.png\"\r\n\
          Content-Type: image/png\r\n\
          \r\n\
          %s\r\n\
          --%s--\r\n"
         boundary chat_id boundary file boundary
  in
  let headers =
    Cohttp.Header.add (Cohttp.Header.init ()) "Content-Type"
    @@ "multipart/form-data; boundary=" ^ boundary
  in
  Client.post ~body ~headers @@ Uri.of_string
  @@ Printf.sprintf "https://api.telegram.org/bot%s/sendPhoto" token

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
