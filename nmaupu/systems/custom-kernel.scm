(define-module (nmaupu systems custom-kernel)
  #:use-module (nongnu packages linux)
  #:use-module (gnu packages linux))

;; (define (linux-url version)
;;   "Return a download URL for Linux VERSION."
;;   (string-append "https://cdn.kernel.org/pub/linux/kernel/"
;;                  "v" (string-take version 1) ".x/"
;;                  "linux-" version ".tar.xz"))

;; (define-public custom-linux-6.14
;;   (package
;;     (inherit linux-libre)
;;     (name "linux")
;;     (version "6.14")
;;     (source (origin
;;               (method url-fetch)
;;               (uri (linux-url version))
;;               (sha256
;;                (base32
;;                 "0w3nqh02vl8f2wsx3fmsvw1pdsnjs5zfqcmv2w2vnqdiwy1vd552"))))))

(define-public custom-linux-6.14
  (corrupt-linux linux-libre-6.14))
