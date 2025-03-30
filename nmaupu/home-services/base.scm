(define-module (nmaupu home-services base)
  #:use-module (gnu)
  #:use-module (gnu packages) ; defines specification->package
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (nongnu packages mozilla)
  #:use-module (nongnu packages compression)
  #:use-module (nmaupu packages qwerty-fr))

(use-package-modules curl version-control admin linux web rsync commencement
                     compression vim python web-browsers rust-apps chromium admin)

(define (home-base-profile-service config)
  (list curl
        lm-sensors
        firefox
        git
        gcc-toolchain
        htop
        jq
        (specification->package "make")
        neovim
        p7zip
        python
        qutebrowser
        ripgrep
        fd
        rsync
        tig
        tree
        ungoogled-chromium
        unrar
        unzip
        yq))

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
   (service home-base-service-type)
   (simple-service 'qwerty-fr-keyboard
                   home-files-service-type
                   `((".config/xkb/symbols/qwerty-fr" ,(file-append qwerty-fr "/usr/share/X11/xkb/symbols/us_qwerty-fr"))))))
