(define-module (nmaupu packages polybar-themes)
  #:use-module (guix build-system trivial)
  #:use-module ((guix licenses) #:prefix licenses:)
  #:use-module (guix packages)
  #:use-module (guix git-download))

(define-public polybar-themes
  (package
    (name "polybar-themes")
    (version "754213e80104c6e68b0b15599c9f278dc4597322")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://github.com/nmaupu/polybar-themes.git")
              (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0l2r28fmcjn0xn6v327w0g9dpa478bgn8fq8z0l60xgnyjvhws1v"))))
    (build-system trivial-build-system)
    (arguments
     `(#:modules ((guix build utils))
       #:builder (begin
                   (use-modules (guix build utils))
                   (let* ((out (assoc-ref %outputs "out"))
                          (source (assoc-ref %build-inputs "source")))
                     (mkdir-p out)
                     (copy-recursively (string-append source "/simple") out)))))
    (home-page "https://github.com/nmaupu/polybar-themes.git")
    (synopsis "A huge collection of polybar themes with different styles, colors and variants.")
    (description "A huge collection of polybar themes with different styles, colors and variants.")
    (license licenses:gpl3)))
