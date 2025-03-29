(define-module (nmaupu home-services wm)
  #:use-module (gnu services)
  #:use-module (gnu home services dotfiles)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu packages haskell-apps) ; greenclip package obj
  #:use-module (guix gexp))

(define-public wm-base-packages
  (list "acpi"
        "arandr"
        "pavucontrol"
        "xrandr"
        "xclip"
        "xmodmap"))

(define-public wm-xmonad-packages
  ;; xmonad, ghc and ghc-xmonad-contrib packages are installed system-wid
  ;; because xmonad can't compile its configuration's file otherwise.
  (list "greenclip"
        "dmenu"
        "dunst"
        "flameshot"
        "fzf"
        "greenclip"
        "pinentry-rofi"
        "polybar"
        "rofi"))

(define-public wm-xmonad-service
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
