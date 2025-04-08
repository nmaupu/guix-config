(define-module (nmaupu home-services wm)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (gnu home services shepherd)
  #:use-module (guix gexp)
  #:use-module (nmaupu packages fonts)
  #:use-module (nmaupu packages polybar-themes))

(use-package-modules linux xdisorg pulseaudio xorg haskell haskell-apps
                     suckless wm image terminals gnupg xorg telegram)

(define (home-wm-base-profile-service config)
  (list acpi
        arandr
        pavucontrol
        telegram-desktop
        xrandr
        xclip
        xmodmap
        xrdb
        setxkbmap))

(define (home-xmonad-profile-service config)
  (append (list greenclip
                dmenu
                dunst
                flameshot
                fzf
                ghc
                ghc-xmonad-contrib
                libxft
                pinentry-rofi
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
                        home-wm-base-profile-service)))
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
             (directories '("../files/xmonad"))))
   (simple-service 'polybar-themes
                   home-files-service-type
                   `((".config/polybar"
                      ,(directory-union "polybar-themes"
                                        (list polybar-themes)))))))
