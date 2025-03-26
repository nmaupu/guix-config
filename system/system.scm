;; This is an operating system configuration generated
;; by the graphical installer.
;;
;; Once installation is complete, you can learn and modify
;; this file to tweak the system configuration, and pass it
;; to the 'guix system reconfigure' command to effect your
;; changes.


;; Indicate which modules to import to access the variables
;; used in this configuration.
(use-modules (gnu) (nongnu packages linux))
(use-modules (gnu packages shells))
(use-service-modules cups desktop networking ssh xorg)

(operating-system
  (kernel linux)
  (firmware (list linux-firmware))
  (locale "en_US.utf8")
  (timezone "Europe/Paris")
  (keyboard-layout (keyboard-layout "us" "altgr-intl"))
  (host-name "guix-test")

  ;; The list of user accounts ('root' is implicit).
  (users (cons* (user-account
                  (name "nmaupu")
                  (comment "Nicolas M.")
                  (group "users")
                  (home-directory "/home/nmaupu")
                  (shell (file-append zsh "/bin/zsh"))
                  (supplementary-groups '("wheel" "netdev" "audio" "video")))
                %base-user-accounts))

  ;; Packages installed system-wide.  Users can also install packages
  ;; under their own account: use 'guix search KEYWORD' to search
  ;; for packages and 'guix install PACKAGE' to install a package.
  (packages (append (list (specification->package "emacs")
                          (specification->package "emacs-exwm")
                          (specification->package "ghc")
                          (specification->package "ghc-xmonad-contrib")
                          (specification->package "xmonad")
                          (specification->package "libxft")
                          (specification->package "emacs-desktop-environment")) %base-packages))

  ;; Below is the list of system services.  To search for available
  ;; services, run 'guix system search KEYWORD' in a terminal.
  (services
    (append
     (list
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
      (service xfce-desktop-service-type)
      ;; To configure OpenSSH, pass an 'openssh-configuration'
      ;; record as a second argument to 'service' below.
      (service openssh-service-type)
      (service cups-service-type)
      (set-xorg-configuration
       (xorg-configuration (keyboard-layout keyboard-layout))))
      ;; This is the default list of services we
      ;; are appending to.
      %desktop-services))
  (bootloader (bootloader-configuration
                (bootloader grub-bootloader)
                (targets (list "/dev/sda"))
                (keyboard-layout keyboard-layout)))
  (swap-devices (list (swap-space
                        (target (uuid
                                 "fc69de37-2cab-49e0-8068-e65a95b2146e")))))

  ;; The list of file systems that get "mounted".  The unique
  ;; file system identifiers there ("UUIDs") can be obtained
  ;; by running 'blkid' in a terminal.
  (file-systems (cons* (file-system
                         (mount-point "/")
                         (device (uuid
                                  "71ea5623-9d4c-49a3-8127-f99ca335ef49"
                                  'ext4))
                         (type "ext4")) %base-file-systems)))
