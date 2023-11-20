type t =
  | FieldNotExist of string
      [@printer
        fun fmt -> fprintf fmt "Field \"%s\" does not exist in input parameters"]
[@@deriving show]
