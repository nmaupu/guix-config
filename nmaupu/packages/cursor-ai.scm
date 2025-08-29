(define-module (nmaupu packages cursor-ai)
  #:use-module (nonguix build-system chromium-binary)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module ((nonguix licenses) #:prefix licensenon:)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages wget))

(define-public cursor-ai
  (package
    (name "cursor-ai")
    (version "1.5.5")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://downloads.cursor.com/production/"
                           "823f58d4f60b795a6aefb9955933f3a2f0331d7b/"
                           "linux/x64/deb/amd64/deb/cursor_" version "_amd64.deb"))
       (file-name (string-append "cursor-" version ".deb"))
       (sha256
        (base32 "0pqjv3zyzfz8qa9vx3rvdwrhvsj9ggrg0815540c8brdfj0zfbhg"))))
    (build-system chromium-binary-build-system)
    (arguments
     (list #:substitutable? #f
           #:validate-runpath? #f
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'binary-unpack 'setup-cwd
                 (lambda _
                   (copy-recursively "usr/share/cursor" "."))))))
    (inputs
     (list nss))
    (propagated-inputs
     (list xdg-utils))
    (home-page "https://cursor.com")
    (synopsis "Cursor")
    (description "Cursor")
    (license (licensenon:nonfree "https://cursor.com/pricing"))))
