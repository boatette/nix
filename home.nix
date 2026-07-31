{ config, pkgs, inputs, ... }:

{
  home.username = "boatette";
  home.homeDirectory = "/home/boatette";
  
  home.packages = with pkgs; [
   foot
    inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default 
   inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
rustup
  ];

  programs.zsh = {
    enable = true;
        sessionVariables = {
            EDITOR = "nvim";
            SUDO_EDITOR = "nvim";

            MANROFFOPT = "-c";
            MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        };


        shellAliases = {
            ls = "eza -al --color=always --group-directories-first --icons auto";
            la = "eza -a --color=always --group-directories-first --icons auto";
            ll = "eza -l --color=always --group-directories-first --icons auto";
            lt = "eza -aT --color=always --group-directories-first --icons auto";
            "l." = ''eza -a | grep -e "^\."'';

            tarnow = "tar -acf";
            untar = "tar -zxvf";
            pkgwalls = "env XZ_OPT=-9e tar --exclude='.git' --exclude='wallpapers.tar.xz' --exclude='README.md' -cJvf ~/Pictures/Wallpapers/wallpapers.tar.xz -C ~/Pictures/Wallpapers .";
            pushwalls = ''gh release create $(date +%Y.%m.%d) ~/Pictures/Wallpapers/wallpapers.tar.xz --repo boatette/wallpapers --notes "Wallpaper pack $(date +%Y.%m.%d)"'';
            pullwalls = "mkdir -p ~/Pictures/Wallpapers && curl -fL https://github.com/boatette/wallpapers/releases/latest/download/wallpapers.tar.xz | tar --xz -x -C ~/Pictures/Wallpapers";
            wget = "wget -c";
            psmem = "ps auxf | sort -nr -k 4";
            psmem10 = "ps auxf | sort -nr -k 4 | head -10";

            ".." = "cd ..";
            "..." = "cd ../..";
            "...." = "cd ../../..";
            "....." = "cd ../../../..";
            "......" = "cd ../../../../..";

            cn = "cd ~/nix";

            nrs = "sudo nixos-rebuild switch --flake ~/nix#redux";
            nrb = "sudo nixos-rebuild boot --flake ~/nix#redux";
            nrt = "sudo nixos-rebuild test --flake ~/nix#redux";
            nrd = "nixos-rebuild dry-build --flake ~/nix#redux";

            ngl = "nixos-rebuild list-generations";
            ngc = "sudo nix-collect-garbage --delete-older-than 7d";

            nfu = "nix flake update --flake ~/nix";
            ns = "nix search nixpkgs";
            nb = "nix path-info -rSh /run/current-system | sort -hk2 | tail -30";
            nrepl = "nix repl ~/nix";
            nt = "nix-tree";
            nw = "nix why-depends";

            please = "sudo";
            jctl = "journalctl -p 3 -xb";
            ff = "fastfetch";
            q = "exit";
            ZQ = "exit";
            h = "history";
            c = "clear";
            cls = "clear";
            vim = "nvim";
            vi = "nvim";
            v = "nvim";
            cat = "bat";
            lg = "lazygit";
            z = "zellij";
            oz = "open_zellij";

            gs = "git status";
            ga = "git add";
            gaa = "git add -A";
            gc = "git commit";
            gcm = "git commit -m";
            gca = "git commit --amend --no-edit";
            gcl = "git clone";
            gl = "git log --oneline";
            glg = "git log --oneline --graph --decorate --all";
            gd = "git diff";
            gds = "git diff --staged";
            gb = "git branch";
            gsw = "git switch";
            gswc = "git switch -c";
            gf = "git fetch --all --prune";
            gpush = "git push";
            gpull = "git pull";
            gst = "git stash";
            gstp = "git stash pop";
            gundo = "git reset --soft HEAD~1";

            wifi = "nmtui";
            shutdown = "systemctl poweroff";
            reboot = "systemctl reboot";
            du = "dust";
            ports = "ss -tulpn";
            myip = "curl -s ifconfig.me";
            temps = "sensors";
            topcpu = "ps auxf | sort -nr -k 3 | head -10";

            baknow = "systemctl --user start ssd-backup.service";
            bakstatus = "systemctl --user list-timers ssd-backup.timer";
            baklog = "journalctl --user -u ssd-backup -n 50 --no-pager";

            dc = "cd";
            cealr = "clear";
            celar = "clear";
        };
    };

  home.stateVersion = "26.05";
}

