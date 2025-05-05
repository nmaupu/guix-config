(define-module (nmaupu packages terragrunt)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (ice-9 optargs))

(define*-public (make-terragrunt #:optional
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
      (name "terragrunt")
      (version version)
      (source
       (origin
         (method url-fetch)
         (uri (string-append "https://github.com/gruntwork-io/terragrunt/releases/download/"
                             "v" version "/terragrunt_linux_" arch))
         (sha256 hash)))
      (build-system copy-build-system)
      (arguments
       `(#:install-plan '((,(string-append "terragrunt_linux_" arch) "bin/terragrunt"))
         #:phases (modify-phases %standard-phases
                    (add-after 'install 'make-executable
                      (lambda* (#:key outputs #:allow-other-keys)
                        (let* ((out (assoc-ref outputs "out"))
                               (bin (string-append out "/bin/terragrunt")))
                          (chmod bin #o555)
                          #t))))))
      (home-page "https://github.com/gruntwork-io/terragrunt")
      (synopsis "Terragrunt is a flexible orchestration tool that allows Infrastructure as Code written in OpenTofu/Terraform to scale.")
      (description "Terragrunt is a flexible orchestration tool that allows Infrastructure as Code written in OpenTofu/Terraform to scale.")
      (license license:expat))))

(define-public terragrunt-0.78
  (package
    (inherit (make-terragrunt #:version "0.78.0"
                              #:amd64-hash (base32 "0iiwx5nvam958km2hg7968gwdz4c0vw3yp4rhc7ifbjgqhvmpg6y")
                              #:arm64-hash (base32 "1f3c0wv35pd398c2li41wy5wxb5kkx7vp79dxmv4snij53jaak0x")))
    (name "terragrunt-0.78")))

(define-public terragrunt
  (package
    (inherit terragrunt-0.78)
    (name "terragrunt")))
