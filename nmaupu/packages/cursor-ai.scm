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
    (version "2.2.20")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://downloads.cursor.com/production/"
                           "b3573281c4775bfc6bba466bf6563d3d498d1074/"
                           "linux/x64/deb/amd64/deb/cursor_" version "_amd64.deb"))
       (file-name (string-append "cursor-" version ".deb"))
       (sha256
        (base32 "1gcy7fl26qkqwdrhyxrxcfc8yfycddn9nfp4d0n1xranx50x7hn4"))))
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
