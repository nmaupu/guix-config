(define-module (nmaupu packages postman)
  #:use-module (nonguix build-system chromium-binary)
  #:use-module (guix build-system copy)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module ((nonguix licenses) #:prefix licensenon:)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages cups)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages wget)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages elf))

(define-public postman
  (package
    (name "postman")
    (version "11.60.4")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://dl.pstmn.io/download/version/"
                           version
                           "/linux_64"))
       (file-name (string-append "postman-" version ".tgz"))
       (sha256
        (base32 "101fjnkn7djjal0b5za5qdmq9g08imfndx7qr11v1jh0z7amnz42"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:modules '((guix build copy-build-system)
                  (guix build utils)
                  (ice-9 ftw)
                  (srfi srfi-1))
      #:phases
      #~(modify-phases %standard-phases
          (replace 'install
            (lambda* (#:key outputs #:allow-other-keys)
              (use-modules (guix build utils) (ice-9 ftw) (srfi srfi-1))
              (let* ((out     (assoc-ref outputs "out"))
                     (appdir  (string-append out "/opt/postman"))
                     (bindir  (string-append out "/bin"))
                     (entries (scandir "." (lambda (f)
                                             (not (member f '("." "..")))))))
                (mkdir-p appdir)
                (for-each
                 (lambda (f)
                   (copy-recursively f (string-append appdir "/" f)))
                 entries)
                (mkdir-p bindir)
                (with-output-to-file (string-append bindir "/postman")
                  (lambda ()
                    (format #t "#!~a~%exec -a postman \"~a\" \"$@\"~%"
                            (which "bash")
                            (string-append appdir "/Postman"))))
                (chmod (string-append bindir "/postman") #o555)
                #t)))
          (add-after 'install 'patch-elf
            (lambda _
              (use-modules (guix build utils))
              (let* ((out    #$output)
                     (appdir (string-append out "/opt/postman"))
                     (rpath  (string-join
                              (list appdir
                                    (string-append appdir "/app")
                                    (string-append #$nss "/lib/nss")
                                    (string-append #$glib "/lib")
                                    (string-append #$dbus "/lib")
                                    (string-append #$at-spi2-core "/lib")
                                    (string-append #$cups "/lib")
                                    (string-append #$libdrm "/lib")
                                    (string-append #$gtk+ "/lib")
                                    (string-append #$pango "/lib")
                                    (string-append #$cairo "/lib")
                                    (string-append #$libx11 "/lib")
                                    (string-append #$libxcomposite "/lib")
                                    (string-append #$libxdamage "/lib")
                                    (string-append #$libxext "/lib")
                                    (string-append #$libxfixes "/lib")
                                    (string-append #$libxrandr "/lib")
                                    (string-append #$mesa "/lib")
                                    (string-append #$expat "/lib")
                                    (string-append #$libxcb "/lib")
                                    (string-append #$libxkbcommon "/lib")
                                    (string-append #$eudev "/lib")
                                    (string-append #$alsa-lib "/lib")
                                    (string-append #$gcc-toolchain "/lib")
                                    (string-append #$libsecret "/lib")
                                    (string-append #$nspr "/lib"))
                              ":"))
                     ;; Get all files, then keep only ELFs.
                     (elfs   (filter elf-file? (find-files appdir ".*"))))
                (for-each
                 (lambda (f)
                   (false-if-exception
                    (invoke #$(file-append patchelf "/bin/patchelf")
                            "--set-rpath" rpath f)))
                 elfs)
                #t)))
          (add-after 'patch-elf 'wrap-ld-library-path
            (lambda _
              (use-modules (guix build utils))
              (let* ((out    #$output)
                     (bindir (string-append out "/bin")))
                (wrap-program (string-append bindir "/postman")
                  `("LD_LIBRARY_PATH" ":" prefix
                    ,(list (string-append #$nss "/lib/nss"))))
                #t))))))

    (inputs
     (list nss glib nspr dbus at-spi2-core cups libdrm
           gtk+ pango cairo libx11 libxcomposite libxdamage libxext
           libxfixes libxrandr mesa expat libxcb libxkbcommon eudev alsa-lib
           gcc-toolchain libsecret))
    (native-inputs
     (list patchelf))
    (propagated-inputs
     (list xdg-utils))
    (home-page "https://www.postman.com")
    (synopsis "Postman")
    (description "Postman")
    (license (licensenon:nonfree "https://www.postman.com/pricing/"))))
