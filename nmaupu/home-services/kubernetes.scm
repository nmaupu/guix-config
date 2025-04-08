(define-module (nmaupu home-services kubernetes)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (guix gexp)
  #:use-module (nmaupu packages helm))

(define (home-kubernetes-profile-service config)
  (list helm))

(define home-kubernetes-service-type
  (service-type (name 'kubernetes-tools)
                (description "Packages and configuration for kubernetes related stuff.")
                (extensions
                 (list (service-extension
                        home-profile-service-type
                        home-kubernetes-profile-service)))
                (default-value #f)))

(define-public home-kubernetes-services
  (list
   (service home-kubernetes-service-type)))
