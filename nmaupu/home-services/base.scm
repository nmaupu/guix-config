(define-module (nmaupu home-services base)
  #:use-module (gnu)
  #:use-module (gnu packages) ; defines specification->package
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (guix build-system trivial)
  #:use-module (guix download)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (nongnu packages mozilla)
  #:use-module (nongnu packages compression)
  #:use-module (nmaupu packages fonts))

(use-package-modules curl version-control admin linux web rsync commencement databases
                     compression vim python web-browsers rust-apps chromium admin ftp xorg)

(define (home-base-profile-service config)
  (list curl
        lm-sensors
        firefox
        git
        gcc-toolchain
        htop
        jq
        lftp
        (specification->package "make")
        neovim
        p7zip
        python
        qutebrowser
        ripgrep
        fd
        rsync
        recutils
        tig
        tree
        ungoogled-chromium
        unrar
        unzip
        xkbcomp
        yq
        font-nerd-commitmono))

; qwertyfr keyboard layout
(define qwerty-fr
  (package
    (name "qwerty-fr")
    (version "0.7.3")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/qwerty-fr/qwerty-fr/releases/download/v"
                                  version "/qwerty-fr_" version "_linux.zip"))
              (sha256
               (base32
                "0csxzs2gk8l4y5ii1pgad8zxr9m9mfrl9nblywymg01qw74gpvnm"))))
    (build-system trivial-build-system)
    (native-inputs `(("source" ,source)
                     ("unzip" ,unzip)))
    (arguments
     `(#:modules ((guix build utils)
                  (srfi srfi-26))
       #:builder (begin
                   (use-modules (guix build utils))
                   (let* ((PATH (string-append (assoc-ref %build-inputs "unzip")
                                               "/bin"))
                          (out (assoc-ref %outputs "out"))
                          (source (assoc-ref %build-inputs "source")))
                     (setenv "PATH" PATH)
                     (mkdir-p out)
                     (system* "unzip" "-d" out source)))))
    (home-page "https://github.com/qwerty-fr/qwerty-fr")
    (synopsis "Qwertyfr keyboard layout")
    (description "Keyboard layout based on the QWERTY layout with extra symbols and diacritics so that typing both in French and English is easy and fast. It is also easy to learn!")
    (license expat)))

;; Load this layout with the following command
;; xkbcomp -I~/.config/xkb ~/.config/xkb/qwertyfr.xkb $DISPLAY &>/dev/null
(define keyboard-layout-qwerty-fr-service
  (simple-service 'keyboard-layout-qwerty-fr-service
                  home-files-service-type
                  `((".config/xkb/symbols/qwerty-fr" ,(file-append qwerty-fr "/usr/share/X11/xkb/symbols/us_qwerty-fr"))
                    (".config/xkb/qwertyfr.xkb" ,(local-file "../files/xkb/qwertyfr.xkb")))))

(define home-base-service-type
  (service-type (name 'base)
                (description "Packages and configuration for base stuff")
                (extensions
                 (list (service-extension
                        home-profile-service-type
                        home-base-profile-service)))
                (default-value #f)))

(define-public home-base-services
  (list
   keyboard-layout-qwerty-fr-service
   (service home-base-service-type)))
