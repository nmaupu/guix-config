(define-module (config home-services wm)
  #:use-module (gnu packages)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (guix gexp))

(define-public wm-base-packages
  (list
   "acpi"
   "arandr"
   "pavucontrol"
   "xrandr"))

(define-public xmonad-packages
  (list
   ;; Installed system-wide because otherwise xmonad
   ;; can't compile its configuration's file
   ;; "xmonad"
   ;; "ghc"
   ;; "ghc-xmonad-contrib"
   "conky"
   "dmenu"
   "dunst"
   "dzen"
   "flameshot"
   "greenclip"
   "rofi"
   "stalonetray"))

(define-public xmonad-service
  (list
   (service home-dotfiles-service-type
            (home-dotfiles-configuration
             (directories '("../files/xmonad"))))))
