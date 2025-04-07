(define-module (nmaupu home-services shepherd-services)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (gnu home services shepherd)
  #:use-module (guix gexp))

(use-package-modules emacs haskell-apps)

(define-public home-shepherd-services
  (list
   (service home-shepherd-service-type
            (home-shepherd-configuration
             (auto-start? #t)
             (services
              (list
               (shepherd-service (documentation "Run the Emacs daemon.")
                                 (provision '(emacs-daemon))
                                 (start #~(make-forkexec-constructor
                                           (list #$(file-append emacs "/bin/emacs") "--fg-daemon")))
                                 (stop #~(make-kill-destructor)))
               (shepherd-service (documentation "Run the Greenclip daemon.")
                                 (provision '(greenclip))
                                 (start #~(make-forkexec-constructor
                                           (list #$(file-append greenclip "/bin/greenclip") "daemon")))
                                 (stop #~(make-kill-destructor)))))))))
