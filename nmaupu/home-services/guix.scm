(define-module (nmaupu home-services guix)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (guix gexp))

(define-public home-guix-services
  (list
   (service home-dotfiles-service-type
            (home-dotfiles-configuration
             (directories '("../files/guix"))))))
