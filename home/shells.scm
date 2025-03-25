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
    "antigen"))

(define-public bash-service
  (list
    (service home-bash-service-type
      (home-bash-configuration 
        (aliases '(("ls" . "ls --color=auto")))
        (bashrc (list (local-file
                        "../files/bashrc"
                        "bashrc")))
        (environment-variables
          '(("TEST" . "val")))
        (bash-logout (list (local-file
                             "../files/bash_logout"
                             "bash_logout")))
      ))))
