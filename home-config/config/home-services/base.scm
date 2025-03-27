(define-module (config home-services base)
  #:use-module (gnu packages))

(define-public base-packages
  (map specification->package
   '("alacritty"
     "curl"
     "firefox"
     "git"
     "htop"
     "jq"
     "make"
     "neovim"
     "python"
     "qutebrowser"
     "ripgrep"
     "tig"
     "ungoogled-chromium"
     "yq")))
