(define-module (nmaupu packages custom-greenclip)
  #:use-module (gnu packages haskell-apps)
  #:use-module (guix packages)
  #:use-module (guix utils))

;; ghc-validation-selective's test suite pins hedgehog < 1.5 and
;; hspec-hedgehog < 0.2, while Guix ships 1.5 and 0.3.0.0.  Cabal refuses to
;; configure with --enable-tests, breaking ghc-tomland and greenclip.
;; Disable the test suite so --enable-tests is not passed.
(define (disable-tests p)
  (package
    (inherit p)
    (arguments
     (substitute-keyword-arguments (package-arguments p)
       ((#:tests? _ #f) #f)))))

(define-public custom-greenclip
  ((package-input-rewriting/spec
    `(("ghc-validation-selective" . ,disable-tests)))
   greenclip))
