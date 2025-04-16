(define-module (nmaupu packages 1password)
  #:use-module (guix build-system copy)
  #:use-module (nonguix build-system binary)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (gnu packages compression)
  #:use-module (guix gexp)
  #:use-module ((nonguix licenses) #:prefix licensenon:)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (nongnu packages mozilla)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages base)
  #:use-module (gnu packages cups)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages polkit)
  #:use-module (gnu packages mate)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages nss))


;; This package requires some rights to be changed on "op" binary (as per the readme)
;; - A group onepassword-cli has to be created
;; - To be used, the user should be added to this group
;; - op binary has to be chown to root:onepassword-cli
;; - op binary has to be chmod g+s
;; Something along those lines:
;;
;; (simple-service 'onepassword-setgid-helper privileged-program-service-type
;;                 (list (privileged-program
;;                         (program  (file-append 1password-cli "/bin/op"))
;;                         (group "onepassword-cli")
;;                         (setgid? #t))))
(define-public 1password-cli
  (package
    (name "1password-cli")
    (version "2.30.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://cache.agilebits.com/dist/1P/op2/pkg/v"
                           version "/op_linux_amd64_v" version ".zip"))
       (sha256
        (base32 "0a7fsmbmwa2x5kg1cijggj4w1hw0qgqg8vvs3l4zsh6brvmhfqx1"))))
    (build-system copy-build-system)
    (native-inputs (list unzip))
    (arguments
     `(#:install-plan '(("op" "bin/op"))))
    (home-page "https://1password.com/downloads/command-line")
    (synopsis "1password-cli")
    (description "1password-cli")
    (license (licensenon:nonfree "https://1password.com/pricing"))))

;;
;; 1password-gui is a bit more tricky...
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

(define-public 1password-gui
  (package
    (name "1password-gui")
    (version "8.10.70")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://downloads.1password.com/linux/tar/stable"
                           "/x86_64/1password-" version ".x64.tar.gz"))
       (sha256
        (base32 "0cha85pzg4pnynafja1pcczka8kb3a7x14wyg3hyxipagqlrwqj0"))))
    (build-system binary-build-system)
    ;; Where things get hairy
    ;; Based on https://zie87.github.io/posts/guix-foreign-binaries
    (arguments
     `(#:strip-directories '()
       #:validate-runpath? #f
       #:phases (modify-phases %standard-phases
                  (add-before 'patchelf 'patchelf-writable
                    (lambda _
                      (for-each make-file-writable
                                '("1password"
                                  "1Password-BrowserSupport"
                                  "1Password-Crash-Handler"
                                  "1Password-LastPass-Exporter"))))
                  (add-after 'unpack 'delete-useless-files
                    (lambda _
                      (substitute* "com.1password.1Password.policy.tpl"
                        (("[$]{1}[{]{1}POLICY_OWNERS[}]{1}") "unix-group:onepassword"))
                      (copy-recursively "com.1password.1Password.policy.tpl" "com.1password.1Password.policy")
                      (for-each delete-file-recursively
                                '("after-install.sh"
                                  "after-remove.sh"
                                  "com.1password.1Password.policy.tpl")))))
                  ;; (add-after 'install 'symlink
                  ;;   (lambda* (#:key outputs #:allow-other-keys)
                  ;;     (let ((out (assoc-ref outputs "out")))
                  ;;       (mkdir-p (string-append out "/bin"))
                  ;;       (symlink (string-append out "/opt/1Password/1password")
                  ;;                (string-append out "/bin/1password")))
                  ;;     #t)))
       #:patchelf-plan `(("1password" ("alsa-lib"
                                       "at-spi2-core"
                                       "cairo"
                                       "cups"
                                       "dbus"
                                       "eudev"
                                       "expat"
                                       "gcc-toolchain"
                                       "glib"
                                       "glibc"
                                       "gtk+"
                                       "libx11"
                                       "libxcb"
                                       "libxcomposite"
                                       "libxdamage"
                                       "libxext"
                                       "libxfixes"
                                       "libxkbcommon"
                                       "libxrandr"
                                       "mesa"
                                       "nspr"
                                       "pango"
                                       "prebuilt-libffmpeg"
                                       ("nss" "/lib/nss")))
                         ("1Password-BrowserSupport" ("gcc-toolchain" "eudev"))
                         ("1Password-Crash-Handler" ("gcc-toolchain", "eudev"))
                         ("1Password-LastPass-Exporter" ("gcc-toolchain")))
       #:install-plan `(("./" "/bin/")
                        ("com.1password.1Password.policy" "/etc/polkit-1/actions/"))))
    (inputs (list alsa-lib
                  at-spi2-core
                  cairo
                  cups
                  dbus
                  eudev
                  expat
                  gcc-toolchain
                  glib
                  glibc
                  gtk+
                  libx11
                  libxcb
                  libxcomposite
                  libxdamage
                  libxext
                  libxfixes
                  libxkbcommon
                  libxrandr
                  mesa
                  nspr
                  nss
                  pango
                  prebuilt-libffmpeg))
    (propagated-inputs (list polkit
                             mate-polkit))
    (supported-systems '("x86_64-linux"))
    (home-page "https://support.1password.com/install-linux")
    (synopsis "1password GUI")
    (description "1password GUI")
    (license (licensenon:nonfree "https://1password.com/pricing"))))
