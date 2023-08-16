open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type chat = { id : int } [@@deriving of_yojson] [@@yojson.allow_extra_fields]

type message = { chat : chat }
[@@deriving of_yojson] [@@yojson.allow_extra_fields]

type t = { bot_token : string; message : message }
[@@deriving of_yojson] [@@yojson.allow_extra_fields]

let of_string str = str |> Yojson.Safe.from_string |> t_of_yojson
