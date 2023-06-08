(lang dune 3.7)

(name avatar-bot)

(generate_opam_files true)

(source
 (github azazak123/avatar-bot))

(authors "Volodymyr Antonov <azazaka2002@gmail.com>")

(maintainers "Volodymyr Antonov <azazaka2002@gmail.com>")

(license MIT)

(package
 (name avatar-bot)
 (synopsis "Avatar bot for telegram")
 (description "Avatar bot for telegram")
 (depends ocaml dune cohttp cohttp-lwt-unix tls-lwt yojson logs))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
