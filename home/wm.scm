(define-module (home wm)
  #:use-module (gnu packages)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (guix gexp))

(define-public wm-packages
  (list
   "acpi"
   "arandr"
   "conky"
   "dmenu"
   "dunst"
   "dzen"
   "flameshot"
   "greenclip"
   "pavucontrol"
   "rofi"
   "stalonetray"
   "xrandr"))

(define-public xmonad-packages
  (list
   "xmonad"
   "ghc-xmonad-contrib"))

(define-public xmonad-service
  (list
   (service home-dotfiles-service-type
            (home-dotfiles-configuration
             (directories '("../files/xmonad"))))))
