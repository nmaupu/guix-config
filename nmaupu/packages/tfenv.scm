(define-module (nmaupu packages tfenv)
  #:use-module (guix build-system copy)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix git-download))

(define-public tfenv
  (package
    (name "tfenv")
    (version "v3.0.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/tfutils/tfenv.git")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0jvs7bk2gaspanb4qpxzd4m2ya5pz3d1izam6k7lw30hyn7mlnnq"))))
    (build-system copy-build-system)
    (home-page "https://github.com/tfutils/tfenv")
    (synopsis "Terraform version manager inspired by rbenv")
    (description "Terraform version manager inspired by rbenv")
    (license expat)))
