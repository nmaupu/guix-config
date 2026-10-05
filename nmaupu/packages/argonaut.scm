(define-module (nmaupu packages argonaut)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download))

;; The release binary is a statically linked Go binary so it runs on Guix
;; without patching the ELF interpreter.
(define-public argonaut
  (package
    (name "argonaut")
    (version "2.20.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/darksworm/argonaut/releases/download"
                           "/v" version "/argonaut-" version "-linux-amd64.tar.gz"))
       (sha256
        (base32 "132arbaf0z5gqajg6sng2a2xlx6brrbdbpdj0f5np7jz3yv9s2na"))))
    (build-system copy-build-system)
    (arguments
     `(#:install-plan '(("argonaut" "bin/"))
       #:phases (modify-phases %standard-phases
                  (add-after 'install 'make-executable
                    (lambda* (#:key outputs #:allow-other-keys)
                      (let ((out (assoc-ref outputs "out")))
                        (chmod (string-append out "/bin/argonaut") #o555)
                        #t))))))
    (supported-systems '("x86_64-linux"))
    (home-page "https://github.com/darksworm/argonaut")
    (synopsis "Terminal UI for Argo CD")
    (description "Argonaut is a keyboard-first terminal UI for Argo CD, to browse,
sync, diff and roll back applications across clusters, projects and namespaces.")
    (license license:gpl3)))
