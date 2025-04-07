(define-module (nmaupu systems nmaupu-laptop)
  #:use-module (srfi srfi-1)
  #:use-module (gnu)
  #:use-module (gnu home)
  #:use-module (gnu packages) ;specification->package procedure
  #:use-module (gnu packages file-systems)
  #:use-module (gnu services)
  #:use-module (gnu system)
  #:use-module (gnu system nss)
  #:use-module (gnu system uuid)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system setuid)
  #:use-module (gnu system privilege)
  #:use-module (gnu system mapped-devices)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu packages video)
  #:use-module (nongnu system linux-initrd)
  #:use-module (nmaupu systems base)
  #:use-module (nmaupu home-services base)
  #:use-module (nmaupu home-services git)
  #:use-module (nmaupu home-services shells)
  #:use-module (nmaupu home-services tmux)
  #:use-module (nmaupu home-services wm)
  #:use-module (nmaupu home-services guix)
  #:use-module (nmaupu home-services emacs)
  #:use-module (nmaupu home-services emacs)
  #:use-module (nmaupu home-services shepherd-services)
  #:use-module (nmaupu home-services dev)
  #:use-module (nmaupu systems custom-sof-firmware)
  #:use-module (nmaupu systems custom-linux-firmware))

(use-service-modules dbus dns guix admin sysctl pm nix cups desktop linux avahi sddm sound
                     mcron networking xorg ssh docker audio virtualization authentication)

(use-package-modules audio video nfs certs shells ssh linux bash emacs gnome avahi
                     networking wm fonts libusb cups freedesktop file-systems xdisorg
                     version-control package-management vim pulseaudio)

(define home
 (home-environment
  (services
   (append home-base-services
           home-git-services
           home-shells-services
           home-guix-services
           home-xmonad-services
           home-tmux-services
           home-emacs-services
           home-shepherd-services
           home-dev-services))))

(define %luks-root-partition-uuid "1bddce67-af38-4486-9573-acf1bba9805d")

(define system
 (operating-system
  (inherit base-operating-system)
  (kernel linux)
  (firmware (list custom-linux-firmware custom-sof-firmware))
  (initrd microcode-initrd)
  (host-name "nmaupu-laptop")

  ;; Redefining here as inherited doesn't seem to be picked off
  (keyboard-layout (keyboard-layout "us" "altgr-intl" #:model "thinkpad"))

  (services
   (append (modify-services %base-services)
           (list (simple-service 'add-nonguix-substitutes
                                 guix-service-type
                                 (guix-extension
                                  (substitute-urls
                                   (append (list "https://substitutes.nonguix.org")
                                           %default-substitute-urls))
                                  (authorized-keys
                                   (append (list (plain-file "nonguix.pub"
                                                             "(public-key (ecc (curve Ed25519) (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))
                                           %default-authorized-guix-keys))))

                 (service gdm-service-type)

                 ;; Add udev rules for MTP devices so that non-root users can access
                 ;; them.
                 (simple-service 'mtp udev-service-type (list libmtp))

                 ;; Add udev rules for scanners.
                 (service sane-service-type)

                 (service cups-service-type
                          (cups-configuration
                           (web-interface? #t)
                           (extensions
                            (list cups-filters))))

                 ;; Add polkit rules, so that non-root users in the wheel group can
                 ;; perform administrative tasks (similar to "sudo").
                 polkit-wheel-service

                 ;; Allow desktop users to also mount NTFS and NFS file systems
                 ;; without root.
                 (simple-service 'mount-setuid-helpers privileged-program-service-type
                                 (map file-like->setuid-program
                                      (list (file-append nfs-utils "/sbin/mount.nfs")
                                            (file-append ntfs-3g "/sbin/mount.ntfs-3g")
                                            (file-append xsecurelock "/libexec/xsecurelock/authproto_pam"))))

                 ;; This is a volatile read-write file system mounted at /var/lib/gdm,
                 ;; to avoid GDM stale cache and permission issues.
                 gdm-file-system-service

                 ;; The global fontconfig cache directory can sometimes contain
                 ;; stale entries, possibly referencing fonts that have been GC'd,
                 ;; so mount it read-only.
                 fontconfig-file-system-service

                 ;; NetworkManager and its applet.
                 (service network-manager-service-type)
                 (service wpa-supplicant-service-type)    ;needed by NetworkManager
                 (simple-service 'network-manager-applet
                                 profile-service-type
                                 (list network-manager-applet))
                 (service modem-manager-service-type)
                 (service usb-modeswitch-service-type)

                 ;; The D-Bus clique.
                 (service avahi-service-type)
                 (service udisks-service-type)
                 (service upower-service-type)
                 (service accountsservice-service-type)
                 (service cups-pk-helper-service-type)
                 (service colord-service-type)
                 (service geoclue-service-type)
                 (service polkit-service-type)
                 (service elogind-service-type)
                 (service dbus-root-service-type)

                 (service ntp-service-type)

                 (service x11-socket-directory-service-type)

                 (service pulseaudio-service-type)
                 (service alsa-service-type)

                 ;;;;;
                 ;;;;;

                 ;; (service fprintd-service-type)

                 (service screen-locker-service-type
                          (screen-locker-configuration (name "xsecurelock")
                                                       (program (file-append xsecurelock "/bin/xsecurelock"))))

                 (set-xorg-configuration
                  (xorg-configuration (keyboard-layout keyboard-layout)
                                      (extra-config '("Section \"InputClass\""
                                                      "  Identifier \"libinput touchpad catchall\""
                                                      "  MatchIsTouchpad \"on\""
                                                      "  MatchDevicePath \"/dev/input/event*\""
                                                      "  Driver \"libinput\""
                                                      "  Option \"Tapping\" \"on\""
                                                      "EndSection" ))))

                 (service openssh-service-type)

                 ;; Docker
                 (service containerd-service-type)
                 (service docker-service-type)
                 (service libvirt-service-type
                          (libvirt-configuration
                           (unix-sock-group "libvirt")
                           (tls-port "16555")))

                 (service bluetooth-service-type
                          (bluetooth-configuration
                           (auto-enable? #t)))

                 (simple-service 'dbus-extras
                                 dbus-root-service-type
                                 (list blueman))

                 ;; Power and thermal management services
                 (service thermald-service-type)
                 (service tlp-service-type
                          (tlp-configuration
                           (cpu-boost-on-ac? #t)
                           (wifi-pwr-on-bat? #t)))

                 ;; Add udev rules for a few packages
                 ;;(udev-rules-service 'pipewire-add-udev-rules pipewire)
                 (udev-rules-service 'brightnessctl-udev-rules brightnessctl)

                 ;; Enable the build service for Nix package manager
                 (service nix-service-type)

                 ;; Schedule cron jobs for system tasks
                 (simple-service 'system-cron-jobs
                                 mcron-service-type
                                 (list
                                  ;; Run `guix gc' 5 minutes after midnight every day.
                                  ;; ;; Clean up generations older than 2 months and free
                                  ;; ;; at least 10G of space.
                                  #~(job "5 0 * * *" "guix gc -d 2m -F 10G"))))))

  ;; Creating a mapped luks device for all the LVM partitions
  (mapped-devices (list
                   (mapped-device (source (uuid %luks-root-partition-uuid))
                                  (target "crypt-root")
                                  (type luks-device-mapping))
                   (mapped-device (source "sys")
                                  (targets (list "sys-swap"
                                                 "sys-root"
                                                 "sys-docker"
                                                 "sys-gnustore"
                                                 "sys-home"
                                                 "sys-log"))
                                  (type lvm-device-mapping))))

  ;; The list of file systems that get "mounted".
  (file-systems (append (map (lambda (item)
                               (file-system (device (car (cdr item)))
                                            (mount-point (car item))
                                            (type "xfs")
                                            (needed-for-boot? (cdr (cdr item)))
                                            (dependencies mapped-devices)))
                             '(("/"               "/dev/mapper/sys-root"     #t)
                               ("/gnu/store"      "/dev/mapper/sys-gnustore" #t)
                               ("/home"           "/dev/mapper/sys-home"     #f)
                               ("/var/lib/docker" "/dev/mapper/sys-docker"   #f)
                               ("/var/log"        "/dev/mapper/sys-log"      #f)))
                        (list (file-system (mount-point "/boot/efi")
                                           (device "/dev/nvme0n1p1")
                                           (type "vfat")))
                        %base-file-systems))

  ;; Swap file over encrypted LVM
  (swap-devices (list (swap-space
                       (target "/dev/mapper/sys-swap")
                       (dependencies mapped-devices))))))

;; Return home or system config based on environment variable
(if (getenv "RUNNING_GUIX_HOME") home system)
