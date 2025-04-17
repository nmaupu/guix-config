(define-module (nmaupu packages custom-linux)
  #:use-module (nongnu packages linux)
  #:use-module (guix build-system copy)
  #:use-module (guix git-download)
  #:use-module (guix download)
  #:use-module (guix licenses)
  #:use-module (guix packages))

(define-public custom-linux-firmware
  (package
    (inherit linux-firmware)
    (name "custom-linux-firmware")
    ; As of 2025-04-03, nonguix linux-firmware package doesn't have the BT drivers included
    ; so we are using a more recent commit to make BT work
    (version "d864697fd38a94092b636c8030843343f265fe69")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "026bdiwz05x4330w21wgza3bqsd4sr8b3jgnv4kqary9pzgnn0cm"))))))

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
