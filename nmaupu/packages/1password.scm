(define-module (nmaupu packages 1password)
  #:use-module (guix build-system copy)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (gnu packages compression)
  #:use-module ((nonguix licenses) #:prefix license:))

;; This package requires some rights to be changed on "op" binary (as per the readme)
;; - A group onepassword-cli has to be created
;; - To be used, the user should be added to this group
;; - op binary has to be chown to root:onepassword-cli
;; - op binary has to be chmod g+s
;; Something along those lines:
;;
;; (simple-service 'onepassword-setgid-helper privileged-program-service-type
;;                 (list (privileged-program
;;                         (program  (file-append 1password-cli "/bin/op"))
;;                         (group "onepassword-cli")
;;                         (setgid? #t))))

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
