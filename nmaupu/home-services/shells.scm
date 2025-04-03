(define-module (nmaupu home-services shells)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (gnu home services shells)
  #:use-module (guix gexp)
  #:use-module (nmaupu packages antidote)
  #:use-module (nmaupu packages alacritty-theme))

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
   (service home-dotfiles-service-type
            (home-dotfiles-configuration
             (directories '("../files/alacritty"))))
   (simple-service 'extra-config-files-from-packages
                   home-files-service-type
                   `((".config/zsh/.antidote"
                      ,(directory-union "antidote"
                                        (list antidote)))
                     (".config/alacritty/themes"
                      ,(directory-union "alacritty-theme"
                                        (list alacritty-theme)))))
   (simple-service 'zsh-misc-configs
                   home-files-service-type
                   `((".config/zsh/.p10k.zsh" ,(local-file "../files/zsh/p10k"))
                     (".config/zsh/.zsh_plugins.txt" ,(local-file "../files/zsh/zsh_plugins.txt"))))
   (service home-zsh-service-type
            (home-zsh-configuration
             (zshrc (list (local-file
                           "../files/zsh/zshrc"
                           "zshrc")))
             (zprofile (list (local-file
                              "../files/zsh/zprofile" "zprofile")))))
   (service home-bash-service-type
            (home-bash-configuration
             (bashrc (list (local-file
                            "../files/bash/bashrc"
                            "bashrc")))
             (bash-logout (list (local-file
                                 "../files/bash/bash_logout"
                                 "bash_logout")))))))
