(define-module (config packages antigen)
  #:use-module (guix build-system trivial)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix download))

(define-public antigen
  (package
    (name "antigen")
    (version "2.2.3")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://raw.githubusercontent.com/zsh-users/antigen/"
                                  version "/bin/antigen.zsh"))
              (sha256
               (base32 "1bmp3qf14509swpxin4j9f98n05pdilzapjm0jdzbv0dy3hn20ix"))))
    (build-system trivial-build-system)
    (arguments
     `(#:modules ((guix build utils))
       #:builder (begin
                   (use-modules (guix build utils))
                   (let* ((out (assoc-ref %outputs "out"))
                          (source (assoc-ref %build-inputs "source"))
                          (dest (string-append out "/antigen.zsh")))
                     (mkdir-p out)
                     (copy-file source dest)))))
    (home-page "https://github.com/zsh-users/antigen")
    (synopsis "A plugin manager for Zsh, inspired by oh-my-zsh")
    (description "Antigen is a plugin manager for Zsh, inspired by oh-my-zsh.")
    (license expat)))
