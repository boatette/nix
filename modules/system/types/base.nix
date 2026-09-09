{ inputs, ... }:
{
  flake.modules.nixos.base = {
    imports =
      (with inputs.self.modules.nixos; [
        home-manager

        boot
        btrfs
        firmware
        locale
        networking
        nix-settings
        smart
        users
        zram

        nh
        nix-index
        zsh

        packages
      ])
      ++ [ inputs.self.modules.generic.constants ];
  };

  flake.modules.homeManager.base = {
    home.sessionPath = [
      "$HOME/.local/bin"
      "$HOME/go/bin"
      "$HOME/.cargo/bin"
    ];

    imports =
      (with inputs.self.modules.homeManager; [
        zsh
        starship
        cli-tools
        toolchains

        archive-tools
        bat
        direnv
        git
        nix-index
        nix-your-shell
        ssh
        nvim
        yazi
        zellij
      ])
      ++ [ inputs.self.modules.generic.constants ];
  };
}
