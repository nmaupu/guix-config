(define-module (nmaupu home-services dev)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (gnu home services shepherd)
  #:use-module (guix gexp)
  #:use-module (nmaupu packages tfenv)
  #:use-module (nmaupu packages goenv))

(define (with-home p)
  (string-append "$HOME/" p))

;; tfenv
(define %tfenv-root ".local/tfenv")
(define %tfenv-data-dir ".local/tfenv-data")

;; goenv
;; goenv-root is the directory where downloaded versions reside
(define %goenv-root ".local/goenv")
(define %goenv-data-dir ".local/goenv-data")

(define (home-dev-env-vars config)
  `(("TFENV_ROOT" . ,(with-home %tfenv-root)) ; root dir for tfenv files
    ("TFENV_CONFIG_DIR" . ,(with-home %tfenv-data-dir)) ; data dir where tf versions are downloaded
    ("GOENV_ROOT" . ,(with-home %goenv-data-dir)))) ; data dir where go versions are downloaded

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
                                        (list tfenv)))
                     (,%goenv-root
                      ,(directory-union "goenv"
                                        (list goenv)))))
   (service home-dev-service-type)))
