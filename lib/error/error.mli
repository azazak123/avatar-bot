type t = FieldNotExist of string

val pp : Format.formatter -> t -> unit
val show : t -> string
