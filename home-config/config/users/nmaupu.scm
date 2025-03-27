(define-module (config users nmaupu)
 #:use-module (gnu home)
 #:use-module (gnu packages)
 #:use-module (gnu services)
 #:use-module (guix packages)
 #:use-module (guix gexp)
 #:use-module (config home-services shells)
 #:use-module (config home-services base)
 #:use-module (config home-services tmux)
 #:use-module (config home-services wm))

(define my-home
  (home-environment
    (packages (specifications->packages
                (append
                  base-packages
                  shells-packages
                  wm-base-packages
                  xmonad-packages
                  tmux-packages)))
    (services (append
               zsh-service
               bash-service
               xmonad-service
               tmux-service))))

my-home
