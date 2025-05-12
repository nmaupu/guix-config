(define-module (nmaupu packages google-cloud-sdk)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system trivial)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (gnu packages compression)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module ((nonguix licenses) #:prefix licensenon:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages python))

;; Latest releases are available at
;; https://console.cloud.google.com/storage/browser/cloud-sdk-release
(define %google-cloud-sdk
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

;; Components are available at
;; https://console.cloud.google.com/storage/browser/cloud-sdk-release/release/components
(define* (%google-cloud-sdk-component #:key comp-id version hash (include-arch? #t))
  (package
   (name (string-append "google-cloud-sdk-" comp-id))
   (version version)
   (source
    (origin
     (method url-fetch)
     (uri (string-append "https://storage.googleapis.com/cloud-sdk-release/release/components"
                         "/google-cloud-sdk-" comp-id (if include-arch? "-linux-x86_64-" "-") version ".tar.gz"))
     (sha256
      (base32 hash))))
    (build-system copy-build-system)
    (arguments
     `(#:install-plan '((,comp-id ,(string-append "bin/" comp-id)))))
    (home-page "https://cloud.google.com/sdk/gcloud")
    (synopsis "Google Cloud CLI")
    (description (string-append "The Google Cloud CLI is a set of tools to create and manage Google Cloud resources. You can use these tools to perform many common platform tasks from the command line or through scripts and other automation."))
    (license (licensenon:nonfree "https://cloud.google.com/source-repositories/docs/features"))))

(define-public google-cloud-sdk-gke-gcloud-auth-plugin
  (%google-cloud-sdk-component #:comp-id "gke-gcloud-auth-plugin"
                               #:version "20250117151628"
                               #:hash "1nkkbsdc8p323ddlj1aykl5ilmb2hmi6dq13mpskn5g9h7a7rqab"))

(define-public google-cloud-sdk-minikube
  (%google-cloud-sdk-component #:comp-id "minikube"
                               #:version "20250210213649"
                               #:hash "0pybkn95l9kr0wsk63jfb1riadpf5jcsx7xljb3wlgm818vm6k8x"))

(define %google-cloud-sdk-beta
  (package
   (inherit (%google-cloud-sdk-component #:comp-id "beta"
                                         #:version "20250221145621"
                                         #:hash "0q2pq5sf5mwc1jcb4kmla7z4cng7b399kqfyzns50i51ahl42zbh"
                                         #:include-arch? #f))
   (arguments
     `(#:install-plan `(("./" "/lib"))))))

(define %google-cloud-sdk-pubsub-emulator
  (package
   (inherit (%google-cloud-sdk-component #:comp-id "pubsub-emulator"
                                         #:version "20250221145621"
                                         #:hash "1dzi301z0mi7ilwbdkiwry2s7gh1fmqnlzn82dsbimslybwq58ya"
                                         #:include-arch? #f))
   (arguments
     `(#:install-plan `(("./" "/platform"))))))

;; Creating a google-cloud-sdk combining gcloud and several components all in one
(define-public google-cloud-sdk
  (package
    (inherit %google-cloud-sdk)
    (name "google-cloud-sdk")
    (source #f)
    (build-system trivial-build-system)
    (inputs `(("google-cloud-sdk" ,%google-cloud-sdk)
              ("google-cloud-sdk-beta" ,%google-cloud-sdk-beta)
              ("google-cloud-sdk-pubsub-emulator" ,%google-cloud-sdk-pubsub-emulator)))
    (arguments
     `(#:modules ((guix build utils))
       #:builder
       (begin
         (use-modules (guix build utils))
         (let ((out (assoc-ref %outputs "out"))
               (google-cloud-sdk (assoc-ref %build-inputs "google-cloud-sdk"))
               (google-cloud-sdk-beta (assoc-ref %build-inputs "google-cloud-sdk-beta"))
               (google-cloud-sdk-pubsub-emulator (assoc-ref %build-inputs "google-cloud-sdk-pubsub-emulator")))
           (mkdir-p out)
           (copy-recursively google-cloud-sdk out)
           (copy-recursively google-cloud-sdk-beta out)
           (copy-recursively google-cloud-sdk-pubsub-emulator out)
           (call-with-output-file (string-append out "/.install/pubsub-emulator.snapshot.json") (lambda (p) #t)) ; Create fake empty manifest file to mimik a real install
           #t))))))
