(define-module (nmaupu home-services base)
  #:use-module (gnu)
  #:use-module (gnu packages) ; defines specification->package
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (nongnu packages mozilla)
  #:use-module (nongnu packages compression)
  #:use-module (nmaupu packages fonts)
  #:use-module (nmaupu packages 1password)
  #:use-module (nmaupu packages keyboard-layout))

(use-package-modules curl version-control admin linux rsync
                     web commencement databases algebra
                     compression vim python web-browsers
                     rust-apps chromium admin ftp xorg
                     node cmake virtualization)

(define (home-base-profile-service config)
  (list 1password-gui
        bc
        curl
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
        python
        qemu
        virt-manager
        qutebrowser
        ripgrep
        fd
        rsync
        recutils
        strace
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
   (service home-base-service-type)
   (service home-dotfiles-service-type
            (home-dotfiles-configuration
             (directories '("../files/firefox-no-libva"
                            "../files/nvim"))))))
