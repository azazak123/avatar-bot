open Cohttp_lwt_unix

let send_message token chat_id text =
  Client.get @@ Uri.of_string
  @@ Printf.sprintf
       "https://api.telegram.org/bot%s/sendMessage?chat_id=%d&text=%s" token
       chat_id text
