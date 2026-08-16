let
  flakeDir = "$HOME/nix";

  posixFunctions = ''
    mkcd() { mkdir -p -- "$1" && cd "$1"; }
    cl() { cd "$1" && ls; }
  '';
in

{
  flake.modules.nixos.base =
    { lib, ... }:
    {
      programs.fish.enable = true;
      environment.shellAliases = lib.mkForce { };
    };

  flake.modules.homeManager.base =
    { pkgs, lib, ... }:
    {
      home.shellAliases = import ./_aliases.nix { inherit flakeDir; };

      home.packages = with pkgs; [
        backup
        copy
        extract
        nsh
        nrun
        psg
        paths
        serve
        unowned
        open-zellij
        prune-small
      ];

      programs = {
        starship.enable = true;

        zoxide = {
          enable = true;
          options = [ "--cmd cd" ];

          enableFishIntegration = false;
          enableZshIntegration = false;
        };

        bash = {
          enable = true;
          enableCompletion = true;
          initExtra = posixFunctions;
        };

        zsh = {
          enable = true;
          enableCompletion = true;
          autosuggestion.enable = true;

          initContent = lib.mkMerge [
            posixFunctions

            (lib.mkAfter ''
              eval "$(${lib.getExe pkgs.zoxide} init zsh --cmd cd)"
            '')
          ];
        };

        fish = {
          enable = true;

          interactiveShellInit = lib.mkMerge [
            (builtins.readFile ./_init.fish)

            (lib.mkAfter ''
              ${lib.getExe pkgs.zoxide} init fish --cmd cd | source
            '')
          ];
        };
      };
    };
}
