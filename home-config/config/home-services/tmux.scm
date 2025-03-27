(define-module (config home-services tmux)
  #:use-module (gnu services)
  #:use-module (gnu packages)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (guix gexp)
  #:use-module (config packages tmux-tpm))

(define-public tmux-packages
  (cons*
   tmux-tpm
   (map specification->package
        '("tmux"))))

(define-public tmux-service
  (list
   (simple-service 'tmux-tpm
                   home-files-service-type
                   `((".tmux/plugins/tpm"
                      ,(directory-union "tmux-tpm"
                                        (list tmux-tpm)))))
   (service home-dotfiles-service-type
            (home-dotfiles-configuration
             (directories '("../files/tmux"))))))
