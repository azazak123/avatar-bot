let ukrainianize binary =
  (* Save image to file *)
  let fname, file = Filename.open_temp_file ~mode:[ Open_binary ] "" "" in
  Logs.info (fun m -> m "Save image in %s" fname);
  output_string file binary;
  close_out file;

  Logs.info (fun m -> m "Load image from %s" fname);
  let stb_image = Result.get_ok @@ Stb_image.load fname in

  (* Get Bimage.Image from Stb_image *)
  let width = Stb_image.width stb_image in
  let height = Stb_image.height stb_image in
  let channels = Stb_image.channels stb_image in
  let image =
    Bimage.Image.of_data Bimage.Color.rgb width height
      (Stb_image.data stb_image)
  in

  Logs.info (fun m -> m "Edit loaded image");
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
  Stb_image_write.png fname ~w:width ~h:height ~c:channels
    (Bimage.Image.data image);

  Logs.info (fun m -> m "Load edited image from %s" fname);
  let file = open_in_bin fname in
  let binary = In_channel.input_all file in
  close_in file;
  binary
