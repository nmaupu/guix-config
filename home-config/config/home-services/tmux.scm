(define-module (config home-services tmux)
  #:use-module (gnu packages)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (config packages tmux-tpm))

(define-public tmux-packages
  (list
   "tmux"
   "tmux-tpm"))

(define-public tmux-service
  (list
   (service home-dotfiles-service-type
            (home-dotfiles-configuration
             (directories '("../files/tmux"))))))
