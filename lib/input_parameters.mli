type chat = { id : int }
type photo = { file_id : string }
type message = { chat : chat; photo : photo array option }
type t = { bot_token : string; message : message }

val of_string : string -> t
val to_command : t -> Command.t
