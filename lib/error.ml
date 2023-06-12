type error =
  | BotTokenNotExist
      [@printer
        fun fmt _ -> fprintf fmt "Bot token is not exist in input parameters"]
  | ChatIdNotExist
      [@printer
        fun fmt _ ->
          fprintf fmt
            "Field \"message > chat > id\" is not exist in input parameters"]
[@@deriving show]
