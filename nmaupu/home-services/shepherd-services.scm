(define-module (nmaupu home-services shepherd-services)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (gnu home services shepherd)
  #:use-module (guix gexp)
  #:use-module (nmaupu packages xidlehook))

(use-package-modules emacs haskell-apps fonts xdisorg)

;; (define xsecurelock-env-vars
;;   (list "XSECURELOCK_COMPOSITE_OBSCURER=0"
;;         "XSECURELOCK_SHOW_HOSTNAME=0"
;;         "XSECURELOCK_SHOW_USERNAME=0"
;;         "XSECURELOCK_PASSWORD_PROMPT=cursor"
;;         "XSECURELOCK_SHOW_DATETIME=1"))

;; (define xidlehook-shepherd-service
;;   (shepherd-service (documentation "Run the xidlehook daemon which locks an idle laptop.")
;;                     (provision '(xidlehook))
;;                     (respawn? #t)
;;                     (stop #~(make-kill-destructor))
;;                     (start #~(make-forkexec-constructor
;;                               (list #$(file-append xidlehook "/bin/xidlehook")
;;                                     "--socket" "/run/user/1000/xidlehook.sock"
;;                                     "--not-when-fullscreen"
;;                                     "--timer" "120"
;;                                     #$(file-append xsecurelock "/bin/xsecurelock") "''")
;;                               #:environment-variables (append '#$xsecurelock-env-vars
;;                                                               default-environment-variables)))))

(define-public home-shepherd-services
  (list
   (service home-shepherd-service-type
            (home-shepherd-configuration
             (auto-start? #t)
             (services
              (list
               ;; xidlehook-shepherd-service
               (shepherd-service (documentation "Run the Emacs daemon.")
                                 (provision '(emacs-daemon))
                                 (respawn? #t)
                                 (stop #~(make-kill-destructor))
                                 (start #~(make-forkexec-constructor
                                           (list #$(file-append emacs "/bin/emacs") "--fg-daemon"))))
               (shepherd-service (documentation "Run the Greenclip daemon.")
                                 (provision '(greenclip))
                                 (respawn? #t)
                                 (stop #~(make-kill-destructor))
                                 (start #~(make-forkexec-constructor
                                           (list #$(file-append greenclip "/bin/greenclip") "daemon"))))))))))
