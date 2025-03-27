(define-module (config users nmaupu)
 #:use-module (gnu home)
 #:use-module (gnu packages)
 #:use-module (gnu services)
 #:use-module (guix packages)
 #:use-module (guix gexp)
 #:use-module (config home-services shells)
 #:use-module (config home-services base)
 #:use-module (config home-services tmux)
 #:use-module (config home-services wm)
 #:use-module (config packages antigen)
 #:use-module (config packages tmux-tpm))

(define my-home
  (home-environment
   (packages
    (cons*
      antigen
      tmux-tpm
      (map specification->packages
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
