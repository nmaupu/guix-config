(define-module (packages antigen)
  #:use-module (guix build-system trivial)
  #:use-module (guix download)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:export (antigen))

(define antigen
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
                          (zsh-dir (string-append out "/share/zsh/site-functions"))
                          (dest (string-append zsh-dir "/antigen.zsh")))
                     (mkdir-p zsh-dir)
                     (copy-file source dest)))))
    (home-page "https://github.com/zsh-users/antigen")
    (synopsis "A plugin manager for Zsh, inspired by oh-my-zsh")
    (description "Antigen is a plugin manager for Zsh, inspired by oh-my-zsh.")
    (license expat)))
