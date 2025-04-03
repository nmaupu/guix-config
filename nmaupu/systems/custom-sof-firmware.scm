(define-module (nmaupu systems custom-sof-firmware)
  #:use-module (nongnu packages linux)
  #:use-module (guix build-system copy)
  #:use-module (guix download)
  #:use-module (guix licenses)
  #:use-module (guix packages))

(define-public custom-sof-firmware
  (package
   (inherit sof-firmware)
   (name "custom-sof-firmware")
   (version "2025.01.1")
   (source
    (origin
     (method url-fetch)
     (uri (string-append "https://github.com/thesofproject/sof-bin/releases/download/v"
                         version "/sof-bin-" version ".tar.gz"))
     (sha256
      (base32
       "08w3z183cva8bg2yynljrxl2j4nl3xyv5mkljq6ips25qbci0qm3"))))))
