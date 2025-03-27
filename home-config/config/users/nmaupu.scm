(define-module (config users nmaupu)
 #:use-module (gnu home)
 #:use-module (config home-services shells)
 #:use-module (config home-services base)
 #:use-module (config home-services tmux)
 #:use-module (config home-services wm))

(define-public pkgs
  (append base-packages
          shells-packages
          wm-base-packages
          wm-xmonad-packages
          tmux-packages))

(define-public svcs
  (append zsh-service
          bash-service
          wm-xmonad-service
          tmux-service))

(define-public my-home
  (home-environment
   (packages pkgs)
   (services svcs)))

my-home
