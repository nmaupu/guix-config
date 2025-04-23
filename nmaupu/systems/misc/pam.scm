(define-module (nmaupu systems misc pam)
  #:use-module (gnu services)
  #:use-module (gnu system pam)
  #:use-module (guix gexp)
  #:use-module (gnu packages freedesktop))

(define-public fprintd-pam-service
  (simple-service 'fprintd-pam-service pam-root-service-type
                  (let ((fprintd-pam-entry
                         (pam-entry
                          (control "sufficient")
                          (module (file-append fprintd "/lib/security/pam_fprintd.so")))))
                    (list (pam-extension
                           (transformer
                            (lambda (pam)
                              (if (or (string=? "gdm-password" (pam-service-name pam))
                                      ;; (string=? "sudo" (pam-service-name pam))
                                      ;; (string=? "xsecurelock" (pam-service-name pam)) ;; not working for now
                                  )
                                  (pam-service
                                   (inherit pam)
                                   (auth
                                    (append (list fprintd-pam-entry)
                                            (pam-service-auth pam))))
                                  pam))))))))
