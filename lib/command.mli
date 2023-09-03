type t =
  | Start of { token : string; chat_id : int }
  | TransformImage of { token : string; chat_id : int; file_id : string }

val pp : Format.formatter -> t -> unit
val show : t -> string
val process : t -> (unit, 'a) result Lwt.t
