(define-module (home shells)
  #:use-module (gnu packages)
  #:use-module (gnu services)
  #:use-module (gnu home services shells)
  #:use-module (guix gexp)
  #:use-module (packages antigen))

(define-public shells-packages
  (list
    "zsh"
    "bash"
    "antigen"
    "zsh-autosuggestions"))

(define env-vars
  '(("TEST" . "val")
    ("DOCKER_ID" . "nmaupu")))

(define aliases
  '(("ls" . "ls --color=auto")
    ("grep" . "rg")))

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
    (service home-zsh-service-type
      (home-zsh-configuration
        (environment-variables env-vars)
        (zshrc (list (local-file
                      "../files/zshrc"
                      "zshrc")))))))
