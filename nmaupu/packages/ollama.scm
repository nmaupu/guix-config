(define-module (nmaupu packages ollama)
  #:use-module (nonguix build-system binary)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages vulkan))

;; Upstream ships a prebuilt, dynamically linked binary plus its llama.cpp
;; runtime libraries in lib/ollama.  Ollama finds that directory relative to
;; the executable (../lib/ollama), so no wrapper is needed for it.
;;
;; The tarball also bundles CUDA backends (~2 GB) which are useless on a
;; machine without an NVIDIA GPU, so they are dropped.  The Vulkan backend is
;; kept and Mesa's Intel driver is pointed to via VK_DRIVER_FILES.
;;
;; Ollama ignores integrated GPUs by default; set OLLAMA_IGPU_ENABLE=1 to use
;; the Intel Arc (Lunar Lake) through Vulkan.  Measured with qwen2.5:0.5b on
;; the laptop, the CPU was actually faster (54 vs 41 tok/s generation, 132 vs
;; 19 tok/s prompt eval), so the default is left as is.
(define-public ollama
  (package
    (name "ollama")
    (version "0.34.3-rc1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/ollama/ollama/releases/download/v"
                           version "/ollama-linux-amd64.tar.zst"))
       (sha256
        (base32 "0977b6qpc3k3ir4h84nl1a7dxp9hk5dhyiifyx7zcrwhh2i8pzky"))))
    (build-system binary-build-system)
    (arguments
     (list #:substitutable? #f
           ;; Executables: set the ELF interpreter and RUNPATH.  The two
           ;; llama.cpp helpers also need their sibling libraries.
           #:patchelf-plan
           #~'(("bin/ollama" ("libc" "gcc"))
               ("lib/ollama/llama-server" ("libc" "gcc" ("out" "/lib/ollama")))
               ("lib/ollama/llama-quantize" ("libc" "gcc" ("out" "/lib/ollama"))))
           #:install-plan
           #~'(("bin" "bin")
               ("lib" "lib"))
           #:phases
           #~(modify-phases %standard-phases
               ;; The tarball has bin/ and lib/ at its top level (no
               ;; versioned directory), so the default unpack phase would
               ;; chdir into bin/.  Unpack into a fresh directory instead.
               (replace 'unpack
                 (lambda* (#:key source #:allow-other-keys)
                   (mkdir "source")
                   (chdir "source")
                   (invoke "tar" "--zstd" "-xf" source)))
               (add-after 'unpack 'remove-cuda-backends
                 (lambda _
                   (for-each (lambda (dir)
                               (when (file-exists? dir)
                                 (delete-file-recursively dir)))
                             '("lib/ollama/cuda_v12"
                               "lib/ollama/cuda_v13"))))
               ;; Upstream libraries only carry $ORIGIN in their RUNPATH.
               ;; Keep it (they depend on each other) and add the Guix
               ;; locations of glibc, libstdc++ and the Vulkan loader.
               (add-after 'patchelf 'patchelf-libraries
                 (lambda* (#:key inputs #:allow-other-keys)
                   (let ((rpath (string-join
                                 (list "$ORIGIN"
                                       (string-append #$output "/lib/ollama")
                                       (string-append (assoc-ref inputs "libc") "/lib")
                                       (string-append (assoc-ref inputs "gcc") "/lib")
                                       (string-append (assoc-ref inputs "vulkan-loader") "/lib"))
                                 ":")))
                     (for-each (lambda (lib)
                                 (invoke "patchelf" "--set-rpath" rpath lib))
                               (find-files "lib/ollama" "\\.so")))))
               (add-after 'install 'wrap-vulkan-driver
                 (lambda _
                   (wrap-program (string-append #$output "/bin/ollama")
                     `("VK_DRIVER_FILES" ":" prefix
                       (,(string-append #$(this-package-input "mesa")
                                        "/share/vulkan/icd.d/intel_icd.x86_64.json")))))))))
    (native-inputs (list zstd))
    (inputs (list bash-minimal
                  `(,gcc "lib")
                  mesa
                  vulkan-loader))
    (home-page "https://ollama.com")
    (synopsis "Run large language models locally")
    (description
     "Ollama downloads, manages and serves large language models on the local
machine, exposing them through a command line interface and an HTTP API.
This package uses the upstream prebuilt Linux release with the CPU and Vulkan
backends.")
    (license license:expat)))
