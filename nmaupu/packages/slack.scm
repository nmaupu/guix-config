(define-module (nmaupu packages slack)
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

;; Slack will start and ask to login via the browser.
;; To do that, it uses xdg-open which has to be installed (see propagated-inputs)
;; The redirection might not work but in that case, copy the "try again" link
;; and focus the slack window. After 2 seconds, a redirection occurs.
;; When upgrading, relink /lib64/ld-linux-x86-64.so.2 to the correct glibc.
;; This is needed by slack's lib/slack/chrome_crashpad_handler
(define-public slack
  (package
    (name "slack")
    (version "4.45.64")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://downloads.slack-edge.com/desktop-releases"
                           "/linux/x64/" version
                           "/slack-desktop-" version "-amd64.deb"))
       (file-name (string-append "slack-" version ".deb"))
       (sha256
        (base32 "03qqxpgyiyfn47l5i13ym21qm57rp5vpskhdjgn8lxymn5mghskw"))))
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
