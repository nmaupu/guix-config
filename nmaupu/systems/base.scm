(define-module (nmaupu systems base)
  #:use-module (srfi srfi-1)
  #:use-module (gnu)
  #:use-module (gnu system)
  #:use-module (gnu system nss)
  #:use-module (gnu system setuid)
  #:use-module (gnu system privilege)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu packages video)
  #:use-module (nongnu system linux-initrd))

(use-service-modules dns guix admin sysctl pm nix avahi dbus cups desktop linux
                     mcron networking xorg ssh docker audio virtualization)

(use-package-modules audio video nfs certs shells ssh linux bash emacs gnome
                     networking wm fonts libusb cups freedesktop file-systems
                     version-control package-management vim haskell xorg)

(define-public base-operating-system
  (operating-system
   (host-name "hackstock")
   (timezone "Europe/Paris")
   (locale "en_US.utf8")

   ;; Use non-free Linux and firmware
   (kernel linux)
   (firmware (list linux-firmware))
   (initrd microcode-initrd)

   ;; Additional kernel modules
   ;; (kernel-loadable-modules (list v4l2loopback-linux-module))

   ;; Choose US English keyboard layout.  The "altgr-intl"
   ;; variant provides dead keys for accented characters.
   (keyboard-layout (keyboard-layout "us" "altgr-intl" #:model "thinkpad"))

   ;; Use the UEFI variant of GRUB with the EFI System
   ;; Partition mounted on /boot/efi.
   (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets '("/boot/efi"))
                (keyboard-layout keyboard-layout)))

   ;; Guix doesn't like it when there isn't a file-systems
   ;; entry, so add one that is meant to be overridden
   (file-systems (cons*
                  (file-system
                   (mount-point "/tmp")
                   (device "none")
                   (type "tmpfs")
                   (check? #f))
                  %base-file-systems))

   (users (cons (user-account
                 (name "nmaupu")
                 (comment "Nicolas Maupu")
                 (group "users")
                 (home-directory "/home/nmaupu")
                 (shell (file-append zsh "/bin/zsh"))
                 (supplementary-groups '("wheel"  ;; sudo
                                         "netdev" ;; network devices
                                         "kvm"
                                         "tty"
                                         "input"
                                         "docker"
                                         "realtime" ;; Enable realtime scheduling
                                         "lp"       ;; control bluetooth devices
                                         "audio"    ;; control audio devices
                                         "video"))) ;; control video devices

                %base-user-accounts))

   ;; Add the 'realtime' group
   (groups (cons (user-group (system? #t) (name "realtime"))
                 %base-groups))

   ;; Install bare-minimum system packages
   (packages (cons* bluez
                    bluez-alsa
                    brightnessctl
                    emacs-no-x-toolkit
                    exfat-utils
                    fuse-exfat
                    ghc
                    ghc-xmonad-contrib
                    git
                    gvfs    ;; Enable user mounts
                    intel-media-driver/nonfree
                    libva-utils
                    libxft
                    ntfs-3g
                    vim
                    xmonad
                    %base-packages))

   ;; Configure only the services necessary to run the system
   (services (append
              (modify-services %base-services
               (delete login-service-type)
               (delete mingetty-service-type)
               (delete console-font-service-type))
              (list
               ;; Seat management (can't use seatd because Wireplumber depends on elogind)
               (service elogind-service-type)

               ;; Configure TTYs and graphical greeter
               (service console-font-service-type
                 (map (lambda (tty)
                        ;; Use a larger font for HIDPI screens
                        (cons tty (file-append
                                   font-terminus
                                   "/share/consolefonts/ter-132n")))
                      '("tty1" "tty2" "tty3")))

               (service greetd-service-type
                        (greetd-configuration
                         (greeter-supplementary-groups (list "video" "input"))
                         (terminals
                          (list
                           ;; TTY1 is the graphical login screen
                           (greetd-terminal-configuration
                            (terminal-vt "1")
                            (terminal-switch #t))

                           ;; Set up remaining TTYs for terminal use
                           (greetd-terminal-configuration (terminal-vt "2"))
                           (greetd-terminal-configuration (terminal-vt "3"))))))

               ;; Configure the Guix service and ensure we use Nonguix substitutes
               (simple-service 'add-nonguix-substitutes
                               guix-service-type
                               (guix-extension
                                (substitute-urls
                                 (append (list "https://substitutes.nonguix.org")
                                         %default-substitute-urls))
                                (authorized-keys
                                 (append (list (plain-file "nonguix.pub"
                                                           "(public-key (ecc (curve Ed25519) (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))
                                         %default-authorized-guix-keys))))

               ;; Set up Polkit to allow `wheel' users to run admin tasks
               polkit-wheel-service

               ;; Give certain programs super-user access
               (simple-service 'mount-setuid-helpers
                               privileged-program-service-type
                               (map (lambda (program)
                                      (privileged-program
                                       (program program)
                                       (setuid? #t)))
                                    (list (file-append nfs-utils "/sbin/mount.nfs")
                                          (file-append ntfs-3g "/sbin/mount.ntfs-3g"))))

               ;; Networking services
               (service network-manager-service-type
                        (network-manager-configuration
                         (vpn-plugins
                          (list network-manager-openvpn))))
               (service wpa-supplicant-service-type) ;; Needed by NetworkManager
               (service bluetooth-service-type
                        (bluetooth-configuration
                         (auto-enable? #t)))
               (service usb-modeswitch-service-type)

               ;; Basic desktop system services (copied from %desktop-services)
               (service avahi-service-type)
               (service udisks-service-type)
               (service upower-service-type)
               (service cups-pk-helper-service-type)
               (service geoclue-service-type)
               (service polkit-service-type)
               (service dbus-root-service-type)
               fontconfig-file-system-service ;; Manage the fontconfig cache

               ;; Power and thermal management services
               (service thermald-service-type)
               (service tlp-service-type
                        (tlp-configuration
                         (cpu-boost-on-ac? #t)
                         (wifi-pwr-on-bat? #t)))

               ;; Enable JACK to enter realtime mode
               (service pam-limits-service-type
                        (list
                         (pam-limits-entry "@realtime" 'both 'rtprio 99)
                         (pam-limits-entry "@realtime" 'both 'nice -19)
                         (pam-limits-entry "@realtime" 'both 'memlock 'unlimited)))

               ;; Enable Docker containers and virtual machines
               (service containerd-service-type)
               (service docker-service-type)
               (service libvirt-service-type
                        (libvirt-configuration
                         (unix-sock-group "libvirt")
                         (tls-port "16555")))

               ;; Enable SSH access
               (service openssh-service-type
                        (openssh-configuration
                         (openssh openssh-sans-x)
                         (port-number 22)))

               ;; Enable printing and scanning
               (service sane-service-type)
               (service cups-service-type
                        (cups-configuration
                         (web-interface? #t)
                         (extensions
                          (list cups-filters))))

               ;; Set up the X11 socket directory for XWayland
               (service x11-socket-directory-service-type)

               ;; Sync system clock with time servers
               (service ntp-service-type)

               ;; Add udev rules for MTP (mobile) devices for non-root user access
               (simple-service 'mtp udev-service-type (list libmtp))

               ;; Add udev rules for a few packages
               (udev-rules-service 'pipewire-add-udev-rules pipewire)
               (udev-rules-service 'brightnessctl-udev-rules brightnessctl)

               ;; Enable the build service for Nix package manager
               (service nix-service-type)

               ;; Schedule cron jobs for system tasks
               (simple-service 'system-cron-jobs
                               mcron-service-type
                               (list
                                ;; Run `guix gc' 5 minutes after midnight every day.
                                ;; Clean up generations older than 2 months and free
                                ;; at least 10G of space.
                                #~(job "5 0 * * *" "guix gc -d 2m -F 10G"))))))

   ;; Allow resolution of '.local' host names with mDNS
   (name-service-switch %mdns-host-lookup-nss)))
