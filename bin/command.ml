open Avatar_bot

type t = Start of string * int

let welcome token chat_id =
  let ( let* ) = Lwt.bind in
  let* resp, _body =
    Telegram_api.send_message token chat_id
      "Hi ! This bot can ukrainianize your avatar ! Simply send picture and \
       you will get it with ukrainian flag border !"
  in
  resp |> Cohttp.Response.status |> Cohttp.Code.code_of_status
  |> (function code when code >= 200 && code < 300 -> true | _ -> false)
  |> Lwt_io.printf {|{"body": { "result":"%b"} }|}
  |> Lwt.map Result.ok

let process command =
  match command with Start (token, chat_id) -> welcome token chat_id
