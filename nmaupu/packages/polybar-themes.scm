(define-module (nmaupu packages polybar-themes)
  #:use-module (guix build-system trivial)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix git-download))

(define-public polybar-themes
  (package
    (name "polybar-themes")
    (version "b8bd8c5fb3a70df7fabbb3500d8021f784743e01")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://github.com/nmaupu/polybar-themes.git")
              (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "05q6yc553zpigi68xjv5hjly3b8a499n443j5l24nphkzjvjp3qq"))))
    (build-system trivial-build-system)
    (arguments
     `(#:modules ((guix build utils))
       #:builder (begin
                   (use-modules (guix build utils))
                   (let* ((out (assoc-ref %outputs "out"))
                          (source (assoc-ref %build-inputs "source")))
                     (mkdir-p out)
                     (copy-recursively (string-append source "/simple") out)))))
    (home-page "")
    (synopsis "")
    (description "")
    (license expat)))
