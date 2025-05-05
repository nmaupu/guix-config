(define-module (nmaupu packages pwvucontrol)
  #:use-module (gnu packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix build-system meson)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages rust)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages python)
  #:use-module (gnu packages lua)
  )

(define lua-5.4.4
  (package
    (inherit lua-5.4)
    (version "5.4.4")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://www.lua.org/ftp/lua-"
                                  version ".tar.gz"))
              (sha256
               (base32 "0qdzkrxx4bpcfls6a1fa5n6wrxabi0xlgdy4prksx01vcm4phk0n"))
              (patches (search-patches "lua-5.4-pkgconfig.patch"
                                       "lua-5.4-liblua-so.patch"))))))

(define wireplumber-0.4
  (package
    (inherit wireplumber)
    (name "wireplumber")
    (version "0.4.90")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url
              "https://gitlab.freedesktop.org/pipewire/wireplumber.git")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1302zg5mnlhndv2nzrfvd76infhg5fwdqh3vkwk90cav698k1788"))))
    (arguments
     (list
      #:tests? #f))
    (inputs (modify-inputs (package-inputs wireplumber)
              (append python pkg-config lua-5.4.4)))))

(define-public pwvucontrol
  (package
    (name "pwvucontrol")
    (version "0.4.9")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/saivert/pwvucontrol.git")
              (commit version)))
        (file-name (git-file-name name version))
        (sha256
         (base32 "1ani2anfdksq0lj51sxw799m5sd1h3q4z8v8h7ayljgp9iaifqby"))))
    (build-system meson-build-system)
    (native-inputs
     (list pkg-config
           glib
           gtk
           libadwaita
           pipewire
           wireplumber-0.4
           rust
           cmake))
    (home-page "https://github.com/saivert/pwvucontrol")
    (synopsis "pwvucontrol")
    (description "pwvucontrol")
    (license license:gpl3)))
