(define-module (nmaupu packages google-cloud-sdk)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system trivial)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (gnu packages compression)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix build utils)
  #:use-module ((nonguix licenses) #:prefix licensenon:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages python)
  #:use-module (guix build copy-build-system))

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

;; TODO: simplify and modularize templating - good luck!
(define %google-cloud-sdk-pubsub-emulator
  (package
   (inherit (%google-cloud-sdk-component #:comp-id "pubsub-emulator"
                                         #:version "20250221145621"
                                         #:hash "1dzi301z0mi7ilwbdkiwry2s7gh1fmqnlzn82dsbimslybwq58ya"
                                         #:include-arch? #f))
   (arguments
    (list
     #:install-plan #~'(("./" "/platform"))
     #:phases
     #~(modify-phases %standard-phases
         (add-after 'install 'add-manifest-file
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (template-file #$(local-file "./tpl/google-cloud-sdk-pubsub-emulator.snapshot.json.in"))
                    (template-dest (string-append out "/.install/pubsub-emulator.snapshot.json")))
               (mkdir-p (dirname template-dest))
               (copy-file template-file template-dest)
               (for-each
                (lambda (pair)
                  (substitute* template-dest
                    (((string-append "@" (car pair) "@")) (cdr pair))))
                '(("checksum" . "89669e0a6be302acf1cf7e773e61d02b5514ccd84ae1e34a4dd7fa6eff1c5bef")
                  ("description" . "Provides the Pub/Sub emulator.")
                  ("display-name" . "Cloud Pub/Sub Emulator")
                  ("id" . "pubsub-emulator")
                  ("version" . "20250221145621")
                  ("version-string" . "0.8.19")
                  ("revision" . "20250411141747")
                  ("url" . "https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.tar.gz")
                  ("gcloud-sdk-version" . "518.0.0")))
               #t))))))))

;; (define (template-phase template-file dest-path substitutions)
;;   #~(lambda* (#:key outputs #:allow-other-keys)
;;       (use-modules (guix build utils))
;;       (let* ((out (assoc-ref outputs "out"))
;;              (subs '#$substitutions)
;;              (target (string-append out "/" #$dest-path)))
;;         (mkdir-p (dirname target))
;;         (copy-file #$template-file target)
;;         (format (current-error-port) "DEBUG substitutions: ~s~%" subs)
;;         (for-each
;;          (lambda (pair)
;;            (substitute* target
;;              ((car pair) (cdr pair))))
;;          subs)
;;         #t)))

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
           ;; (call-with-output-file (string-append out "/.install/pubsub-emulator.snapshot.json") (lambda (p) #t)) ; Create fake empty manifest file to mimik a real install
           #t))))))
