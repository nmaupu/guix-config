(define-module (nmaupu packages polybar-themes)
  #:use-module (guix build-system trivial)
  #:use-module ((guix licenses) #:prefix licenses:)
  #:use-module (guix packages)
  #:use-module (guix git-download))

(define-public polybar-themes
  (package
    (name "polybar-themes")
    (version "bcc9957b569841c05c950d41d49e07e2edc17e47")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://github.com/nmaupu/polybar-themes.git")
              (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "10kb35rjfadjgimrly9gnmfxylmqinj34v39hcc4qcd6ya0q1hwv"))))
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
