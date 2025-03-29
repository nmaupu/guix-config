(define-module (nmaupu home-services base)
  #:use-module (gnu)
  #:use-module (gnu packages)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (nongnu packages mozilla))

(use-package-modules curl version-control admin linux web
                     vim python web-browsers rust-apps chromium)

(define (home-base-profile-service config)
  (list curl
        lm-sensors
        firefox
        git
        htop
        jq
        (specification->package "make")
        neovim
        python
        qutebrowser
        ripgrep
        fd
        tig
        ungoogled-chromium
        yq))

(define home-base-service-type
  (service-type (name 'base)
                (description "Packages and configuration for base stuff")
                (extensions
                 (list (service-extension
                        home-profile-service-type
                        home-base-profile-service)))
                (default-value #f)))

(define-public home-base-services
  (list
   (service home-base-service-type)))
