status is-interactive; or exit

# ls replacements
alias ls 'eza -al --color=always --group-directories-first --icons auto'
alias la 'eza -a --color=always --group-directories-first --icons auto'
alias ll 'eza -l --color=always --group-directories-first --icons auto'
alias lt 'eza -aT --color=always --group-directories-first --icons auto'
alias l. 'eza -a | grep -e "^\."'

# System helpers
alias tarnow 'tar -acf'
alias untar 'tar -zxvf'
alias pkgwalls "env XZ_OPT=-9e tar --exclude='.git' --exclude='wallpapers.tar.xz' --exclude='README.md' -cJvf ~/Pictures/Wallpapers/wallpapers.tar.xz -C ~/Pictures/Wallpapers ."
alias pushwalls 'gh release create (date +%Y.%m.%d) ~/Pictures/Wallpapers/wallpapers.tar.xz --repo boatette/wallpapers --notes "Wallpaper pack "(date +%Y.%m.%d)'
alias pullwalls 'mkdir -p ~/Pictures/Wallpapers && curl -fL https://github.com/boatette/wallpapers/releases/latest/download/wallpapers.tar.xz | tar --xz -x -C ~/Pictures/Wallpapers'
alias wget 'wget -c'
alias psmem 'ps auxf | sort -nr -k 4'
alias psmem10 'ps auxf | sort -nr -k 4 | head -10'

# Navigation
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'
alias ...... 'cd ../../../../..'

alias cn 'cd ~/nix'

# Nix helpers
alias nrs 'sudo nixos-rebuild switch --flake ~/nix#redux'
alias nrb 'sudo nixos-rebuild boot --flake ~/nix#redux'
alias nrt 'sudo nixos-rebuild test --flake ~/nix#redux'
alias nrd 'nixos-rebuild dry-build --flake ~/nix#redux'

alias ngl 'nixos-rebuild list-generations'
alias ngc 'sudo nix-collect-garbage --delete-older-than 7d'

alias nfu 'nix flake update --flake ~/nix'
alias ns 'nix search nixpkgs'
alias nb 'nix path-info -rSh /run/current-system | sort -hk2 | tail -30'
alias nrepl 'nix repl ~/nix'
alias nt 'nix-tree'
alias nw 'nix why-depends'

# Shortcuts
alias please 'sudo'
alias jctl 'journalctl -p 3 -xb'
alias ff 'fastfetch'
alias q 'exit'
alias ZQ 'exit'
alias h 'history'
alias c 'clear'
alias cls 'clear'
alias vim 'nvim'
alias vi 'nvim'
alias v 'nvim'
alias cat 'bat'
alias lg 'lazygit'
alias z 'zellij'
alias oz 'open_zellij'

# Git shortcuts
alias gs 'git status'
alias ga 'git add'
alias gaa 'git add -A'
alias gc 'git commit'
alias gcm 'git commit -m'
alias gca 'git commit --amend --no-edit'
alias gcl 'git clone'
alias gl 'git log --oneline'
alias glg 'git log --oneline --graph --decorate --all'
alias gd 'git diff'
alias gds 'git diff --staged'
alias gb 'git branch'
alias gsw 'git switch'
alias gswc 'git switch -c'
alias gf 'git fetch --all --prune'
alias gpush 'git push'
alias gpull 'git pull'
alias gst 'git stash'
alias gstp 'git stash pop'
alias gundo 'git reset --soft HEAD~1'

# System control
alias wifi 'nmtui'
alias shutdown 'systemctl poweroff'
alias reboot 'systemctl reboot'
alias du 'dust'
alias ports 'ss -tulpn'
alias myip 'curl -s ifconfig.me'
alias temps 'sensors'
alias topcpu 'ps auxf | sort -nr -k 3 | head -10'

# SSD backup
alias baknow 'systemctl --user start ssd-backup.service'
alias bakstatus 'systemctl --user list-timers ssd-backup.timer'
alias baklog 'journalctl --user -u ssd-backup -n 50 --no-pager'

# Spelling
alias dc 'cd'
alias cealr 'clear'
alias celar 'clear'
