{ inputs, ... }:
{
  flake.modules.nixos.base = {
    imports =
      (with inputs.self.modules.nixos; [
        nixpkgs
        pkgs-by-name
        home-manager

        boot
        btrfs
        locale
        networking
        nix-settings
        users
        zram

        bat
        nvim
        zsh
        toolchains

        essential-packages
        session-path
      ])
      ++ [ inputs.self.modules.generic.constants ];
  };

  flake.modules.homeManager.base = {
    imports =
      (with inputs.self.modules.homeManager; [
        zsh
        starship
        cli-tools
        toolchains

        bat
        git
        ssh
        nvim
        fastfetch
        fetch
        yazi
        zellij
      ])
      ++ [ inputs.self.modules.generic.constants ];
  };
}
