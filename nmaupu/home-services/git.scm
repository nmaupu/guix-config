(define-module (nmaupu home-services git)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (guix gexp))

(use-package-modules version-control)

(define (home-git-profile-service config)
  (list git tig))

(define home-git-service-type
  (service-type (name 'git)
                (description "Packages and configuration regarding git")
                (extensions
                 (list (service-extension
                        home-profile-service-type
                        home-git-profile-service)))
                (default-value #f)))

(define-public home-git-services
  (list
   (service home-git-service-type)
   (service home-dotfiles-service-type
            (home-dotfiles-configuration
             (directories '("../files/git"))))))
