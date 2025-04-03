(define-module (nmaupu packages keyboard-layout)
  #:use-module (guix build-system trivial)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix download))

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
    (build-system trivial-build-system)
    (native-inputs `(("source" ,source)
                     ("unzip" ,unzip)))
    (arguments
     `(#:modules ((guix build utils)
                  (srfi srfi-26))
       #:builder (begin
                   (use-modules (guix build utils))
                   (let* ((PATH (string-append (assoc-ref %build-inputs "unzip")
                                               "/bin"))
                          (out (assoc-ref %outputs "out"))
                          (source (assoc-ref %build-inputs "source")))
                     (setenv "PATH" PATH)
                     (mkdir-p out)
                     (system* "unzip" "-d" out source)))))
    (home-page "https://github.com/qwerty-fr/qwerty-fr")
    (synopsis "Qwertyfr keyboard layout")
    (description "Keyboard layout based on the QWERTY layout with extra symbols and diacritics so that typing both in French and English is easy and fast. It is also easy to learn!")
    (license expat)))
