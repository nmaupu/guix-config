(define-module (nmaupu packages k8s)
  #:use-module (guix download)
  #:use-module (guix packages)
  #:use-module (nongnu packages k8s))

(define-public helm-kubernetes-3.17.2
  (package
    (inherit helm-kubernetes)
    (version "3.17.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://get.helm.sh/helm-v" version "-linux-amd64.tar.gz"))
       (sha256
        (base32
         "0hbj4wpsp6ypvd890n9zyzyfncb5hazrxqr802sv0pzbl698ghlh"))))))

(define-public kind-0.27.0
  (package
    (inherit kind)
    (version "0.27.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://kind.sigs.k8s.io/dl/v" version "/kind-linux-amd64"))
       (sha256
        (base32
         "0jx094zw27388qp7m6y7yi0dd3yhamkilsvq0yng1b2qlfp5m1x6"))))))

(define-public k9s-0.40.10
  (package
    (inherit k9s)
    (version "0.40.10")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/derailed/k9s/releases/download/v"
             version "/k9s_Linux_amd64.tar.gz"))
       (sha256
        (base32
         "0m0axrxgkzjlyjb241l3kzx49jbdg2bdiqcn2c5rrr8ljg5vy2s9"))))))

(define-public kubectl-1.32.3
  (package
    (inherit kubectl)
    (version "1.32.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://dl.k8s.io/release/v" version "/bin/linux/amd64/kubectl"))
       (sha256
        (base32
         "17ypn8bmijdk0k9ldpq7zjr5nsk199h8ara8l2319dila469s85b"))))))
