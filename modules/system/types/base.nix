{ inputs, ... }:
{
  flake.modules.nixos.base = {
    imports =
      (with inputs.self.modules.nixos; [
        home-manager

        boot
        btrfs
        locale
        networking
        nix-settings
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

        bat
        git
        nix-index
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
