(lang dune 3.8)

(name perf)

(using ctypes 0.3)

(generate_opam_files true)

(source
 (github TheLortex/ocaml-perf))

(authors "Lucas Pluvinage")

(maintainers "Lucas Pluvinage")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name perf)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends ocaml dune)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
