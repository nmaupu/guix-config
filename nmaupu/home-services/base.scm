(define-module (nmaupu home-services base)
  #:use-module (gnu)
  #:use-module (gnu packages) ; defines specification->package
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (nongnu packages mozilla)
  #:use-module (nongnu packages compression)
  #:use-module (nmaupu packages fonts)
  #:use-module (nmaupu packages keyboard-layout))

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
        nerd-font-commitmono))

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
