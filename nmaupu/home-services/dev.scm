(define-module (nmaupu home-services dev)
  #:use-module (gnu)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services gnupg)
  #:use-module (gnu packages patchutils)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages networking)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (nmaupu packages tfenv)
  #:use-module (nmaupu packages goenv)
  #:use-module (nmaupu packages google-cloud-sdk)
  #:use-module (nmaupu packages talosctl)
  #:use-module (nmaupu packages vault)
  ;; TODO Create a specific home-service for work/pro tools
  #:use-module (nmaupu packages terragrunt)
  #:use-module (nmaupu packages git-secret)
  #:use-module (nmaupu packages skaffold)
  #:use-module (nmaupu packages sops)
  #:use-module (nmaupu packages docker)
  #:use-module (nmaupu packages argocd)
  #:use-module (nmaupu packages argonaut)
  #:use-module (nmaupu packages cursor-ai)
  #:use-module (nmaupu packages postman)
  #:use-module (nmaupu packages kubectl-view-allocations)
  #:use-module (nmaupu packages pi-extensions)
  #:use-module (gnu packages protobuf)
  #:use-module (gnu packages java)
  #:use-module (gnu packages golang-apps)
  #:use-module (gnu packages rust)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages web))

(define (home-dev-profile-service config)
  ;; goenv is linked to ~/.local/goenv
  (list tfenv
        meld
        google-cloud-sdk
        google-cloud-sdk-gke-gcloud-auth-plugin
        google-cloud-sdk-minikube
        talosctl
        vault
        pinentry-rofi
        ;; TODO Create a specific home-service for pro tools
        gnupg
        proxychains-ng
        terragrunt
        git-secret
        skaffold
        sops
        docker-compose
        argocd
        argonaut
        go-jsonnet
        protobuf
        pre-commit
        openjdk
        cursor-ai
        postman
        kubectl-view-allocations
        ;; The profile accepts (package "output") tuples to select a non-default output
        (list rust "cargo")))

(define (with-home p)
  (string-append "$HOME/" p))

(define %tfenv-data-dir ".local/tfenv-data")
(define %goenv-root ".local/goenv")
(define %goenv-data-dir ".local/goenv-data")

(define (home-dev-env-vars config)
  `(("TFENV_CONFIG_DIR" . ,(with-home %tfenv-data-dir)) ; data dir where tf versions are actually downloaded
    ("GOENV_ROOT" . ,(with-home %goenv-data-dir))))
    ;; Added gcc-toolchain to LD_LIBRARY_PATH because for an obscure reason
    ;; go build generates binaries that misses libgcc_s.so.1
    ;; TODO find out why and fix
    ;; Edit @2025-08-26: lots of seg fault because gcc-toolchain is outdated in home so commenting it for now
    ;;("LD_LIBRARY_PATH" . ,(file-append gcc-toolchain "/lib"))))

(define pi-mcp-config
  (local-file "../files/pi/agent/mcp.json"))

;; Anthropic's skills collection (https://github.com/anthropics/skills).  Only
;; selected skills are linked below so the others don't clutter pi's system
;; prompt.  Bump: `git rev-parse HEAD` + `guix hash -rx .` on a fresh clone.
(define anthropic-skills-src
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/anthropics/skills")
          (commit "dbd4588f9e1033efb41dad4bef2f7947c8993d44")))
    (file-name "anthropic-skills-checkout")
    (sha256
     (base32 "1x81ypg4nfacr4ma9vphj890yrnwhhv6i6124npq6y7jgh32lhpr"))))

(define (pi-extensions-files)
  ;; Files are linked one by one so ~/.pi/agent stays writable for pi
  ;; (settings, sessions, auth) and for custom agents/prompts.
  ;; OAuth tokens are intentionally kept out of this declarative config; pi stores
  ;; them separately in ~/.pi/agent/mcp-auth.json after `pi mcp login <server>`.
  (let ((share (lambda (p) (file-append pi-extensions "/share/pi/" p))))
    (append
     `((".local/bin/pi" ,pi-wrapper)
       (".pi/agent/mcp.json" ,pi-mcp-config)
       (".pi/agent/extensions/plan-mode" ,(share "extensions/plan-mode"))
       (".pi/agent/extensions/subagent" ,(share "extensions/subagent"))
       (".pi/agent/skills/frontend-design"
        ,(file-append anthropic-skills-src "/skills/frontend-design")))
     (map (lambda (f)
            (list (string-append ".pi/agent/agents/" f)
                  (share (string-append "agents/" f))))
          '("planner.md" "reviewer.md" "scout.md" "worker.md"))
     (map (lambda (f)
            (list (string-append ".pi/agent/prompts/" f)
                  (share (string-append "prompts/" f))))
          '("implement.md" "implement-and-review.md" "scout-and-plan.md")))))

;; Pi packages (what `pi install <source>` would add).  They are merged into
;; ~/.pi/agent/settings.json, which pi also writes to and therefore cannot be a
;; read-only symlink; pi installs missing packages on next startup.
;; Entries are matched by package identity (npm version / git ref ignored) so
;; bumping a version here replaces the previous one.  Removing an entry does not remove it
;; from settings.json, use `pi remove <source>` for that.
(define %pi-packages
  '("npm:pi-ollama-cloud@0.13.0"
    "npm:@aliou/pi-guardrails@0.19.0"
    "npm:@juicesharp/rpiv-ask-user-question@2.13.8"
    "npm:@juicesharp/rpiv-todo@2.13.8"
    ;; pi-lens needs the gcc libs from pi-wrapper for its native tools
    "npm:pi-lens@4.4.3"
    ;; Agent Skills library; pi auto-discovers its skills/ dir.  Loaded as
    ;; /skill:<name> commands (brainstorming, test-driven-development, ...).
    "git:github.com/obra/superpowers@v7.0.0"))

(define pi-settings-activation
  (with-imported-modules '((guix build utils))
    #~(begin
        (use-modules (guix build utils) (ice-9 popen) (ice-9 textual-ports))
        (let* ((dir (string-append (getenv "HOME") "/.pi/agent"))
               (file (string-append dir "/settings.json"))
               (tmp (string-append file ".guix-tmp"))
               ;; id strips a trailing @version / @ref ("npm:@s/p@1.0" -> "npm:@s/p",
               ;; "git:host/repo@v1" -> "git:host/repo"); ssh sources like
               ;; "git:git@host:repo" are untouched since their '@' is not trailing.
               (filter "def id: (if type == \"string\" then . else .source end)
                          | sub(\"@[^@/:]+$\"; \"\");
                        ($pkgs | map(id)) as $ids
                        | .packages = ([(.packages // [])[]
                                        | select(id as $i | $ids | index($i) | not)]
                                       + $pkgs)"))
          (mkdir-p dir)
          (unless (file-exists? file)
            (call-with-output-file file (lambda (port) (display "{}" port))))
          (let* ((pipe (open-pipe* OPEN_READ #$(file-append jq "/bin/jq")
                                   "--argjson" "pkgs"
                                   #$(string-append
                                      "["
                                      (string-join (map (lambda (p) (string-append "\"" p "\""))
                                                        %pi-packages)
                                                   ",")
                                      "]")
                                   filter file))
                 (json (get-string-all pipe)))
            (unless (zero? (status:exit-val (close-pipe pipe)))
              (error "pi-packages: jq failed on" file))
            (call-with-output-file tmp (lambda (port) (display json port))))
          (rename-file tmp file)))))

;; pi is installed by npm in ~/.npm-global.  This wrapper (first on PATH via
;; ~/.local/bin) gives pi and the tools it spawns the gcc runtime libs:
;; prebuilt binaries pulled by pi packages (e.g. ast-grep for pi-lens) need
;; libgcc_s.so.1.  Scoped to pi as a global LD_LIBRARY_PATH caused segfaults.
(define pi-wrapper
  (computed-file
   "pi"
   #~(begin
       (call-with-output-file #$output
         (lambda (port)
           (format port "#!/bin/sh
export LD_LIBRARY_PATH=\"~a/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}\"
exec \"$HOME/.npm-global/bin/pi\" \"$@\"
" #$gcc-toolchain)))
       (chmod #$output #o555))))

(define home-dev-service-type
  (service-type (name 'dev-tools)
                (description "Dev tools configuration and packages.")
                (extensions
                 (list (service-extension
                        home-environment-variables-service-type
                        home-dev-env-vars)
                       (service-extension
                        home-profile-service-type
                        home-dev-profile-service)))
                (default-value #f)))

(define-public home-dev-services
  (list
   ;; goenv is a piece of crap and needs that the directory with goenv script is named without
   ;; the version in it. Hence, it's not possible to use the directory from /gnu/store directly...
   ;; As a result, we link it to the home directory under GOENV_ROOT
   (simple-service 'link-from-packages
                   home-files-service-type
                   `((,%goenv-root
                      ,(directory-union "goenv" (list goenv)))))
   (simple-service 'pi-extensions
                   home-files-service-type
                   (pi-extensions-files))
   (simple-service 'pi-packages
                   home-activation-service-type
                   pi-settings-activation)
   (service home-gpg-agent-service-type
         (home-gpg-agent-configuration
          (pinentry-program
           (file-append pinentry-rofi "/bin/pinentry"))
          (ssh-support? #t)))
   (service home-dev-service-type)))
