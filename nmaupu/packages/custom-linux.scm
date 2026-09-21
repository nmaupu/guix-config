(define-module (nmaupu packages custom-linux)
  #:use-module (gnu packages disk)
  #:use-module (nongnu packages linux)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils))

;; Updated linux-firmware for better support (try to fix suspend issue on 6.14 kernel with driver 'xe')
(define-public custom-linux-firmware
  (package
    (inherit linux-firmware)
    (name "custom-linux-firmware")
    (version "20250509")
    (source (origin
              (method url-fetch)
              (uri (string-append "mirror://kernel.org/linux/kernel/firmware/"
                                  "linux-firmware-" version ".tar.xz"))
              (sha256
               (base32
                "0gkhpl60iw83pa8pq4hf8rrrc8nk8kjychsnrcq838i6y9k0vipj"))))))

;; ndctl: disable libtracefs to fix ABI mismatch with libtraceevent-1.7.3.
;; Use rewrite-ndctl in base.scm to propagate this fix transitively.
(define-public custom-ndctl
  (package
    (inherit ndctl)
    (name "custom-ndctl")
    (arguments
     (substitute-keyword-arguments (package-arguments ndctl)
       ((#:configure-flags flags)
        #~(append #$flags (list "-Dlibtracefs=disabled")))))
    (inputs (modify-inputs (package-inputs ndctl)
                           (delete "libtraceevent")
                           (delete "libtracefs")))))
