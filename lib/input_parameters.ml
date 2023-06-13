type chat = { id : int } [@@deriving yojson { strict = false }]
type message = { chat : chat } [@@deriving yojson { strict = false }]

type t = { bot_token : string; message : message }
[@@deriving yojson { strict = false }]
