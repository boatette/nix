{ pkgs, flakeDir }:

let
    inherit (pkgs) writeShellApplication;
in
[
    (writeShellApplication {
        name = "backup";
        text = ''
            cp -- "$1" "$1.bak"
        '';
    })

    (writeShellApplication {
        name = "copy";
        meta.description = "cp, recursing automatically when the source is a directory";
        text = ''
            if [ "$#" -eq 2 ] && [ -d "$1" ]; then
                cp -r "''${1%/}" "$2"
            else
                cp "$@"
            fi
        '';
    })

    (writeShellApplication {
        name = "extract";
        meta.description = "unpack an archive by extension";
        runtimeInputs = with pkgs; [
            gnutar
            gzip
            bzip2
            xz
            zstd
            unzip
            p7zip
        ];
        text = ''
            file="$1"

            if [ ! -f "$file" ]; then
                echo "'$file' is not a valid file" >&2
                exit 1
            fi

            case "$file" in
                *.tar.bz2 | *.tbz2) tar xjf "$file" ;;
                *.tar.gz | *.tgz)   tar xzf "$file" ;;
                *.tar.xz)           tar xJf "$file" ;;
                *.tar.zst)          tar --zstd -xf "$file" ;;
                *.tar)              tar xvf "$file" ;;
                *.bz2)              bunzip2 "$file" ;;
                *.gz)               gunzip "$file" ;;
                *.rar)              unrar x "$file" ;;
                *.zip)              unzip "$file" ;;
                *.Z)                uncompress "$file" ;;
                *.7z)               7z x "$file" ;;
                *)
                    echo "'$file' cannot be extracted via extract" >&2
                    exit 1
                    ;;
            esac
        '';
    })

    (writeShellApplication {
        name = "nsh";
        meta.description = "open a shell with packages from nixpkgs";
        text = ''
            args=()
            for p in "$@"; do
                args+=("nixpkgs#$p")
            done
            exec nix shell "''${args[@]}"
        '';
    })

    (writeShellApplication {
        name = "nrun";
        meta.description = "run a package from nixpkgs without installing";
        text = ''
            pkg="$1"
            shift
            exec nix run "nixpkgs#$pkg" -- "$@"
        '';
    })

    (writeShellApplication {
        name = "nfmt";
        meta.description = "nixfmt every nix file in the flake";
        runtimeInputs = with pkgs; [
            fd
            nixfmt
        ];
        text = ''
            fd -e nix . "${flakeDir}" --exclude nix.bak -X nixfmt
        '';
    })

    (writeShellApplication {
        name = "psg";
        meta.description = "grep the process list without matching the grep itself";
        text = ''
            # shellcheck disable=SC2009
            ps aux | grep -v grep | grep -i -- "$@"
        '';
    })

    (writeShellApplication {
        name = "paths";
        meta.description = "print PATH one entry per line";
        text = ''
            printf '%s' "$PATH" | tr ':' '\n'
        '';
    })

    (writeShellApplication {
        name = "serve";
        meta.description = "serve the current dir over http, default port 8000";
        runtimeInputs = [ pkgs.python3 ];
        text = ''
            exec python3 -m http.server "''${1:-8000}"
        '';
    })

    (writeShellApplication {
        name = "unowned";
        meta.description = "find files not owned by the user";
        text = ''
            find "$@" -not -user "$(whoami)"
        '';
    })

    # these two keep their own set -uo pipefail; errexit would break the arithmetic counters in prune-small
    (writeShellApplication {
        name = "open-zellij";
        meta.description = "pick a directory with fzf, then attach or start a zellij session there";
        runtimeInputs = with pkgs; [
            zellij
            zoxide
            fzf
        ];
        bashOptions = [ ];
        text = builtins.readFile ./scripts/open-zellij;
    })

    (writeShellApplication {
        name = "prune-small";
        meta.description = "list or delete wallpapers below a minimum resolution";
        runtimeInputs = with pkgs; [
            imagemagick
            findutils
        ];
        bashOptions = [ ];
        text = builtins.readFile ./scripts/prune-small;
    })
]
