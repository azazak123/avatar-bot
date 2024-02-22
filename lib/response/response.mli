type t = { ok : bool; error_code : int option; description : string option }

val yojson_of_t : t -> Yojson.Safe.t
val to_string : t -> string
