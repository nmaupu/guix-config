(define-module (config home-services wm)
  #:use-module (gnu packages)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (guix gexp)
  #:use-module (config home-services greenclip))

(define-public wm-base-packages
  (list
   "acpi"
   "arandr"
   "pavucontrol"
   "xrandr"
   "xclip"))

(define-public xmonad-packages
  (append
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
   "stalonetray")
   greenclip-packages))

(define-public xmonad-service
  (append
   (list
    (service home-dotfiles-service-type
             (home-dotfiles-configuration
              (directories '("../files/xmonad")))))
   greenclip-service))
