{
  flake.modules.homeManager.zsh =
    { config, ... }:
    let
      inherit (config.constants) flakeDir;
    in
    {
      programs.zsh.initContent = ''
        mkcd() { mkdir -p -- "$1" && cd "$1"; }

        nsh() { nix shell "''${@/#/nixpkgs#}"; }

        nrun() { local pkg="$1"; shift; nix run "nixpkgs#$pkg" -- "$@"; }

        npadd() { nix profile add "''${@/#/nixpkgs#}"; }

        npup() { nix profile upgrade "''${@:---all}"; }

        nprm() {
          local picked

          (( $# )) && { nix profile remove "$@"; return; }

          picked=$(nix profile list --json |
            jq -r '.elements | keys[]' |
            fzf --multi --prompt 'remove > ') || return

          [[ -n $picked ]] && nix profile remove ''${(f)picked}
        }

        ngd() {
          local -a gens=(/nix/var/nix/profiles/system-*-link(nN))

          (( $# == 2 )) && gens=(/nix/var/nix/profiles/system-$1-link /nix/var/nix/profiles/system-$2-link)

          (( ''${#gens} >= 2 )) || { print -u2 'need two generations to diff'; return 1; }

          nix store diff-closures "''${gens[-2]}" "''${gens[-1]}"
        }

        nwhich() {
          local bin=''${commands[$1]}

          [[ -n $bin ]] || { print -u2 "$1: not an external command"; return 1; }

          readlink -f -- "$bin"
        }

        unowned() { find "$@" -not -user "$USER"; }

        dotfiles() {
          local dir

          git -C ${flakeDir} worktree prune
          dir=$(git -C ${flakeDir} worktree list --porcelain |
            awk '/^worktree /{w=$2} /^branch refs\/heads\/dotfiles$/{print w; exit}')

          [[ -n $dir ]] || {
            dir=${flakeDir}-dotfiles
            git -C ${flakeDir} worktree add "$dir" dotfiles || return
          }

          cd "$dir"
        }
      '';
    };
}
