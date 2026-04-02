(define-module (nmaupu packages custom-arandr)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages glib)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils))

(define-public custom-arandr
  (package
    (inherit arandr)
    (name "custom-arandr")
    (propagated-inputs
     (modify-inputs (package-propagated-inputs arandr)
       (append gobject-introspection)))))
