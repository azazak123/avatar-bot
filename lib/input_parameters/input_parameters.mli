type chat = { id : int }
type photo = { file_id : string }
type document = { file_id : string; mime_type : string }

type message = {
  chat : chat;
  photo : photo array option;
  document : document option;
}

type t = { bot_token : string; message : message }

val of_string : string -> t
val to_command : t -> Command.t
