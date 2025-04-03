(define-module (nmaupu systems latest-linux-firmware)
  #:use-module (nongnu packages linux)
  #:use-module (guix build-system copy)
  #:use-module (guix download)
  #:use-module (guix licenses)
  #:use-module (guix packages))

(define-public latest-linux-firmware
  (package
    (inherit linux-firmware)
    (name "latest-linux-firmware")
    (version "d864697fd38a94092b636c8030843343f265fe69")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "file:///home/nmaupu/work/perso/"
             "linux-firmware/dist/"
             "linux-firmware-d864697fd38a94092b636c8030843343f265fe69.tar.xz"))
       (sha256
        (base32
         "09s18sr4frark3cbl5brn3746nps9ld6qd1as03cvk439fgm8cd9"))))))
