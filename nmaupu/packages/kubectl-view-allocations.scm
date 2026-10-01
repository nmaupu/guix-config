(define-module (nmaupu packages kubectl-view-allocations)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download))

;; kubectl plugin: any executable named kubectl-<name> found in PATH is
;; picked up by kubectl.  Dashes in the subcommand map to underscores in
;; the file name, so `kubectl view-allocations' looks for
;; kubectl-view_allocations; we provide that as a symlink to the binary.
;; We use the statically linked musl release so it runs on Guix without
;; patching the ELF interpreter.
(define-public kubectl-view-allocations
  (package
    (name "kubectl-view-allocations")
    (version "3.1.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/davidB/kubectl-view-allocations/releases/download"
                           "/" version "/kubectl-view-allocations_" version
                           "-x86_64-unknown-linux-musl.tar.gz"))
       (sha256
        (base32 "01w4cmfqqpyzmbil7xbr9bl9ck71qz3dhcc6gp61mxp37w2sbn01"))))
    (build-system copy-build-system)
    (arguments
     `(#:install-plan '(("kubectl-view-allocations" "bin/"))
       #:phases (modify-phases %standard-phases
                  (add-after 'install 'make-executable
                    (lambda* (#:key outputs #:allow-other-keys)
                      (let* ((out (assoc-ref outputs "out"))
                             (bin (string-append out "/bin/kubectl-view-allocations")))
                        (chmod bin #o555)
                        ;; Name kubectl resolves for `kubectl view-allocations'
                        (symlink "kubectl-view-allocations"
                                 (string-append out "/bin/kubectl-view_allocations"))
                        #t))))))
    (supported-systems '("x86_64-linux"))
    (home-page "https://github.com/davidB/kubectl-view-allocations")
    (synopsis "kubectl plugin to list allocations (cpu, memory, gpu,...) per node, pod, namespace")
    (description "kubectl plugin to list allocations for resources (cpu, memory, gpu,...)
as requested, limit, allocatable and utilization, grouped by node, namespace, pod or
resource.  Invoked as @command{kubectl view-allocations}.")
    (license license:cc0)))
