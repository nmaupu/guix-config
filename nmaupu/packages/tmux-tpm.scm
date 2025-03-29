(define-module (nmaupu packages tmux-tpm)
  #:use-module (guix build-system trivial)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix git-download))

(define-public tmux-tpm
  (package
    (name "tmux-tpm")
    (version "3.1.0-99469c4a9b1ccf77fade25842dc7bafbc8ce9946")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/tmux-plugins/tpm.git")
                    (commit "99469c4a9b1ccf77fade25842dc7bafbc8ce9946")))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "01ribl326n6n0qcq68a8pllbrz6mgw55kxhf9mjdc5vw01zjcvw5"))))
    (build-system trivial-build-system)
    (arguments
     `(#:modules ((guix build utils))
       #:builder (begin
                   (use-modules (guix build utils))
                   (let* ((out (assoc-ref %outputs "out"))
                          (source (assoc-ref %build-inputs "source")))
                     (mkdir-p out)
                     (copy-recursively source out)))))
    (home-page "https://github.com/tmux-plugins/tpm")
    (synopsis "Tmux Plugin Manager")
    (description "TPM manages tmux plugins from configuration.")
    (license expat)))
