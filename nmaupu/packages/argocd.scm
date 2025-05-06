(define-module (nmaupu packages argocd)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (ice-9 optargs))

(define*-public (make-argocd #:optional
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
      (name "argocd")
      (version version)
      (source
       (origin
         (method url-fetch)
         (uri (string-append "https://github.com/argoproj/argo-cd/releases/download"
                             "/v" version "/argocd-linux-" arch))
         (sha256 hash)))
      (build-system copy-build-system)
      (arguments
       `(#:install-plan '((,(string-append "argocd-linux-" arch) "bin/argocd"))
         #:phases (modify-phases %standard-phases
                    (add-after 'install 'make-executable
                      (lambda* (#:key outputs #:allow-other-keys)
                        (let* ((out (assoc-ref outputs "out"))
                               (bin (string-append out "/bin/argocd")))
                          (chmod bin #o555)
                          #t))))))
      (home-page "https://argo-cd.readthedocs.io/en/stable")
      (synopsis "Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes.")
      (description "Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes.")
      (license license:asl2.0))))


(define-public argocd-2.14
  (package
    (inherit (make-argocd #:version "2.14.11"
                          #:amd64-hash (base32 "0lmjl5vf82kk25gcnvzfd2ppgcc1lia63hb8x3d38sxmzvzqqhvq")
                          #:arm64-hash (base32 "0d15fjshvkrcjf3vbrard9vyf67a7128qk436dfrnr6ah1i9g7r0")))))

(define-public argocd-3
  (package
    (inherit (make-argocd #:version "3.0.0"
                          #:amd64-hash (base32 "0wc1fnp3w3q8rin11ivmd5w1l5d6pi4g4az2majh1ls089rk8h7h")
                          #:arm64-hash (base32 "0bzbxkwskb30hwh9ada4c8gna7kbra7jg7n736b7saarybma8cdz")))))

(define-public argocd argocd-2.14)
