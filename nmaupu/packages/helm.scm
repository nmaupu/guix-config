(define-module (nmaupu packages helm)
  #:use-module (guix build-system copy)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix download))

(define-public helm
  (package
    (name "helm")
    (version "3.17.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://get.helm.sh/helm-v" version "-linux-amd64.tar.gz"))
       (sha256
        (base32 "0hbj4wpsp6ypvd890n9zyzyfncb5hazrxqr802sv0pzbl698ghlh"))))
    (build-system copy-build-system)
    (arguments
     `(#:install-plan '(("helm" "bin/helm"))))
    (home-page "https://helm.sh")
    (synopsis "Helm is a tool for managing Charts. Charts are packages of pre-configured Kubernetes resources.")
    (description "Helm is a tool for managing Charts. Charts are packages of pre-configured Kubernetes resources.")
    (license asl2.0)))
