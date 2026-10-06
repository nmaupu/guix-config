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

(define-public terragrunt-0.99
  (package
    (inherit (make-terragrunt #:version "0.99.5"
                              #:amd64-hash (base32 "1kbl1ydz82yhlh9k97d7h7g33r6wcgy73zcnav46f6zdrvh31av5")
                              #:arm64-hash (base32 "195dri5na9jw51c7h4r49sp9kmxdlhq6mqz2cdwnxh81g76vp92p")))
    (name "terragrunt-0.99")))

(define-public terragrunt-1.1.6
  (package
    (inherit (make-terragrunt #:version "1.1.6"
                              #:amd64-hash (base32 "014vyrmh7pshczwl37hdm56apkbza15pzcdwv80bln274sxq0nnp")
                              #:arm64-hash (base32 "17b4h5akk474770q12pkbhagp17vksyq04c3vfgk0ymfkgwkvd24")))
    (name "terragrunt-1.1.6")))

(define-public terragrunt
  (package
    (inherit terragrunt-1.1.6)
    (name "terragrunt")))
