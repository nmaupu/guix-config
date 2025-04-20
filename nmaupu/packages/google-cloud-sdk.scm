(define-module (nmaupu packages google-cloud-sdk)
  #:use-module (guix build-system copy)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (gnu packages compression)
  #:use-module (guix gexp)
  #:use-module ((nonguix licenses) #:prefix licensenon:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages python))

;; Latest releases are available at
;; https://console.cloud.google.com/storage/browser/cloud-sdk-release
(define-public google-cloud-sdk
  (package
    (name "google-cloud-sdk")
    (version "518.0.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads"
                           "/google-cloud-sdk-" version "-linux-x86_64.tar.gz"))
       (sha256
        (base32 "18lwpcm30s810q50z9xmw34lm1xkjfs39639argffgla4vlrp1cp"))))
    (build-system copy-build-system)
    (propagated-inputs (list python))
    (home-page "https://cloud.google.com/sdk/gcloud")
    (synopsis "Google Cloud CLI")
    (description (string-append "The Google Cloud CLI is a set of tools to create and manage Google Cloud resources. You can use these tools to perform many common platform tasks from the command line or through scripts and other automation."))
    (license (licensenon:nonfree "https://cloud.google.com/source-repositories/docs/features"))))

;;
