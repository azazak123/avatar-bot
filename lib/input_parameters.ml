open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type chat = { id : int } [@@deriving of_yojson] [@@yojson.allow_extra_fields]

type photo = { file_id : string }
[@@deriving of_yojson] [@@yojson.allow_extra_fields]

type message = { chat : chat; photo : photo array option [@yojson.option] }
[@@deriving of_yojson] [@@yojson.allow_extra_fields]

type t = { bot_token : string; message : message }
[@@deriving of_yojson] [@@yojson.allow_extra_fields]

let of_string str = str |> Yojson.Safe.from_string |> t_of_yojson

let to_command parameters =
  match parameters.message.photo with
  | Some arr ->
      Command.TransformImage
        {
          token = parameters.bot_token;
          chat_id = parameters.message.chat.id;
          file_id = arr.(Array.length arr - 1).file_id;
        }
  | None ->
      Command.Start
        { token = parameters.bot_token; chat_id = parameters.message.chat.id }
