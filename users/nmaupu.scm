(define-module (users nmaupu)
 #:use-module (gnu home)
 #:use-module (gnu packages)
 #:use-module (gnu services)
 #:use-module (guix packages)
 #:use-module (guix gexp)
 #:use-module (home shells))

(define my-home
  (home-environment
    (packages (append
        shells-packages))
    (services
      (append 
        (bash-service)))))

my-home
