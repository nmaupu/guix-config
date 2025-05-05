(define-module (nmaupu home-services k8s)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (guix gexp)
  #:use-module (nmaupu packages k8s))

; krew is installed manually

(define (home-kubernetes-profile-service config)
  (list
   helm-kubernetes-3.17
   k9s-0.40
   kind-0.27
   kubectl-1.32))

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
