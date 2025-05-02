(define-module (nmaupu packages custom-telegram)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (gnu packages)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages telegram))

;; From 2025-04-23, pipewire has been updated from 1.2.7 to 1.4.0 which breaks
;; telegram-desktop package...
;; guix commit: 366af125a3672f48b38816f7c0433f62965f8e31
;; We redefine an older pipewire package to build a custom telegram-desktop which compiles.

(define pipewire-for-telegram
  (hidden-package
   (package
     (inherit pipewire)
     (name "pipewire-for-telegram")
     (version "1.2.7")
     (source (origin
             (method git-fetch)
             (uri (git-reference
                     (url "https://gitlab.freedesktop.org/pipewire/pipewire")
                     (commit version)))
             (file-name (git-file-name name version))
             (sha256
             (base32
                 "17a18978100c0dj3w42ybqxjg46cgdmrvij7dlvbwsrq7sgvcpsd")))))))

(define recursively-replace-inputs-for-telegram
  (package-input-rewriting `((,pipewire . ,pipewire-for-telegram))))

(define-public custom-telegram-desktop-fixed
  (package
    (inherit (recursively-replace-inputs-for-telegram telegram-desktop))
    (name "custom-telegram-desktop-fixed")))
