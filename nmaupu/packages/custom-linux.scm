(define-module (nmaupu packages custom-linux)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages lua)
  ;; custom-pipewire
  #:use-module (gnu packages avahi)
  #:use-module (gnu packages video)
  #:use-module (gnu packages gstreamer)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages libusb)
  #:use-module (gnu packages readline)
  ;;
  #:use-module (nongnu packages linux)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (guix git-download)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages))

;; Updated linux-firmware for better support (try to fix suspend issue on 6.14 kernel with driver 'xe')
(define-public custom-linux-firmware
  (package
    (inherit linux-firmware)
    (name "custom-linux-firmware")
    (version "20250509")
    (source (origin
              (method url-fetch)
              (uri (string-append "mirror://kernel.org/linux/kernel/firmware/"
                                  "linux-firmware-" version ".tar.xz"))
              (sha256
               (base32
                "0gkhpl60iw83pa8pq4hf8rrrc8nk8kjychsnrcq838i6y9k0vipj"))))))

;; alsa-lib is a bit too old for the sound to work, need a version >= 1.2.13
;; But beware, installing this package is not enough! We also need to rebuild all underlying packages using this one as dependency...
;; pipewire, wireplumber, etc...
(define-public custom-alsa-lib
  (package
    (inherit alsa-lib)
    (name "custom-alsa-lib")
    (version "1.2.14")
    (source
     (origin
        (method url-fetch)
        (uri (string-append
              "https://www.alsa-project.org/files/pub/lib/alsa-lib-" version ".tar.bz2"))

        (sha256
         (base32 "0cksx4p7mwny5xxf8ai9f3v45q9m99sjnyhnfkfnfhv0nfh8i75y"))))
    (arguments
     '(#:configure-flags (list (string-append "LDFLAGS=-Wl,-rpath="
                                              (assoc-ref %outputs "out")
                                              "/lib"))
       #:phases
       (modify-phases %standard-phases
         (add-before 'install 'pre-install
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let* ((ucm
                     (string-append (assoc-ref inputs "custom-alsa-ucm-conf")))
                    (topology
                     (string-append (assoc-ref inputs "custom-alsa-topology-conf")))
                    (alsa
                     (string-append (assoc-ref outputs "out") "/share/alsa"))
                    (ucm-share
                     (string-append ucm "/share/alsa/ucm"))
                    (ucm2-share
                     (string-append ucm "/share/alsa/ucm2"))
                    (topology-share
                     (string-append topology "/share/alsa/topology")))
               (mkdir-p alsa)
               (symlink ucm-share (string-append alsa "/ucm"))
               (symlink ucm2-share (string-append alsa "/ucm2"))
               (symlink topology-share (string-append alsa "/topology")))
             #t)))))
    (inputs
     (list custom-alsa-ucm-conf custom-alsa-topology-conf))))

(define-public custom-alsa-ucm-conf
  (package
    (inherit alsa-ucm-conf)
    (name "custom-alsa-ucm-conf")
    (version "1.2.14")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "ftp://ftp.alsa-project.org/pub/lib/alsa-ucm-conf-" version ".tar.bz2"))
              (sha256
               (base32
                "08cw0siyjgic08vzjxf43q7qsfy3jd9f6chhm9wbk4idb6gq1s9j"))))))

(define-public custom-alsa-topology-conf
  (package
    (inherit alsa-topology-conf)
    (name "custom-alsa-topology-conf")
    (version "1.2.5")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "ftp://ftp.alsa-project.org/pub/lib/alsa-topology-conf-" version ".tar.bz2"))
              (sha256
               (base32
                "0p3pin6dswdaqnk0026xnzaipfbk09k89s8bx35x1qb3r8387ylb"))))))

(define-public custom-alsa-utils
  (package
    (inherit alsa-utils)
    (name "custom-alsa-utils")
    (version "1.2.14")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://www.alsa-project.org/files/pub/utils/alsa-utils-" version ".tar.bz2"))
              (sha256
               (base32 "0h87jv02ki2gk3l6lga0dhmk22g4i4qc2286qpkl7ngy6d6wg507"))))
    (inputs (modify-inputs (package-inputs alsa-utils)
                           (replace "alsa-lib" custom-alsa-lib)
                           (append pkg-config)))))

(define-public custom-pipewire
  (package
    (inherit pipewire)
    (name "custom-pipewire")
    (version "1.4.2")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://gitlab.freedesktop.org/pipewire/pipewire")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0kqicbigz71ipnslqks8bz6zibcaqr9bydd7b9kb7k4sz5vg655v"))))
    (inputs (modify-inputs (package-inputs pipewire)
                           (replace "alsa-lib" custom-alsa-lib)))))

(define-public custom-wireplumber
  (package
    (inherit wireplumber)
    (name "custom-wireplumber")
    (version "0.5.8")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url
              "https://gitlab.freedesktop.org/pipewire/wireplumber.git")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0g6gv7apwyc74z4rfhcdgdgwidda7cy4znwjjq39q4jh24dg70j4"))))
    (inputs (modify-inputs (package-inputs wireplumber)
                           (replace "pipewire" custom-pipewire)))))
