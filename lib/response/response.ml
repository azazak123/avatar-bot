open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t = {
  ok : bool;
  error_code : int option; [@yojson.option]
  description : string option; [@yojson.option]
}
[@@deriving yojson_of]

let to_string response = response |> yojson_of_t |> Yojson.Safe.to_string
