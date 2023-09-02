type t =
  | Start of { token : string; chat_id : int }
  | TransformImage of { token : string; chat_id : int; file_id : string }
[@@deriving show]

let welcome token chat_id =
  Telegram_api.send_message token chat_id
    "Hi ! This bot can ukrainianize your avatar ! Just send a picture and you \
     will receive its copy with the Ukrainian flag as a round border !"

let transform_image token chat_id file_id =
  let ( let* ) = Lwt.bind in

  Logs.info (fun m -> m "Get file with file_id: %s" file_id);
  let* file = Telegram_api.get_file token file_id in

  Logs.info (fun m -> m "Download file with file_path: %s" file.file_path);
  let* binary = Telegram_api.download_file token file.file_path in

  (* Save image to file *)
  let fname, file = Filename.open_temp_file ~mode:[ Open_binary ] "" "" in
  Logs.info (fun m -> m "Save image in %s" fname);
  output_string file binary;
  close_out file;

  Logs.info (fun m -> m "Load image from %s" fname);
  let image = Result.get_ok @@ Bimage_unix.Stb.read_u8 Bimage.Color.rgb fname in

  Logs.info (fun m -> m "Edit loaded image");
  let width, height, _channel = Bimage.Image.shape image in
  let thickness = 35 in
  let r = (min width height / 2) - thickness in
  let c_x = width / 2 in
  let c_y = height / 2 in

  for x = 0 to width do
    for y = 0 to height do
      if ((x - c_x) * (x - c_x)) + ((y - c_y) * (y - c_y)) > r * r then
        Bimage.Image.set_pixel image x y
          (Bimage.Pixel.v Bimage.Color.rgb
             (if y < c_y then [ 0.; 0.34; 0.72 ] else [ 1.; 0.84; 0. ]))
    done
  done;

  (* Save edited image to file *)
  let fname = Filename.temp_file "" "" in
  Logs.info (fun m -> m "Save edited image in %s" fname);
  let () = Result.get_ok @@ Bimage_unix.Stb.write_png fname image in

  Logs.info (fun m -> m "Load edited image from %s" fname);
  let file = open_in_bin fname in
  let binary = In_channel.input_all file in
  close_in file;

  Logs.info (fun m -> m "Send file %s to the chat %d" fname chat_id);
  Telegram_api.send_photo token chat_id binary

let process command =
  let ( let* ) = Lwt.bind in
  let* resp, _body =
    match command with
    | Start { token; chat_id } -> welcome token chat_id
    | TransformImage { token; chat_id; file_id } ->
        transform_image token chat_id file_id
  in
  resp |> Cohttp.Response.status |> Cohttp.Code.code_of_status
  |> (function code when code >= 200 && code < 300 -> true | _ -> false)
  |> Lwt_io.printf {|{"body": { "result":"%b" } }|}
  |> Lwt.map Result.ok
