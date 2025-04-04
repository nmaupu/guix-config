(define-module (nmaupu home-services emacs)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (gnu home services shepherd)
  #:use-module (guix gexp))

;; We want to have doom emacs and custom configuration *not read-only*.
;; To achieve that, we are using a custom shell script
;; to run doom-emacs.
;; If relevant directories are missing, the startup script install the needed files
;; and pull the needed repositories.

(use-package-modules emacs)

(define (home-emacs-profile-service config)
  (list emacs))

(define home-emacs-service-type
  (service-type (name 'emacs)
                (description "Packages and configuration for emacs.")
                (extensions
                 (list (service-extension
                        home-profile-service-type
                        home-emacs-profile-service)))
                (default-value #f)))

(define-public home-emacs-services
  (list
   (service home-emacs-service-type)
   (service home-dotfiles-service-type
            (home-dotfiles-configuration
             (directories '("../files/emacs"))))))
