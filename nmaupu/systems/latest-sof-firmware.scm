(define-module (nmaupu systems latest-sof-firmware)
  #:use-module (nongnu packages linux)
  #:use-module (guix build-system copy)
  #:use-module (guix download)
  #:use-module (guix licenses)
  #:use-module (guix packages))

(define-public latest-sof-firmware
  (package
   (name "custom-sof-firmware")
   (version "2025.01.1")
   (source
    (origin
     (method url-fetch)
     (uri (string-append "https://github.com/thesofproject/sof-bin/releases/download/v"
                         version "/sof-bin-" version ".tar.gz"))
     (sha256
      (base32
       "08w3z183cva8bg2yynljrxl2j4nl3xyv5mkljq6ips25qbci0qm3"))))
   (build-system copy-build-system)
    (arguments
     `(#:install-plan
       '(("sof"           "lib/firmware/intel/sof")
         ("sof-ace-tplg"  "lib/firmware/intel/sof-ace-tplg")
         ("sof-ipc4"      "lib/firmware/intel/sof-ipc4")
         ("sof-ipc4-tplg" "lib/firmware/intel/sof-ipc4-tplg")
         ("sof-tplg"      "lib/firmware/intel/sof-tplg"))))
    (home-page "https://www.sofproject.org")
    (synopsis "Sound Open Firmware")
    (description "This package contains Linux firmwares and topology files for
audio DSPs that can be found on the Intel Skylake architecture.  This
firmware can be built from source but need to be signed by Intel in order to be
loaded by Linux.")
    (license bsd-3)))
