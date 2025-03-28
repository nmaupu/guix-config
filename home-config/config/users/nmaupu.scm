(define-module (config users nmaupu)
 #:use-module (gnu home)
 #:use-module (gnu packages) ;specification->package procedure
 #:use-module (config home-services shells)
 #:use-module (config home-services base)
 #:use-module (config home-services tmux)
 #:use-module (config home-services wm))

;; gnu/packages/specification->package gets a Package object from a string
;; Each module provides a list of packages as strings
;; so we need to get the actual Package object to be able to install them effectively
(define-public pkgs
  (map specification->package
       (append base-packages
               shells-packages
               wm-base-packages
               wm-xmonad-packages
               tmux-packages)))

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
