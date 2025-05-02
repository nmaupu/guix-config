(define-module (nmaupu packages talosctl)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (ice-9 optargs))

(define*-public (make-talosctl #:optional
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
      (name "talosctl")
      (version version)
      (source
       (origin
         (method url-fetch)
         (uri (string-append "https://github.com/siderolabs/talos/releases/download/"
                             "v" version "/talosctl-linux-" arch))
         (sha256 hash)))
      (build-system copy-build-system)
      (arguments
       `(#:install-plan '((,(string-append "talosctl-linux-" arch) "bin/talosctl"))
         #:phases (modify-phases %standard-phases
                    (add-after 'install 'make-executable
                      (lambda* (#:key outputs #:allow-other-keys)
                        (let* ((out (assoc-ref outputs "out"))
                               (bin (string-append out "/bin/talosctl")))
                          (chmod bin #o555)
                          #t))))))
      (home-page "https://github.com/siderolabs/talos")
      (synopsis "Talos is a modern OS for running Kubernetes: secure, immutable, and minimal.")
      (description "Talos is a modern OS for running Kubernetes: secure, immutable, and minimal. Talos is fully open source, production-ready, and supported by the people at Sidero Labs All system management is done via an API - there is no shell or interactive console.")
      (license license:mpl2.0))))

(define-public talosctl-1.11.0-alpha0
  (package
    (inherit (make-talosctl #:version "1.11.0-alpha0"
                            #:amd64-hash (base32 "1aanr8s92law8dm1ih5bvv0vmvnr8bdba7jbvfywv25czmaz7jwf")
                            #:arm64-hash (base32 "1vp5lilq06sns450bqas60wffz53dagdrdqcaxbwr855m1g9zc2r")))
    (name "talosctl-1.11.0-alpha0")))

(define-public talosctl-1.10.0
  (package
    (inherit (make-talosctl #:version "1.10.0"
                            #:amd64-hash (base32 "0i2p896if50jwza5kxf22228h1rkag2bbvj95r4bcjyxgrfysa36")
                            #:arm64-hash (base32 "02jmcs3jp6h58zigw758v3v40g747zr3wkqxq5pzzdlvrbxrj4cj")))
    (name "talosctl-1.10.0")))

(define-public talosctl
  (package
    (inherit talosctl-1.10.0)
    (name "talosctl")))
