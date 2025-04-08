(define-module (nmaupu packages goenv)
  #:use-module (guix build-system copy)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix git-download))

(define-public goenv
  (package
    (name "goenv")
    (version "2.2.22")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/go-nv/goenv.git")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0i18aqngmbhpvmwg0951qmkpy6k28lr64z7wwib3r1b7jkpdzlvh"))))
    (build-system copy-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'patch-paths
           (lambda _
             (substitute*
                 '("libexec/goenv-version-name"
                   "libexec/goenv-which")
               (("/bin/ls") (which "ls"))))))))
    (home-page "https://github.com/go-nv/goenv.git")
    (synopsis "goenv aims to be as simple as possible and follow the already established successful version management model of pyenv and rbenv.")
    (description "goenv aims to be as simple as possible and follow the already established successful version management model of pyenv and rbenv.")
    (license expat)))
