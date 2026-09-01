(define-module (nmaupu packages delve)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (gnu packages debug))

(define-public custom-delve
  (package
    (inherit delve)
    (name "delve")
    (version "1.27.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/go-delve/delve")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "176vrc4xm6xbri5pqdm0yra32dfg4nklvpbwfcl0ijxapjf51p8z"))))))
