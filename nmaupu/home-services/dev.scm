(define-module (nmaupu home-services dev)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (gnu home services shepherd)
  #:use-module (guix gexp)
  #:use-module (nmaupu packages tfenv))

(define %tfenv-root ".local/tfenv")
(define %tfenv-config-dir ".local/tfenv-data")

(define (home-dev-env-vars config)
  `(("TFENV_ROOT" . ,(string-append "$HOME/" %tfenv-root))
    ("TFENV_CONFIG_DIR" . ,(string-append "$HOME/" %tfenv-config-dir))))

(define home-dev-service-type
  (service-type (name 'dev-tools)
                (description "Dev tools configuration and packages.")
                (extensions
                 (list (service-extension
                        home-environment-variables-service-type
                        home-dev-env-vars)))
                (default-value #f)))

(define-public home-dev-services
  (list
   (simple-service 'dev-configs-from-packages
                   home-files-service-type
                   `((,%tfenv-root
                      ,(directory-union "tfenv"
                                        (list tfenv)))))
   (service home-dev-service-type)))
