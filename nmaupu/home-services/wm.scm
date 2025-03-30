(define-module (nmaupu home-services wm)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (gnu home services shepherd)
  #:use-module (guix gexp))

(use-package-modules linux xdisorg pulseaudio xorg haskell haskell-apps
                     suckless wm image terminals gnupg xorg)

(define (home-wm-base-profile-service config)
  (list acpi
        arandr
        pavucontrol
        xrandr
        xclip
        xmodmap))

(define (home-xmonad-profile-service config)
  (list greenclip
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
        xmonad))

(define home-base-service-type
  (service-type (name 'base)
                (description "Packages and configuration related to base wm.")
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
   (service home-shepherd-service-type
            (home-shepherd-configuration
             (auto-start? #t)
             (services
              (list
               (shepherd-service
                (documentation "Run the Greenclip daemon.")
                (provision '(greenclip))
                (start #~(make-forkexec-constructor
                          (list #$(file-append greenclip "/bin/greenclip") "daemon")))
                (stop #~(make-kill-destructor)))))))))
