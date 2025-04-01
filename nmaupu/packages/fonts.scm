(define-module (nmaupu packages fonts)
  #:use-module (guix build-system font)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix download))

(define-public font-nerd-commitmono
  (package
    (name "font-nerd-commitmono")
    (version "3.3.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append 
	      "https://github.com/ryanoasis/nerd-fonts/releases/download/v" version "/CommitMono.zip"))
       (sha256
        (base32
         "0bxk8mqalg2sf8pnm85p083imcjcnzz4h5lg0920dljqbz95w1gj"))))
    (build-system font-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-before 'install 'make-files-writable
           (lambda _
             (for-each
              make-file-writable
              (find-files "." ".*\\.(otf|otc|ttf|ttc)$"))
             #t)))))
    (home-page "https://www.nerdfonts.com/")
    (synopsis "Iconic font aggregator, collection, and patcher")
    (description
     "Nerd Fonts patches developer targeted fonts with a high number
of glyphs (icons). Specifically to add a high number of extra glyphs
from popular ‘iconic fonts’ such as Font Awesome, Devicons, Octicons,
and others.")
    (license expat)))
