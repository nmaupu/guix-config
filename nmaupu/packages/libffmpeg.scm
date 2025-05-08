(define-module (nmaupu packages libffmpeg)
  #:use-module (gnu packages compression)
  #:use-module (guix download)
  #:use-module (guix packages)
  #:use-module (nonguix build-system binary)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages commencement))

(define-public prebuilt-libffmpeg
  (package
    (name "prebuilt-libffmpeg")
    (version "0.98.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/nwjs-ffmpeg-prebuilt"
                           "/nwjs-ffmpeg-prebuilt/releases/download/"
                           version "/" version "-linux-x64.zip"))
       (sha256
        (base32 "1nqdpnpbvp5fzyqlj6dwfgf2hprmhkd499pjn4npl75rs8lmj9cg"))))
    (build-system binary-build-system)
    (arguments
     `(#:phases (modify-phases %standard-phases
                  (add-before 'patchelf 'patchelf-writable
                    (lambda _
                      (make-file-writable "libffmpeg.so"))))
       #:patchelf-plan `(("libffmpeg.so" ("glibc" "gcc-toolchain")))
       #:install-plan `(("libffmpeg.so", "lib/"))))
    (inputs (list glibc
                  gcc-toolchain))
    (native-inputs (list unzip))
    (supported-systems '("x86_64-linux"))
    (home-page "https://github.com/nwjs-ffmpeg-prebuilt/nwjs-ffmpeg-prebuilt")
    (synopsis "FFmpeg prebuilt for NW.js")
    (description "FFmpeg prebuilt binaries with proprietary codecs and build instructions for Window, Linux and macOS.")
    (license license:gpl2)))
