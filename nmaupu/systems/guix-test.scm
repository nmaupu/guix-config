(define-module (nmaupu systems guix-test)
  #:use-module (gnu)
  #:use-module (gnu home)
  #:use-module (gnu packages) ;specification->package procedure
  #:use-module (gnu packages file-systems)
  #:use-module (gnu services)
  #:use-module (gnu system)
  #:use-module (gnu system uuid)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system mapped-devices)
  #:use-module (nongnu packages linux)
  #:use-module (nmaupu systems base)
  #:use-module (nmaupu home-services shells)
  #:use-module (nmaupu home-services base)
  #:use-module (nmaupu home-services tmux)
  #:use-module (nmaupu home-services wm)
  #:use-module (nmaupu home-services guix))

(use-service-modules cups desktop docker virtualization mcron networking ssh xorg)

(define home
 (home-environment
  (services
   (append home-base-services
           home-shells-services
           home-guix-services
           home-xmonad-services
           home-tmux-services))))

(define system
 (operating-system
  (inherit base-operating-system)
  (host-name "guix-test")

  (keyboard-layout (keyboard-layout "us" "altgr-intl"))

  (bootloader (bootloader-configuration
               (bootloader grub-bootloader)
               (targets (list "/dev/sda"))
               (keyboard-layout keyboard-layout)))

  (services
   (append (list (service xfce-desktop-service-type)
                 ;; To configure OpenSSH, pass an 'openssh-configuration'
                 ;; record as a second argument to 'service' below.
                 (service openssh-service-type)
                 (service cups-service-type)
                 (set-xorg-configuration
                  (xorg-configuration (keyboard-layout keyboard-layout)))

                 ;; Docker
                 (service containerd-service-type)
                 (service docker-service-type)
                 (service libvirt-service-type
                          (libvirt-configuration
                           (unix-sock-group "libvirt")
                           (tls-port "16555")))

               ;; Schedule cron jobs for system tasks
               (simple-service 'system-cron-jobs
                               mcron-service-type
                               (list
                                ;; Run `guix gc' 5 minutes after midnight every day.
                                ;; Clean up generations older than 2 months and free
                                ;; at least 10G of space.
                                #~(job "5 0 * * *" "guix gc -d 2m -F 10G"))))

           ;; This is the default list of services we
           ;; are appending to.
           %desktop-services))

  (swap-devices (list (swap-space
                       (target (uuid "fc69de37-2cab-49e0-8068-e65a95b2146e")))))

  ;; The list of file systems that get "mounted".  The unique
  ;; file system identifiers there ("UUIDs") can be obtained
  ;; by running 'blkid' in a terminal.
  (file-systems
   (cons* (file-system
           (mount-point "/")
           (device (uuid "71ea5623-9d4c-49a3-8127-f99ca335ef49"
                         'ext4))
           (type "ext4"))
          %base-file-systems))))

;; Return home or system config based on environment variable
(if (getenv "RUNNING_GUIX_HOME") home system)
