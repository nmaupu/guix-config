(define-module (nmaupu home-services wm)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services desktop)
  #:use-module (gnu home services dotfiles)
  #:use-module (gnu home services shepherd)
  #:use-module (guix gexp)
  #:use-module (nmaupu packages custom-linux)
  #:use-module (nmaupu packages fonts)
  #:use-module (nmaupu packages polybar-themes)
  #:use-module (nmaupu packages custom-telegram))

(use-package-modules linux xdisorg xorg haskell haskell-apps networking compton
                     suckless wm image terminals gnupg xorg haskell-xyz telegram)

(define (home-wm-base-profile-service config)
  (list acpi
        arandr
        blueman
        telegram-desktop
        picom
        ;; xidlehook ;; custom package to replace xautolock or xss-lock
        xsecurelock
        xclip
        xmodmap
        xrandr
        xrdb
        setxkbmap))

(define (home-xmonad-profile-service config)
  (append (list custom-alsa-utils
                brightnessctl
                greenclip
                dmenu
                dunst
                flameshot
                fzf
                xmessage ; useful when recompiling xmonad in case of errors
                ghc
                ghc-xmonad-contrib
                ghc-raw-strings-qq
                ghc-regex-base
                ghc-regex-tdfa
                libxft
                polybar
                rofi
                xmonad)
          fonts-all))

(define home-base-service-type
  (service-type (name 'base)
                (description "Packages and configuration related to base window manager.")
                (extensions
                 (list (service-extension
                        home-profile-service-type
                        home-wm-base-profile-service)
                       (service-extension
                        home-profile-service-type
                        home-dbus-service-type)))
                (default-value #f)))

(define home-xmonad-service-type
  (service-type (name 'xmonad)
                (description "Packages and configuration related to xmonad wm.")
                (extensions
                 (list (service-extension
                        home-profile-service-type
                        home-xmonad-profile-service)))
                (default-value #f)))

(define-public home-xmonad-services
  (list
   (service home-base-service-type)
   (service home-xmonad-service-type)
   (service home-dotfiles-service-type
            (home-dotfiles-configuration
             (directories '("../files/xsession"
                            "../files/xmonad"
                            "../files/dunst"
                            "../files/picom"
                            "../files/flameshot"))))
   (simple-service 'polybar-themes
                   home-files-service-type
                   `((".config/polybar"
                      ,(directory-union "polybar-themes"
                                        (list polybar-themes)))))))
