(define-module (nmaupu packages goenv)
  #:use-module (guix build-system trivial)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix git-download))

(define-public goenv
  (package
    (name "goenv")
    (version "da12b0d0af204f1aeb0e75d1d61496503e52ddac")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/nmaupu/goenv.git")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "14xs4r2c7m4xdvfl6350x2rkw4qw6rcmsws7yf33hs6kvwyir6ww"))))
    (build-system trivial-build-system)
    (arguments
     `(#:modules ((guix build utils))
       #:builder (begin
                   (use-modules (guix build utils))
                   (let* ((out (assoc-ref %outputs "out"))
                          (source (assoc-ref %build-inputs "source")))
                     (mkdir-p out)
                     (copy-recursively source out)))))
    (home-page "https://github.com/go-nv/goenv.git")
    (synopsis "goenv aims to be as simple as possible and follow the already established successful version management model of pyenv and rbenv.")
    (description "goenv aims to be as simple as possible and follow the already established successful version management model of pyenv and rbenv.")
    (license expat)))
