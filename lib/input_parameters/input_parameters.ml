open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type chat = { id : int } [@@deriving of_yojson] [@@yojson.allow_extra_fields]

type photo = { file_id : string }
[@@deriving of_yojson] [@@yojson.allow_extra_fields]

type document = { file_id : string; mime_type : string }
[@@deriving of_yojson] [@@yojson.allow_extra_fields]

type message = {
  chat : chat;
  photo : photo array option; [@yojson.option]
  document : document option; [@yojson.option]
}
[@@deriving of_yojson] [@@yojson.allow_extra_fields]

type t = { message : message }
[@@deriving of_yojson] [@@yojson.allow_extra_fields]

let of_string str = str |> Yojson.Safe.from_string |> t_of_yojson

let to_command bot_token parameters =
  match (parameters.message.photo, parameters.message.document) with
  | Some photo, _ ->
      Command.TransformImage
        {
          token = bot_token;
          chat_id = parameters.message.chat.id;
          file_id = photo.(Array.length photo - 1).file_id;
        }
  | _, Some { file_id; mime_type }
    when mime_type = "image/jpeg" || mime_type = "image/png" ->
      Command.TransformImage
        { token = bot_token; chat_id = parameters.message.chat.id; file_id }
  | _, _ ->
      Command.Start { token = bot_token; chat_id = parameters.message.chat.id }
