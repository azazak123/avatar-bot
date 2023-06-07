open Lwt
open Cohttp
open Cohttp_lwt_unix

let token =
  let open Yojson.Basic in
  let json = from_string Sys.argv.(1) in
  json |> Util.member "bot_token" |> Util.to_string

let get_me = Printf.sprintf "https://api.telegram.org/bot%s/getMe"

let () =
  Lwt_main.run
    ( token |> get_me |> Uri.of_string |> Client.get >>= fun (resp, _body) ->
      resp |> Response.status |> Code.code_of_status
      |> Lwt_io.printf "{\"body\":\"%d\"}" )
