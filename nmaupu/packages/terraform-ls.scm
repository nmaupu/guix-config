(define-module (nmaupu packages terraform-ls)
  #:use-module (guix build-system copy)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (gnu packages compression))

(define-public terraform-ls
  (package
    (name "terraform-ls")
    (version "0.38.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://releases.hashicorp.com/terraform-ls/" version
                           "/terraform-ls_" version "_linux_amd64.zip"))
       (sha256
        (base32 "0wcsqyk5cnvah3r11hsc7y6gq4bvmiiihaak2zg545hcbxq254jg"))))
    (build-system copy-build-system)
    (native-inputs (list unzip))
    (arguments
     `(#:install-plan '(("terraform-ls" "bin/terraform-ls"))))
    (home-page "https://github.com/hashicorp/terraform-ls")
    (synopsis "The official Terraform language server (terraform-ls) maintained by HashiCorp provides IDE features to any LSP-compatible editor.")
    (description "The official Terraform language server (terraform-ls) maintained by HashiCorp provides IDE features to any LSP-compatible editor.")
    (license mpl2.0)))
