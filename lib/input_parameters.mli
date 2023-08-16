type chat = { id : int }
type message = { chat : chat }
type t = { bot_token : string; message : message }

val of_string : string -> t
