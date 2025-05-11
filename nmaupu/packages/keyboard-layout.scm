(define-module (nmaupu packages keyboard-layout)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages xorg)
  #:use-module (guix build-system copy)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp))

; qwertyfr keyboard layout
(define-public qwerty-fr
  (package
    (name "qwerty-fr")
    (version "0.7.3")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/qwerty-fr/qwerty-fr/releases/download/v"
                                  version "/qwerty-fr_" version "_linux.zip"))
              (sha256
               (base32
                "0csxzs2gk8l4y5ii1pgad8zxr9m9mfrl9nblywymg01qw74gpvnm"))))
    (build-system copy-build-system)
    (native-inputs (list unzip))
    (home-page "https://github.com/qwerty-fr/qwerty-fr")
    (synopsis "Qwertyfr keyboard layout")
    (description "Keyboard layout based on the QWERTY layout with extra symbols and diacritics so that typing both in French and English is easy and fast. It is also easy to learn!")
    (license expat)))

;; (define-public xkeyboard-config-with-qwerty-fr
;;   (package
;;     (inherit xkeyboard-config)
;;     (name "xkeyboard-config-with-qwerty-fr")
;;     (arguments
;;      `(#:phases
;;        (modify-phases %standard-phases
;;          (add-after 'install 'add-qwerty-fr
;;            (lambda* (#:key inputs outputs #:allow-other-keys)
;;              (let ((out (assoc-ref outputs "out"))
;;                    (qfr (assoc-ref inputs "qwerty-fr")))
;;                (copy-recursively
;;                 (string-append qfr "/share/")
;;                 (string-append out "/share/")))
;;              #t)))))
;;     (inputs (list qwerty-fr))))
