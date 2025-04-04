(define-module (nmaupu packages polybar-themes)
  #:use-module (guix build-system trivial)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix git-download))

(define-public polybar-themes
  (package
    (name "polybar-themes")
    (version "def08ccb9870ffbd26072852ad137227603f99ba")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://github.com/nmaupu/polybar-themes.git")
              (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "00qlbiwpc5wim2inpnryjjg9aivc4ycz4aa1r39h5rmmg4jiwzf3"))))
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
