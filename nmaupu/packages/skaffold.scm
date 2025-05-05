(define-module (nmaupu packages skaffold)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (ice-9 optargs))

(define*-public (make-skaffold #:optional
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
      (name "skaffold")
      (version version)
      (source
       (origin
         (method url-fetch)
         (uri (string-append "https://github.com/GoogleContainerTools/skaffold/releases/download"
                             "/v" version "/skaffold-linux-" arch))
         (sha256 hash)))
      (build-system copy-build-system)
      (arguments
       `(#:install-plan '((,(string-append "skaffold-linux-" arch) "bin/skaffold"))
         #:phases (modify-phases %standard-phases
                    (add-after 'install 'make-executable
                      (lambda* (#:key outputs #:allow-other-keys)
                        (let* ((out (assoc-ref outputs "out"))
                               (bin (string-append out "/bin/skaffold")))
                          (chmod bin #o555)
                          #t))))))
      (home-page "https://skaffold.dev")
      (synopsis "Skaffold is a command line tool that facilitates continuous development for Kubernetes applications.")
      (description "Skaffold is a command line tool that facilitates continuous development for Kubernetes applications.")
      (license license:asl2.0))))

(define-public skaffold-2.15
  (package
    (inherit (make-skaffold #:version "2.15.0"
                            #:amd64-hash (base32 "1if80lhd20w37as1igw3nk65a265a0fizw4wfd3yydwlm2y4b788")
                            #:arm64-hash (base32 "00xgk1kh0x6nz22fwy7544nqb3skj07yx55arw8q43vb73qbw3gm")))
    (name "skaffold-2.15")))

(define-public skaffold
  (package
    (inherit skaffold-2.15)
    (name "skaffold")))
