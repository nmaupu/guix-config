(define-module (config home-services shells)
  #:use-module (gnu packages)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services shells)
  #:use-module (guix gexp)
  #:use-module (config packages antigen))

(define-public shells-packages
  (cons*
   antigen
   (map specification->package
        '("alacritty"
          "zsh"
          "bash"
          "zsh-autosuggestions"))))

(define env-vars
  '(("TERM" . "xterm-256color")
    ("DOCKER_ID" . "nmaupu")))

(define aliases
  '(("ls" . "ls --color=auto")))

(define-public bash-service
  (list
    (service home-bash-service-type
      (home-bash-configuration
        (aliases aliases)
        (environment-variables env-vars)
        (bashrc (list (local-file
                        "../files/bashrc"
                        "bashrc")))
        (bash-logout (list (local-file
                             "../files/bash_logout"
                             "bash_logout")))))))

(define-public zsh-service
  (list
   (simple-service 'zsh-antigen
                   home-files-service-type
                   `((".antigen.zsh" ,(file-append antigen "/antigen.zsh"))))
   (simple-service 'zsh-misc-configs
                   home-files-service-type
                   `((".config/zsh/.p10k.zsh" ,(local-file "../files/zsh/p10k"))))
   (service home-zsh-service-type
            (home-zsh-configuration
             (environment-variables env-vars)
             (zshrc (list (local-file
                           "../files/zsh/zshrc"
                           "zshrc")))))))
