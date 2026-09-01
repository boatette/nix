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

        nfu() {
          env --chdir ${flakeDir} nix run ${flakeDir}#write-flake \
            && nix flake update --flake ${flakeDir} --commit-lock-file "$@"
        }

        unowned() { find "$@" -not -user "$USER"; }
      '';
    };
}
