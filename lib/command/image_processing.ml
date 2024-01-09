let ukrainianize binary =
  (* Save image to file *)
  let fname, file = Filename.open_temp_file ~mode:[ Open_binary ] "" "" in
  Logs.info (fun m -> m "Save image in %s" fname);
  output_string file binary;
  close_out file;

  Logs.info (fun m -> m "Load image from %s" fname);
  let stb_image = Result.get_ok @@ Stb_image.load fname in

  (* Get Bimage.Image from Stb_image *)
  let width_avatar = Stb_image.width stb_image in
  let height_avatar = Stb_image.height stb_image in
  let channels_avatar = Stb_image.channels stb_image in
  let avatar_image =
    Bimage.Image.of_data Bimage.Color.rgb width_avatar height_avatar
      (Stb_image.data stb_image)
  in

  Logs.info (fun m -> m "Edit loaded image");
  let thickness = 35 in

  let width = width_avatar + (2 * thickness) in
  let height = height_avatar + (2 * thickness) in

  let r = min width_avatar height_avatar / 2 in
  let c_x = width / 2 in
  let c_y = height / 2 in

  let image = Bimage.Image.v Bimage.u8 Bimage.Color.rgb width height in

  for x = 0 to width do
    for y = 0 to height do
      if ((x - c_x) * (x - c_x)) + ((y - c_y) * (y - c_y)) > r * r then
        Bimage.Image.set_pixel image x y
          (Bimage.Pixel.v Bimage.Color.rgb
             (if y < c_y then [ 0.; 0.34; 0.72 ] else [ 1.; 0.84; 0. ]))
      else
        let x_avatar = x - thickness in
        let y_avatar = y - thickness in
        Bimage.Image.set_pixel image x y
          (Bimage.Image.get_pixel avatar_image x_avatar y_avatar)
    done
  done;

  (* Save edited image to file *)
  let fname = Filename.temp_file "" "" in
  Logs.info (fun m -> m "Save edited image in %s" fname);
  Stb_image_write.png fname ~w:width ~h:height ~c:channels_avatar
    (Bimage.Image.data image);

  Logs.info (fun m -> m "Load edited image from %s" fname);
  let file = open_in_bin fname in
  let binary = In_channel.input_all file in
  close_in file;
  binary
