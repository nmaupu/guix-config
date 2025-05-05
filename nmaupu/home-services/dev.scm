(define-module (nmaupu home-services dev)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services gnupg)
  #:use-module (gnu packages patchutils)
  #:use-module (gnu packages gnupg)
  #:use-module (guix gexp)
  #:use-module (nmaupu packages tfenv)
  #:use-module (nmaupu packages goenv)
  #:use-module (nmaupu packages google-cloud-sdk)
  #:use-module (nmaupu packages talosctl)
  #:use-module (nmaupu packages vault)
  ;; TODO Create a specific home-service for pro tools
  #:use-module (nmaupu packages terragrunt)
  #:use-module (nmaupu packages git-secret)
  #:use-module (nmaupu packages skaffold)
  #:use-module (nmaupu packages sops)
  #:use-module (nmaupu packages docker))

(define (home-dev-profile-service config)
  ;; goenv is linked to ~/.local/goenv
  (list tfenv
        meld
        google-cloud-sdk
        google-cloud-sdk-gke-gcloud-auth-plugin
        google-cloud-sdk-minikube
        talosctl
        vault
        pinentry-rofi
        ;; TODO Create a specific home-service for pro tools
        gnupg
        terragrunt
        git-secret
        skaffold
        sops
        docker-compose))

(define (with-home p)
  (string-append "$HOME/" p))

(define %tfenv-data-dir ".local/tfenv-data")
(define %goenv-root ".local/goenv")
(define %goenv-data-dir ".local/goenv-data")

(define (home-dev-env-vars config)
  `(("TFENV_CONFIG_DIR" . ,(with-home %tfenv-data-dir)) ; data dir where tf versions are actually downloaded
    ("GOENV_ROOT" . ,(with-home %goenv-data-dir))))

(define home-dev-service-type
  (service-type (name 'dev-tools)
                (description "Dev tools configuration and packages.")
                (extensions
                 (list (service-extension
                        home-environment-variables-service-type
                        home-dev-env-vars)
                       (service-extension
                        home-profile-service-type
                        home-dev-profile-service)))
                (default-value #f)))

(define-public home-dev-services
  (list
   ;; goenv is a piece of crap and needs that the directory with goenv script is named without
   ;; the version in it. Hence, it's not possible to use the directory from /gnu/store directly...
   ;; As a result, we link it to the home directory under GOENV_ROOT
   (simple-service 'link-from-packages
                   home-files-service-type
                   `((,%goenv-root
                      ,(directory-union "goenv" (list goenv)))))
   (service home-gpg-agent-service-type
         (home-gpg-agent-configuration
          (pinentry-program
           (file-append pinentry-rofi "/bin/pinentry"))
          (ssh-support? #t)))
   (service home-dev-service-type)))
