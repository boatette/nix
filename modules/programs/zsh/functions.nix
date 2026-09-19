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
