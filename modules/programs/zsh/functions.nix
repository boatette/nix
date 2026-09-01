{ inputs, ... }:
{
  flake.modules.homeManager.zsh =
    { config, ... }:
    let
      inherit (config.constants) flakeDir;

      rebuild = inputs.self.lib.rebuild flakeDir;
    in
    {
      programs.zsh.initContent = ''
        mkcd() { mkdir -p -- "$1" && cd "$1"; }

        nsh() { nix shell "''${@/#/nixpkgs#}"; }

        nrun() { local pkg="$1"; shift; nix run "nixpkgs#$pkg" -- "$@"; }

        nfu() { ${rebuild.update} "$@"; }

        unowned() { find "$@" -not -user "$USER"; }
      '';
    };
}
