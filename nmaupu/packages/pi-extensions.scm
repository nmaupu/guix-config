(define-module (nmaupu packages pi-extensions)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix git-download))

;; Pi itself is installed with npm (~/.npm-global) because packaging its whole
;; node dependency tree for Guix is not worth it.  Only the official example
;; extensions are packaged here and linked into ~/.pi/agent.
;; Keep the version in sync with the installed pi (pi --version) as extensions
;; follow the pi extension API of the same release.
(define-public pi-extensions
  (package
    (name "pi-extensions")
    (version "1.2.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/earendil-works/pi.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0dzaajd4zjszaccim16kmnqks8z6q1ihs47sv6mipkb3bjyljcr2"))))
    (build-system copy-build-system)
    (arguments
     `(#:install-plan
       '(("packages/coding-agent/examples/extensions/plan-mode"
          "share/pi/extensions/plan-mode")
         ("packages/coding-agent/examples/extensions/subagent/index.ts"
          "share/pi/extensions/subagent/")
         ("packages/coding-agent/examples/extensions/subagent/agents.ts"
          "share/pi/extensions/subagent/")
         ("packages/coding-agent/examples/extensions/subagent/agents"
          "share/pi/agents")
         ("packages/coding-agent/examples/extensions/subagent/prompts"
          "share/pi/prompts"))))
    (home-page "https://github.com/earendil-works/pi")
    (synopsis "Plan mode and subagent extensions for the pi coding agent")
    (description "Official example extensions of the pi coding agent: a
read-only plan mode (@code{/plan}) and a subagent tool delegating tasks to
isolated pi processes, along with sample agents and workflow prompts.")
    (license license:expat)))
