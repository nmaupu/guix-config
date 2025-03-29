(define-module (nmaupu home-services shells)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services shells)
  #:use-module (guix gexp)
  #:use-module (nmaupu packages antigen))

(use-package-modules shells terminals bash)

(define (home-shells-profile-service config)
  (list alacritty
        zsh
        bash))

(define (home-desktop-env-vars config)
  '(("TERM" . "xterm-256color")
    ("DOCKER_ID" . "nmaupu")))

(define home-shells-service-type
  (service-type (name 'shells)
                (description "Packages and configuration for shells.")
                (extensions
                 (list (service-extension
                        home-profile-service-type
                        home-shells-profile-service)
                       (service-extension
                        home-environment-variables-service-type
                        home-desktop-env-vars)))
                (default-value #f)))

(define-public home-shells-services
  (list
   (service home-shells-service-type)
   (simple-service 'zsh-antigen
                   home-files-service-type
                   `((".antigen.zsh" ,(file-append antigen "/antigen.zsh"))))
   (simple-service 'zsh-misc-configs
                   home-files-service-type
                   `((".config/zsh/.p10k.zsh" ,(local-file "../files/zsh/p10k"))))
   (service home-zsh-service-type
            (home-zsh-configuration
             (zshrc (list (local-file
                           "../files/zsh/zshrc"
                           "zshrc")))))
   (service home-bash-service-type
            (home-bash-configuration
             (bashrc (list (local-file
                            "../files/bashrc"
                            "bashrc")))
             (bash-logout (list (local-file
                                 "../files/bash_logout"
                                 "bash_logout")))))))
