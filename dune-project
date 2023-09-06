(lang dune 3.7)

(name avatar-bot)

(generate_opam_files true)

(source
 (github azazak123/avatar-bot))

(authors "Volodymyr Antonov <azazaka2002@gmail.com>")

(maintainers "Volodymyr Antonov <azazaka2002@gmail.com>")

(license MIT)

(implicit_transitive_deps false)

(package
 (name avatar-bot)
 (synopsis "Avatar bot for telegram")
 (description "Avatar bot for telegram")
 (depends
  ocaml
  dune
  lwt
  cohttp
  cohttp-lwt-unix
  uri
  tls-lwt
  logs
  yojson
  bimage
  stb_image
  stb_image_write
  result
  ppx_deriving
  ppx_yojson_conv))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
