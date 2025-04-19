(define-module (nmaupu packages slack)
  #:use-module (nonguix build-system chromium-binary)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module ((nonguix licenses) #:prefix licensenon:)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages wget))

(define-public slack
  (package
    (name "slack")
    (version "4.43.51")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://downloads.slack-edge.com/desktop-releases"
                           "/linux/x64/" version
                           "/slack-desktop-" version "-amd64.deb"))
       (file-name (string-append "slack-" version ".deb"))
       (sha256
        (base32 "09lkqnfgil0zaq5nlaph9cbrh622ywx05ma29h6ak4n6pismr3jk"))))
    (build-system chromium-binary-build-system)
    (arguments
     (list #:substitutable? #f
           #:validate-runpath? #f
           #:wrapper-plan
           #~'(("lib/slack/slack" (("out" "/lib/slack"))))
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'binary-unpack 'setup-cwd
                 (lambda _
                   (copy-recursively "usr/" ".")
                   ;; Remove unneeded files.
                   (delete-file-recursively "usr")
                   (delete-file-recursively "bin")
                   (delete-file-recursively "etc")))
               (add-after 'install 'symlink-binary-file
                 (lambda _
                   (mkdir-p (string-append #$output "/bin"))
                   (symlink (string-append #$output "/lib/slack/slack")
                            (string-append #$output "/bin/slack")))))))
    (inputs
     (list nss))
    (propagated-inputs
     (list xdg-utils))
    (home-page "https://slack.com")
    (synopsis "Slack")
    (description "Slack")
    (license (licensenon:nonfree "https://slack.com/pricing"))))
