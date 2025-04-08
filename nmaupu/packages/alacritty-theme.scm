(define-module (nmaupu packages alacritty-theme)
  #:use-module (guix build-system copy)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix git-download))

(define-public alacritty-theme
  (package
    (name "alacritty-theme")
    (version "master-86c578469e2bf784faf6f916883bf48349ff4f6d")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/alacritty/alacritty-theme.git")
                    (commit "86c578469e2bf784faf6f916883bf48349ff4f6d")))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "063899ssfl2hhsidqj73d8sjv1874yywh6fnjrrk4gl8hfsqi96l"))))
    (build-system copy-build-system)
    (home-page "https://github.com/alacritty/alacritty-theme")
    (synopsis "Alacritty theme collection")
    (description "Collection of colorschemes for easy configuration of the Alacritty terminal emulator.")
    (license asl2.0)))
