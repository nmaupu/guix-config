(define-module (nmaupu home-services tmux)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (guix gexp)
  #:use-module (nmaupu packages tmux-tpm))

(use-package-modules tmux)

(define (home-tmux-profile-service config)
  (list tmux))

(define home-tmux-service-type
  (service-type (name 'tmux)
                (description "Packages and configuration for tmux.")
                (extensions
                 (list (service-extension
                        home-profile-service-type
                        home-tmux-profile-service)))
                (default-value #f)))

(define-public home-tmux-services
  (list
   (service home-tmux-service-type)
   (simple-service 'tmux-tpm
                   home-files-service-type
                   `((".tmux/plugins/tpm"
                      ,(directory-union "tmux-tpm"
                                        (list tmux-tpm)))))
   (service home-dotfiles-service-type
            (home-dotfiles-configuration
             (directories '("../files/tmux"))))))
