(define-module (nmaupu packages temporal-cli)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download))

;; The release binary is a statically linked Go binary so it runs on Guix
;; without patching the ELF interpreter.
(define-public temporal-cli
  (package
    (name "temporal-cli")
    (version "1.10.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/temporalio/cli/releases/download"
                           "/v" version "/temporal_cli_" version "_linux_amd64.tar.gz"))
       (sha256
        (base32 "1438s4sffsns0fp095mmay9xr0nk1z6qa7mp7dv0528h7lglc7sj"))))
    (build-system copy-build-system)
    (arguments
     `(#:install-plan '(("temporal" "bin/"))
       #:phases (modify-phases %standard-phases
                  (add-after 'install 'make-executable
                    (lambda* (#:key outputs #:allow-other-keys)
                      (let ((out (assoc-ref outputs "out")))
                        (chmod (string-append out "/bin/temporal") #o555)
                        #t))))))
    (supported-systems '("x86_64-linux"))
    (home-page "https://github.com/temporalio/cli")
    (synopsis "Command-line interface for Temporal")
    (description "The Temporal CLI is a command-line tool for interacting with
the Temporal Service.  It manages, monitors and debugs Temporal applications
and also includes an embedded development server.")
    (license license:expat)))
