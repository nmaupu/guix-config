;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(define-module (config home home-config)
 #:use-module (gnu home)
 #:use-module (gnu packages)
 #:use-module (gnu services)
 #:use-module (gnu home services shells)
 #:use-module (guix packages)
 #:use-module (guix gexp)
 #:use-module (config packages antigen))

(home-environment
  (packages (specifications->packages (list
					"antigen"
					"git"
				        "vim"
				        "zsh")))
  (services
    (append 
      (list 
	(service home-zsh-service-type
		 (home-zsh-configuration
		   (zshrc (list (local-file ".zshrc" "zshrc"))))))
      %base-home-services)))
