if status is-interactive
    set -g fish_greeting ""

    set -g fish_key_bindings fish_vi_key_bindings

    set -g fish_escape_delay_ms 10

    if test -f $HOME/.fish_profile
        source $HOME/.fish_profile
    end

    starship init fish | source
    zoxide init fish --cmd cd | source

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
end

function fish_user_key_bindings -d 'emacs-style rescues on top of vi mode'
    for mode in insert default
        bind -M $mode ctrl-a beginning-of-line
        bind -M $mode ctrl-e end-of-line
        bind -M $mode ctrl-r history-pager
    end

    bind -M insert ctrl-w backward-kill-word
    bind -M insert ctrl-u backward-kill-line
    bind -M insert ctrl-f accept-autosuggestion

    # !! and !$ history expansion
    bind -M insert ! __history_previous_command
    bind -M insert '$' __history_previous_command_arguments
end

function fish_mode_prompt -d 'always block cursor, no per-mode indicator'
    # deliberately empty -- starship owns the whole prompt
end

function __history_previous_command -d 'expand ! to the previous command'
    switch (commandline -t)
        case "!"
            commandline -t $history[1]
            commandline -f repaint
        case "*"
            commandline -i !
    end
end

function __history_previous_command_arguments -d 'expand !$ to the last argument'
    switch (commandline -t)
        case "!"
            commandline -t ""
            commandline -f history-token-search-backward
        case "*"
            commandline -i '$'
    end
end

function history -d 'history with timestamps'
    builtin history --show-time='%F %T ' $argv
end

function backup -d 'copy <file> to <file>.bak'
    cp -- $argv[1] $argv[1].bak
end

function copy -d 'cp, recursing automatically when the source is a directory'
    if test (count $argv) -eq 2; and test -d $argv[1]
        command cp -r (string trim -r -c '/' $argv[1]) $argv[2]
    else
        command cp $argv
    end
end

function mkcd -d 'mkdir -p, then cd into it'
    mkdir -p -- $argv[1]; and cd $argv[1]
end

function extract -d 'unpack an archive by extension'
    set -l file $argv[1]

    if not test -f "$file"
        echo "'$file' is not a valid file" >&2
        return 1
    end

    switch $file
        case '*.tar.bz2' '*.tbz2'
            tar xjf $file
        case '*.tar.gz' '*.tgz'
            tar xzf $file
        case '*.tar.xz'
            tar xJf $file
        case '*.tar.zst'
            tar --zstd -xf $file
        case '*.tar'
            tar xvf $file
        case '*.bz2'
            bunzip2 $file
        case '*.gz'
            gunzip $file
        case '*.rar'
            unrar x $file
        case '*.zip'
            unzip $file
        case '*.Z'
            uncompress $file
        case '*.7z'
            7z x $file
        case '*'
            echo "'$file' cannot be extracted via extract" >&2
            return 1
    end
end

function zellij-clear-all-sessions -d 'kill and delete every zellij session'
    zellij kill-all-sessions
    zellij delete-all-sessions
end

function nsh -d 'open a shell with packages from nixpkgs'
    nix shell nixpkgs#$argv
end

function nrun -d 'run a package from nixpkgs without installing'
    nix run nixpkgs#$argv[1] -- $argv[2..]
end

function nfmt -d 'nixfmt every nix file in the flake'
    # --indent 4 matches the repo style; conform.nvim passes the same.
    # nix.bak is a separate checkout and is not ours to reformat.
    nixfmt --indent 4 (fd -e nix . ~/nix --exclude nix.bak)
end

function psg -d 'grep the process list without matching the grep itself'
    ps aux | grep -v grep | grep -i -- $argv
end

function paths -d 'print PATH one entry per line'
    # named "paths", not "path" -- fish 3.2+ ships a `path` builtin
    printf '%s\n' $PATH
end

function serve -d 'serve the current dir over http, default port 8000'
    set -l port 8000
    test (count $argv) -gt 0; and set port $argv[1]
    python3 -m http.server $port
end
