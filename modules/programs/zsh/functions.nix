{
  flake.modules.homeManager.zsh = {
    programs.zsh.initContent = ''
      mkcd() { mkdir -p -- "$1" && cd "$1"; }

      nsh() { nix shell "''${@/#/nixpkgs#}"; }

      nrun() { local pkg="$1"; shift; nix run "nixpkgs#$pkg" -- "$@"; }

      unowned() { find "$@" -not -user "$USER"; }
    '';
  };
}
