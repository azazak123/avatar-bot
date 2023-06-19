open Ppx_deriving_yojson_runtime

type chat = { id : int } [@@deriving of_yojson { strict = false }]
type message = { chat : chat } [@@deriving of_yojson { strict = false }]

type t = { bot_token : string; message : message }
[@@deriving of_yojson { strict = false }]

let of_string str =
  let json = Yojson.Safe.from_string str in
  match of_yojson json with
  | Result.Ok parameters -> Ok parameters
  | Result.Error error_str -> Error (Error.FieldNotExist error_str)
