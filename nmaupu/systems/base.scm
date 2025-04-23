(define-module (nmaupu systems base)
  #:use-module (srfi srfi-1)
  #:use-module (gnu)
  #:use-module (gnu system)
  #:use-module (gnu system nss)
  #:use-module (gnu system setuid)
  #:use-module (gnu system privilege)
  #:use-module (gnu services authentication)
  #:use-module (gnu services syncthing)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu packages video)
  #:use-module (nongnu system linux-initrd)
  #:use-module (nmaupu packages 1password)
  #:use-module (nmaupu systems misc polkit)
  #:use-module (nmaupu systems misc pam))

(use-service-modules dns guix admin sysctl pm nix avahi dbus cups desktop linux
                     mcron networking xorg ssh docker audio virtualization sound)

(use-package-modules audio video nfs certs shells ssh linux bash emacs gnome authentication
                     networking wm fonts libusb cups freedesktop file-systems xorg
                     version-control package-management vim pulseaudio freedesktop xdisorg)

(define onepassword-cli-group-name "onepassword-cli")
(define onepassword-gui-group-name "onepassword")

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

   ;; Guix doesn't like when there isn't a file-systems
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
                 (supplementary-groups `("wheel"  ;; sudo
                                         "netdev" ;; network devices
                                         "kvm"
                                         "libvirt"
                                         "tty"
                                         "input"
                                         "docker"
                                         ,onepassword-cli-group-name
                                         ,onepassword-gui-group-name
                                         "realtime" ;; Enable realtime scheduling
                                         "lp"       ;; control bluetooth devices
                                         "audio"    ;; control audio devices
                                         "video"))) ;; control video devices

                %base-user-accounts))

   ;; Add the 'realtime' group
   (groups (cons*
            (user-group (system? #t) (name "realtime"))
            (user-group (name onepassword-cli-group-name) (id 1003))
            (user-group (name onepassword-gui-group-name) (id 1004))
            %base-groups))

   ;; Install bare-minimum system packages
   (packages (cons* alsa-utils
                    alsa-plugins
                    bluez
                    bluez-alsa
                    blueman
                    brightnessctl
                    dconf
                    exfat-utils
                    fuse-exfat
                    fprintd
                    libfprint
                    git
                    gnome-keyring
                    libgnome-keyring
                    gvfs    ;; Enable user mounts
                    intel-media-driver/nonfree
                    intel-microcode
                    libva-utils
                    lvm2
                    ntfs-3g
                    pamtester
                    pulseaudio
                    vim
                    xset
                    xss-lock
                    %base-packages))

   ;; Configure only the services necessary to run the system
   (services (append (modify-services %base-services)
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
                           (service gnome-keyring-service-type)

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

                           (simple-service 'onepassword-setgid-helper privileged-program-service-type
                                           (list (privileged-program
                                                  (program (file-append 1password-cli "/bin/op"))
                                                  (group onepassword-cli-group-name)
                                                  (setgid? #t))
                                                 (privileged-program
                                                  (program (file-append 1password-gui "/bin/1Password-BrowserSupport"))
                                                  (group onepassword-gui-group-name)
                                                  (setgid? #t))))

                           1password-polkit-action-service


                           ;; The global fontconfig cache directory can sometimes contain
                           ;; stale entries, possibly referencing fonts that have been GC'd,
                           ;; so mount it read-only.
                           fontconfig-file-system-service

                           ;; NetworkManager and its applet.
                           (service network-manager-service-type
                                    (network-manager-configuration
                                     (vpn-plugins
                                      (list network-manager-openvpn))))
                           (service wpa-supplicant-service-type)    ;needed by NetworkManager
                           (simple-service 'network-manager-applet
                                           profile-service-type
                                           (list network-manager-applet))
                           (service bluetooth-service-type
                                    (bluetooth-configuration
                                     (auto-enable? #t)))
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

                           ;; (service pulseaudio-service-type)
                           ;; (service alsa-service-type)


                           ;;;;;
                           ;;;;;

                           (service screen-locker-service-type
                                    (screen-locker-configuration (name "xsecurelock")
                                                                 (program (file-append xsecurelock "/bin/xsecurelock"))))

                           (service fprintd-service-type)
                           ;; Added custom pam config and polkit rules
                           ;; Deactivating for now as fprintd is tried first but it's kind of slow with everything
                           ;; for gdm: seems to timeout the password, then try fingerprint -> 10 secs to login
                           ;; for others: fprintd is tried first, if we want to be using the password, we need to fail the fingerprint which is slow
                           ;; + doesn't work with xsecurelock
                           ;; fprintd-pam-service
                           fprintd-polkit-rule-service

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

                           ;; Docker and qemu
                           (service containerd-service-type)
                           (service docker-service-type)
                           (service libvirt-service-type
                                    (libvirt-configuration
                                     (unix-sock-group "libvirt")
                                     (tls-port "16555")))
                           (service virtlog-service-type)


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
                           ;; (udev-rules-service 'pipewire-add-udev-rules pipewire)
                           (udev-rules-service 'brightnessctl-udev-rules brightnessctl)

                           ;; Enable the build service for Nix package manager
                           (service nix-service-type)

                           ;; Syncthing service
                           (service syncthing-service-type
                                    (syncthing-configuration (user "nmaupu")))

                           ;; Schedule cron jobs for system tasks
                           (simple-service 'system-cron-jobs
                                           mcron-service-type
                                           (list
                                            ;; Run `guix gc' 5 minutes after midnight every day.
                                            ;; ;; Clean up generations older than 2 months and free
                                            ;; ;; at least 10G of space.
                                            #~(job "5 0 * * *" "guix gc -d 2m -F 10G"))))))

   ;; Allow resolution of '.local' host names with mDNS
   (name-service-switch %mdns-host-lookup-nss)))
