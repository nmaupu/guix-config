(define-module (config home-services wm)
  #:use-module (gnu packages)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu packages haskell-apps) ; greenclip package obj
  #:use-module (guix gexp))

(define-public wm-base-packages
  (map specification->package
       '("acpi"
         "arandr"
         "pavucontrol"
         "xrandr"
         "xclip")))

(define-public xmonad-packages
  (map specification->package
       ;; xmonad, ghc and ghc-xmonad-contrib packages are installed system-wid
       ;; because xmonad can't compile its configuration's file otherwise.
       '("greenclip"
         "conky"
         "dmenu"
         "dunst"
         "dzen"
         "flameshot"
         "greenclip"
         "rofi"
         "stalonetray")))

(define-public xmonad-service
  (append
   (list
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
                 (stop #~(make-kill-destructor))))))))))
