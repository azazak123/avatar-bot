type chat = { id : int }
type photo = { file_id : string }
type document = { file_id : string; mime_type : string }

type message = {
  chat : chat;
  photo : photo array option;
  document : document option;
}

type t = { message : message }

val of_string : string -> t
val to_command : string -> t -> Command.t
