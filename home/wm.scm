(define-module (home wm)
  #:use-module (gnu packages)
  #:use-module (gnu services)
  #:use-module (gnu home services) ; home-files-service-type
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
   "ghc-xmonad-contrib"
   "greenclip"
   "pavucontrol"
   "rofi"
   "stalonetray"
   "xmonad"
   "xrandr"))

(define-public xmonad-service
  (list
   (simple-service 'xmonad-config
                   home-files-service-type
                   '((".config/xmonad/xmonad.hs", (local-file "../files/xmonad/xmonad.hs"))))
   (simple-service 'xmonad-icons
                   home-activation-service-type
                   #~(begin
                       (use-module (ice9 ftw))
                       (define src #$(local-file "../files/xmonad/icons" #:recursive? #t))
                       (define dst (string-append (getenv "HOME") "/.config/xmonad/icons"))
                       (mkdir-p dst)
                       (copy-recursively src dst)))))
