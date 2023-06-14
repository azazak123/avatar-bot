type t =
  | FieldNotExist of string
      [@printer
        fun fmt -> fprintf fmt "Field \"%s\" is not exist in input parameters"]
[@@deriving show]
