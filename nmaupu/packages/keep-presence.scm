(define-module (nmaupu packages keep-presence)
  #:use-module (guix build-system copy)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-xyz))

(define-public keep-presence
  (package
    (name "keep-presence")
    (version "1.0.7")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/carrot69/keep-presence.git")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1w68b4kfnzskl1qcfpp3rsxdax17hmigicwsp3snh7azxspbjykm"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan #~'(("src/keep-presence.py" "bin/keep-presence"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'patch-shebang-and-wrap
            (lambda _
              (let ((bin (string-append #$output "/bin/keep-presence")))
                ;; Upstream ships "#!/usr/bin/env python", but Guix' python
                ;; only provides "python3".
                (substitute* bin
                  (("/usr/bin/env python")
                   (string-append #$(this-package-input "python")
                                  "/bin/python3")))
                (chmod bin #o555)
                (wrap-program bin
                  `("GUIX_PYTHONPATH" ":" prefix
                    (,(getenv "GUIX_PYTHONPATH"))))))))))
    (inputs (list bash-minimal python python-pynput))
    (home-page "https://github.com/carrot69/keep-presence")
    (synopsis "Keep the computer awake by simulating user input")
    (description
     "Keep-presence moves the mouse, scrolls the wheel or presses a modifier
key at a configurable interval so the session never goes idle.  It stops
acting as soon as real user input is detected.")
    (license cc0)))
