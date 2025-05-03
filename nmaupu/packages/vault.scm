(define-module (nmaupu packages vault)
  #:use-module ((nonguix licenses) #:prefix licensenon:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system copy)
  #:use-module (guix utils)
  #:use-module (ice-9 optargs)
  #:use-module (gnu packages compression))

(define*-public (make-vault #:optional
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
      (name "vault")
      (version version)
      (source
       (origin
         (method url-fetch)
         (uri (string-append "https://releases.hashicorp.com/vault/" version
                             "/vault_" version "_linux_" arch ".zip"))
         (sha256 hash)))
      (build-system copy-build-system)
      (arguments
       `(#:install-plan '(("vault" "bin/vault"))
         #:phases (modify-phases %standard-phases
                    (add-after 'install 'make-executable
                      (lambda* (#:key outputs #:allow-other-keys)
                        (let* ((out (assoc-ref outputs "out"))
                               (bin (string-append out "/bin/vault")))
                          (chmod bin #o555)
                          #t))))))
      (native-inputs (list unzip))
      (home-page "https://www.hashicorp.com/en/products/vault")
      (synopsis "Vault by Hashicorp")
      (description "Vault is a tool for securely accessing secrets.")
      (license (licensenon:nonfree "https://github.com/hashicorp/vault/blob/main/LICENSE")))))

(define-public vault-1.19.3
  (package
    (inherit (make-vault #:version "1.19.3"
                         #:amd64-hash (base32 "1qivljgp6rxbg3yjfljcgs66r56nsy4r445x0liisxdpk82zbccl")
                         #:arm64-hash (base32 "103c9gpqwa31wms73c82hc105nkp4fpxff0jcp6b18b6j72icvaz")))
    (name "vault-1.19.3")))

(define-public vault
  (package
    (inherit vault-1.19.3)
    (name "vault")))
