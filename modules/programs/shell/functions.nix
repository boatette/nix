{
  flake.modules.homeManager.shell =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        gnutar
        gzip
        bzip2
        xz
        zstd
        unzip
        p7zip
      ];

      programs.fish.functions = {
        mkcd = {
          description = "mkdir -p and cd";
          body = ''
            mkdir -p -- $argv[1]; and cd $argv[1]
          '';
        };

        cl = {
          description = "cd and ls";
          body = ''
            cd $argv[1]; and ls
          '';
        };

        backup = {
          description = "copy to .bak";
          body = ''
            cp -- $argv[1] $argv[1].bak
          '';
        };

        copy = {
          description = "cp, -r for directories";
          body = ''
            if test (count $argv) -eq 2; and test -d $argv[1]
                cp -r (string trim --right --chars=/ $argv[1]) $argv[2]
            else
                cp $argv
            end
          '';
        };

        extract = {
          description = "unpack an archive";
          body = ''
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
                case '*.zip'
                    unzip $file
                case '*.Z'
                    uncompress $file
                case '*.rar' '*.7z'
                    7z x $file
                case '*'
                    echo "'$file' cannot be extracted via extract" >&2
                    return 1
            end
          '';
        };

        nsh = {
          description = "shell with nixpkgs packages";
          body = ''
            nix shell (printf 'nixpkgs#%s\n' $argv)
          '';
        };

        nrun = {
          description = "run a nixpkgs package";
          body = ''
            nix run "nixpkgs#$argv[1]" -- $argv[2..]
          '';
        };

        psg = {
          description = "grep the process list";
          body = ''
            ps aux | grep -v grep | grep -i -- $argv
          '';
        };

        paths = {
          description = "print PATH per line";
          body = ''
            printf '%s\n' $PATH
          '';
        };

        serve = {
          description = "http server, default port 8000";
          body = ''
            set -l port 8000
            if test (count $argv) -gt 0
                set port $argv[1]
            end
            python3 -m http.server $port
          '';
        };

        unowned = {
          description = "find files not owned by you";
          body = ''
            find $argv -not -user (whoami)
          '';
        };
      };
    };
}
