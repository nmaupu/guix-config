(define-module (nmaupu packages antidote)
  #:use-module (guix build-system trivial)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix git-download))

(define-public antidote
  (package
    (name "antidote")
    (version "1.9.7-9be325619f398a4b2c4f00795345844aeeacaddf")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/mattmc3/antidote.git")
                    (commit "9be325619f398a4b2c4f00795345844aeeacaddf")))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1jn7w7jwn77snhqfz53q252vilqcmvslj3k0g8dxp2dqqvb47n6y"))))
    (build-system trivial-build-system)
    (arguments
     `(#:modules ((guix build utils))
       #:builder (begin
                   (use-modules (guix build utils))
                   (let* ((out (assoc-ref %outputs "out"))
                          (source (assoc-ref %build-inputs "source")))
                     (mkdir-p out)
                     (copy-recursively source out)))))
    (home-page "https://antidote.sh")
    (synopsis "Antidote ZSH Plugin Manager")
    (description "Antidote is a Zsh plugin manager made from the ground up thinking about performance.")
    (license expat)))
