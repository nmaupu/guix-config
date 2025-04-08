(define-module (nmaupu packages 1password)
  #:use-module (guix build-system copy)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (gnu packages compression)
  #:use-module ((nonguix licenses) #:prefix license:))

(define-public 1password-cli
  (package
    (name "1password-cli")
    (version "2.30.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://cache.agilebits.com/dist/1P/op2/pkg/v"
                           version "/op_linux_amd64_v" version ".zip"))
       (sha256
        (base32 "0a7fsmbmwa2x5kg1cijggj4w1hw0qgqg8vvs3l4zsh6brvmhfqx1"))))
    (build-system copy-build-system)
    (native-inputs (list unzip))
    (arguments
     `(#:install-plan '(("op" "bin/op"))))
    (home-page "https://1password.com/downloads/command-line")
    (synopsis "1password-cli")
    (description "1password-cli")
    (license (license:nonfree "https://1password.com/pricing"))))
