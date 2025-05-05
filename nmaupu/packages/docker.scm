(define-module (nmaupu packages docker)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (ice-9 optargs))

(define*-public (make-docker-compose #:optional
                                     (system (or (%current-target-system)
                                                 (%current-system)))
                                     #:key
                                     version
                                     amd64-hash)
  (let* ((arch+hash
          (cond
           ((target-x86-64? system)
            `("x86_64" . ,amd64-hash))
           (else
            (error "Unsupported system architecture" system))))
         (arch (car arch+hash))
         (hash (cdr arch+hash)))
    (package
      (name "docker-compose")
      (version version)
      (source
       (origin
         (method url-fetch)
         (uri (string-append "https://github.com/docker/compose/releases/download"
                             "/v" version "/docker-compose-linux-" arch))
         (sha256 hash)))
      (build-system copy-build-system)
      (arguments
       `(#:install-plan '((,(string-append "docker-compose-linux-" arch) "bin/docker-compose"))
         #:phases (modify-phases %standard-phases
                    (add-after 'install 'make-executable
                      (lambda* (#:key outputs #:allow-other-keys)
                        (let* ((out (assoc-ref outputs "out"))
                               (bin (string-append out "/bin/docker-compose")))
                          (chmod bin #o555)
                          #t))))))
      (home-page "https://docs.docker.com/compose")
      (synopsis "Docker Compose is a tool for running multi-container applications on Docker defined using the Compose file format. ")
      (description "Docker Compose is a tool for running multi-container applications on Docker defined using the Compose file format. ")
      (license license:asl2.0))))

(define-public docker-compose-2.35
  (package
    (inherit (make-docker-compose #:version "2.35.1"
                                  #:amd64-hash (base32 "0c62nhfi6ghpp5lyv3mbm6qwvzcnpy99h4jx9qsx0pbfj7i2rnvv")))
    (name "docker-compose-2.35")))

(define-public docker-compose
  (package
    (inherit docker-compose-2.35)
    (name "docker-compose")))
