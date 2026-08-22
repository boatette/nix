{
  flake.modules.homeManager.shell =
    { config, ... }:
    let
      inherit (config.constants) flakeDir;
    in
    {
      home.shellAliases = {
        ls = "eza -al --color=always --group-directories-first --icons auto";
        la = "eza -a --color=always --group-directories-first --icons auto";
        ll = "eza -l --color=always --group-directories-first --icons auto";
        lt = "eza -aT --color=always --group-directories-first --icons auto";
        "l." = ''eza -a | grep -e "^\."'';

        tarnow = "tar -acf";
        untar = "tar -zxvf";
        wget = "wget -c";
        psmem = "ps auxf | sort -nr -k 4";
        psmem10 = "ps auxf | sort -nr -k 4 | head -10";

        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";
        "......" = "cd ../../../../..";
        cn = "cd ${flakeDir}";

        nrs = "run0 nixos-rebuild switch --flake ${flakeDir}";
        nrb = "run0 nixos-rebuild boot --flake ${flakeDir}";
        nrt = "run0 nixos-rebuild test --flake ${flakeDir}";
        nrd = "nixos-rebuild dry-build --flake ${flakeDir}";
        ngl = "nixos-rebuild list-generations";
        ngc = "run0 nix-collect-garbage --delete-older-than 7d";
        nfu = ''nix run ~/nix#write-flake && nix flake update --flake ${flakeDir} && git -C ${flakeDir} commit -m "chore: update flake lock" flake.lock'';
        ns = "nix search nixpkgs";
        nb = "nix path-info -rSh /run/current-system | sort -hk2 | tail -30";
        nrepl = "nix repl ${flakeDir}";
        nt = "nix-tree";
        nw = "nix why-depends";

        please = "run0";
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
        oz = "open-zellij";

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
}
