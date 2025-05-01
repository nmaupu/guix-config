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

;; An experimental option needs to be enabled for the sound to work properly
;; Here is the options to enable in the kernel configuration
;; Device Drivers > Sound card support > Advanced Linux Sound Architecture > ALSA for SoC audio support > Intel Machine drivers > SoundWire generic machine driver
;; To access this module, we need to also enable "Use more user friendly long card names" at the top
;; This will ensure snd_soc_sof_sdw module is built and loaded with sof-firmware
;; Here I use the 6.14 kernel because it's the latest available but it should work with 6.12+ kernel
;; Making a defconfig is easy:
;;   - download kernel: wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.14.1.tar.xz
;;   - uncompress and cd to the directory
;;   - copy old configuration: zcat /proc/config.gz > .config
;;   - edit current config with: make menuconfig
;;   - save the defconfig file: make savedefconfig
;; This can also help to get make menuconfig work or compile a kernel:
;; guix shell --container --emulate-fhs -L ~/.dotfiles flex bison gmp mpfr mpc make cmake gcc-toolchain coreutils sed findutils ncurses grep
;; or
;; guix environment -L ~/.dotfiles --ad-hoc perl bc openssl elfutils flex bison util-linux gmp mpfr mpc dwarves python-wrapper zlib zstd ncurses cpio
(define-public custom-linux-kernel-6.14
  (package
   (inherit (customize-linux
             #:linux linux-6.14
             #:defconfig (local-file "aux-files/kernel-intel-lunar-lake-defconfig-6.14")))
   (name "custom-linux-kernel-6.14")))

;; As of 2025-04-03, nonguix linux-firmware package doesn't have the BT drivers included
;; so we are using a more recent commit to make BT work
(define-public custom-linux-firmware
  (package
    (inherit linux-firmware)
    (name "custom-linux-firmware")
    (version "d864697fd38a94092b636c8030843343f265fe69")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "026bdiwz05x4330w21wgza3bqsd4sr8b3jgnv4kqary9pzgnn0cm"))))))

;; Latest sof-firmware to ensure with have something up to date with our Lunar Lake platform
(define-public custom-sof-firmware
  (package
   (inherit sof-firmware)
   (name "custom-sof-firmware")
   (version "2025.01.1")
   (source
    (origin
     (method url-fetch)
     (uri (string-append "https://github.com/thesofproject/sof-bin/releases/download/v"
                         version "/sof-bin-" version ".tar.gz"))
     (sha256
      (base32
       "08w3z183cva8bg2yynljrxl2j4nl3xyv5mkljq6ips25qbci0qm3"))))
    (arguments
     `(#:install-plan
       '(("sof" "lib/firmware/intel/sof")
         ("sof-ace-tplg" "lib/firmware/intel/sof-ace-tplg")
         ("sof-ipc4" "lib/firmware/intel/sof-ipc4")
         ("sof-ipc4-tplg" "lib/firmware/intel/sof-ipc4-tplg")
         ("sof-tplg" "lib/firmware/intel/sof-tplg")
         ("sof-ipc4-lib" "lib/firmware/intel/sof-ipc4-lib"))))))

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
