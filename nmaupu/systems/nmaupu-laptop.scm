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
  #:use-module (nmaupu home-services kubernetes)
  #:use-module (nmaupu systems custom-sof-firmware)
  #:use-module (nmaupu systems custom-linux-firmware))

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
           home-dev-services
           home-kubernetes-services))))

(define %luks-root-partition-uuid "1bddce67-af38-4486-9573-acf1bba9805d")

(define system
 (operating-system
  (inherit base-operating-system)
  (kernel linux)
  (firmware (list custom-linux-firmware custom-sof-firmware))
  (initrd microcode-initrd)
  (host-name "nmaupu-laptop")

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
                                            (needed-for-boot? (cdr (cdr (cdr item))))
                                            (type (car (cdr (cdr (cdr item)))))
                                            (dependencies mapped-devices)))
                             '(("/"               "/dev/mapper/sys-root"     #t "ext4")
                               ("/gnu/store"      "/dev/mapper/sys-gnustore" #t "ext4")
                               ("/home"           "/dev/mapper/sys-home"     #f "xfs")
                               ("/var/lib/docker" "/dev/mapper/sys-docker"   #f "xfs")
                               ("/var/log"        "/dev/mapper/sys-log"      #f "xfs")))
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
