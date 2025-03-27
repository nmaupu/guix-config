(define-module (config home-services tmux)
  #:use-module (gnu packages)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles))

(define-public tmux-packages
  (list
   "tmux"
   "tmux-plugin-resurrect"))

(define-public tmux-service
  (list
   (service home-dotfiles-service-type
            (home-dotfiles-configuration
             (directories '("../files/tmux"))))))
