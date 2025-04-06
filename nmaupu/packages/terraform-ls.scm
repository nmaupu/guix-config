(define-module (nmaupu packages terraform-ls)
  #:use-module (guix build-system copy)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (gnu packages compression))

(define-public terraform-ls
  (package
    (name "terraform-ls")
    (version "0.36.4")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://releases.hashicorp.com/terraform-ls/" version
                           "/terraform-ls_" version "_linux_amd64.zip"))
       (sha256
        (base32 "08wjzabcmjfy8jnng5xh9xvrp6ffsg5gxvkblfkh4rgyblnibx4a"))))
    (build-system copy-build-system)
    (native-inputs (list unzip))
    (arguments
     `(#:install-plan '(("terraform-ls" "bin/terraform-ls"))))
    (home-page "https://github.com/hashicorp/terraform-ls")
    (synopsis "The official Terraform language server (terraform-ls) maintained by HashiCorp provides IDE features to any LSP-compatible editor.")
    (description "The official Terraform language server (terraform-ls) maintained by HashiCorp provides IDE features to any LSP-compatible editor.")
    (license mpl2.0)))
