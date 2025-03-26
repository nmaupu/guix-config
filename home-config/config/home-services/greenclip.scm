(define-module (config home-services greenclip)
  #:use-module (gnu services)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu packages haskell-apps) ; greenclip package obj
  #:use-module (guix gexp))

(define-public greenclip-packages
  '("greenclip"))

(define-public greenclip-service
  (list
   (service home-shepherd-service-type
            (home-shepherd-configuration
             (auto-start? #t)
             (services
              (list
               (shepherd-service
                (documentation "Run the Greenclip daemon.")
                (provision '(greenclip))
                (start #~(make-forkexec-constructor
                          (list #$(file-append greenclip "/bin/greenclip") "daemon")))
                (stop #~(make-kill-destructor)))))))))
