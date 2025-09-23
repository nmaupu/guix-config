(define-module (nmaupu home-services base)
  #:use-module (gnu)
  #:use-module (gnu packages) ; defines specification->package
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (nongnu packages mozilla)
  #:use-module (nongnu packages compression)
  #:use-module (nongnu packages chrome)
  #:use-module (nmaupu packages fonts)
  #:use-module (nmaupu packages slack)
  #:use-module (nmaupu packages keyboard-layout))

(use-package-modules curl version-control admin linux rsync vpn
                     web commencement databases algebra bash gnome
                     compression vim python python-build python-web python-xyz web-browsers
                     rust-apps chromium admin ftp xorg fonts fontutils
                     node cmake virtualization dns xdisorg perl textutils)

(define (home-base-profile-service config)
  (list
        bash-completion ;; provides compgen
        bc
        ;; bind is the name of guile procedure, so bind package has been renamed to isc-bind
        isc-bind
        curl
        evince
        lm-sensors
        firefox
        git
        gcc-toolchain
        htop
        jq
        lftp
        cmake
        (specification->package "make")
        neovim
        node ; provides npm needed for some packages installation (lsp, etc.)
        p7zip
        perl ; sometimes useful
        python
        python-pip
        python-requests
        qemu
        virt-manager
        openvpn
        qutebrowser
        ripgrep
        fd
        rsync
        recutils
        slack
        strace
        tig
        tree
        ungoogled-chromium
        google-chrome-stable
        unrar
        unzip
        xkbcomp
        yq
        fontconfig
        nerd-font-commitmono
        font-adobe-source-han-serif
        font-google-noto-emoji
        glibc-utf8-locales))

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
   (service home-base-service-type)
   (service home-dotfiles-service-type
            (home-dotfiles-configuration
             (directories '("../files/firefox-no-libva"
                            "../files/nvim"))))))
