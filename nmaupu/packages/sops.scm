(define-module (nmaupu packages sops)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (ice-9 optargs))

(define*-public (make-sops #:optional
                               (system (or (%current-target-system)
                                           (%current-system)))
                               #:key
                               version
                               amd64-hash
                               arm64-hash)
  (let* ((arch+hash
          (cond
           ((target-x86-64? system)
            `("amd64" . ,amd64-hash))
           ((target-aarch64? system)
            `("arm64" . ,arm64-hash))
           (else
            (error "Unsupported system architecture" system))))
         (arch (car arch+hash))
         (hash (cdr arch+hash)))
    (package
      (name "sops")
      (version version)
      (source
       (origin
         (method url-fetch)
         (uri (string-append "https://github.com/getsops/sops/releases/download"
                             "/v" version "/sops-v" version ".linux." arch))
         (sha256 hash)))
      (build-system copy-build-system)
      (arguments
       `(#:install-plan '((,(string-append "sops-v" version ".linux." arch) "bin/sops"))
         #:phases (modify-phases %standard-phases
                    (add-after 'install 'make-executable
                      (lambda* (#:key outputs #:allow-other-keys)
                        (let* ((out (assoc-ref outputs "out"))
                               (bin (string-append out "/bin/sops")))
                          (chmod bin #o555)
                          #t))))))
      (home-page "https://github.com/getsops/sops")
      (synopsis "SOPS is an editor of encrypted files that supports YAML, JSON, ENV, INI and BINARY formats and encrypts with AWS KMS, GCP KMS, Azure Key Vault, age, and PGP.")
      (description "SOPS is an editor of encrypted files that supports YAML, JSON, ENV, INI and BINARY formats and encrypts with AWS KMS, GCP KMS, Azure Key Vault, age, and PGP.")
      (license license:mpl2.0))))

(define-public sops-3.10
  (package
    (inherit (make-sops #:version "3.10.2"
                        #:amd64-hash (base32 "0f8pf0p6z74lsm1zfs1rvkgcfpvnq7dq9j2ddr2b1m3v4d2gic3r")
                        #:arm64-hash (base32 "1x89ngszdwp2g206p7nrfhxw8fdmg6i4ghsgkvnmm3x7wq2dq7g9")))
    (name "sops-3.10")))

(define-public sops
  (package
    (inherit sops-3.10)
    (name "sops")))
