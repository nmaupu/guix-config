(define-module (nmaupu packages git-secret)
  #:use-module (guix packages)
  #:use-module (guix build-system gnu)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:))

(define-public git-secret
  (let ((commit "7ef38389ba93f33751279d8f6123e662009bd0be")
        (revision "0"))
    (package
      (name "git-secret")
      (version (git-version "0.5.1" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/sobolevn/git-secret.git")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32
           "0xa56vj9kcv87r6hn7b217jr45s1v0qzpgg3pzl5svd1jpazzcam"))))
      (build-system gnu-build-system)
      (arguments
       (list
        #:tests? #f
        #:phases
        #~(modify-phases %standard-phases
            (delete 'configure)
            (add-before 'install 'set-prefix
              (lambda* (#:key outputs #:allow-other-keys)
                (let* ((out (assoc-ref outputs "out")))
                  (mkdir-p out)
                  (setenv "PREFIX" out)
                  #t))))))
      (home-page "https://github.com/sobolevn/git-secret.git")
      (synopsis "git-secret is a bash tool which stores private data inside a git repo.")
      (description
       "git-secret is a bash tool which stores private data inside a git repo. git-secret encrypts files with permitted users' public keys, allowing users you trust to access encrypted data using pgp and their secret keys.")
      (license license:expat))))
