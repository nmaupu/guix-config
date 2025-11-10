(define-module (nmaupu packages custom-telegram)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages telegram))

;; As of 2025-11-03 this is not being used anymore
;; remains here for reference

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
    (name "custom-telegram-desktop-fixed")
    (version "5.12.3")
    (source
     (origin
       (method git-fetch)
       (uri
        (git-reference
         (url "https://github.com/telegramdesktop/tdesktop.git")
         (commit
          (string-append "v" version))))
       (file-name
        (git-file-name name version))
       (sha256
        (base32 "16dfk36xfsizrxmxcid9kwj2dvxfp42382hqcan9rsrgjlqm6ymy"))
       (patches
        (search-patches
         ;; https://github.com/telegramdesktop/tdesktop/pull/24126
         "telegram-desktop-allow-disable-libtgvoip.patch"
         ;; Make it compatible with GCC 11.
         "telegram-desktop-qguiapp.patch"
         "telegram-desktop-hashmap-incomplete-value.patch"))
       (modules '((guix build utils)
                  (ice-9 ftw)
                  (srfi srfi-1)))
       (snippet
        #~(begin
            (let ((keep
                   '(;; Not available in Guix.
                     "tgcalls" "cld3")))
              (with-directory-excursion "Telegram/ThirdParty"
                (for-each delete-file-recursively
                          (lset-difference string=?
                                           (scandir ".")
                                           (cons* "." ".." keep)))))))))
    (arguments
     (substitute-keyword-arguments
       (package-arguments (recursively-replace-inputs-for-telegram telegram-desktop))
       ((#:phases phases)
        #~(modify-phases #$phases
            (add-after 'unpack-additional-sources 'apply-custom-qt-patch
              (lambda _
                ;; Apply patch after lib_base is copied into place
                (with-directory-excursion "Telegram/lib_base"
                  (invoke "patch" "-p0" "-i"
                          #$(local-file "./patches/telegram-desktop-fix-qt-version-check.patch")))))))))))
