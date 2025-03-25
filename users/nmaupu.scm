(define-module (users nmaupu)
 #:use-module (gnu home)
 #:use-module (gnu packages)
 #:use-module (gnu services)
 #:use-module (guix packages)
 #:use-module (guix gexp)
 #:use-module (home shells)
 #:use-module (home base))

(define my-home
  (home-environment
    (packages (specifications->packages
                (append
                  base-packages
                  shells-packages)))
    (services (append
               zsh-service
               bash-service))))

my-home
