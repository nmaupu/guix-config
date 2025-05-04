(define-module (nmaupu packages xidlehook)
  #:use-module (guix git-download)
  #:use-module (guix download)
  #:use-module (guix packages)
  #:use-module (guix build-system cargo)
  #:use-module (gnu packages crates-io)
  #:use-module (gnu packages crates-graphics)
  #:use-module (gnu packages crates-audio)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages python)
  #:use-module (gnu packages pkg-config)
  #:use-module ((guix licenses) #:prefix licenses:))

(define-public rust-xcb-0.9
  (package
    (inherit rust-xcb-1)
    (name "rust-xcb")
    (version "0.9.0")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "xcb" version))
       (file-name
        (string-append name "-" version ".tar.gz"))
       (sha256
        (base32
         "19i2pm8alpn2f0m4jg8bsw6ckw8irj1wjh55h9pi2fcb2diny1b2"))))
    (build-system cargo-build-system)
    (arguments
     `(#:tests? #f  ; Building all the features tests the code.
       #:cargo-build-flags '("--features" "debug_all")
       #:cargo-inputs
       (("rust-libc" ,rust-libc-0.2)
        ("rust-log" ,rust-log-0.4)
        ("rust-x11" ,rust-x11-2))))
    (inputs
     (list libx11 libxcb xcb-proto))
    (native-inputs
     (list pkg-config python))))

(define-public xidlehook
  (package
    (name "xidlehook")
    (version "5c6cd2fe944898258c17e877b6ea26a84b5070ed")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://gitlab.com/jD91mZM2/xidlehook.git")
              (commit version)))
        (file-name (git-file-name name version))
        (sha256
         (base32 "0swgraa196p6rdbb9m1pf97byhm5pfsl7f592zn7yy1la3h9qshb"))))
    (build-system cargo-build-system)
    (arguments
     `(#:install-source? #f
       #:cargo-build-flags '("--release" "--bins")
       #:cargo-inputs
       (("rust-xcb" ,rust-xcb-0.9)
        ("rust-env-logger" ,rust-env-logger-0.11)
        ("rust-nix" ,rust-nix-0.15)
        ("rust-structopt" ,rust-structopt-0.3)
        ("rust-libpulse-binding" ,rust-libpulse-binding-2))
       #:phases (modify-phases %standard-phases
                  (replace 'install
                    (lambda* (#:key outputs #:allow-other-keys)
                      (let* ((out (assoc-ref outputs "out"))
                             (bin (string-append out "/bin")))
                        (mkdir-p bin)
                        (install-file "target/release/xidlehook" bin)
                        (install-file "target/release/xidlehook-client" bin)))))))
    (inputs
     (list libxscrnsaver pulseaudio libxcb))
    (native-inputs
     (list pkg-config python))
    (home-page "https://github.com/jD91mZM2/xidlehook")
    (synopsis "xidlehook is a general-purpose replacement for xautolock. It executes a command when the computer has been idle for a specified amount of time.")
    (description "xidlehook is a general-purpose replacement for xautolock. It executes a command when the computer has been idle for a specified amount of time.")
    (license licenses:expat)))
