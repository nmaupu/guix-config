(define-module (nmaupu packages delve)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (gnu packages debug))

(define-public custom-delve
  (package
    (inherit delve)
    (name "delve")
    (version "1.24.2")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/go-delve/delve")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "13lk8m7nkhmdm6qgnbniwkw0ffyv91x9z763c8qwy5v4kb6v6mq4"))))))
