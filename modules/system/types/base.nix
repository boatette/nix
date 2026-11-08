{ inputs, ... }:
{
  flake.modules.nixos.base = {
    imports =
      (with inputs.self.modules.nixos; [
        home-manager

        boot
        btrfs
        firmware
        install
        locale
        networking
        nix-settings
        packages
        smart
        users
        zram

        btop
        nh
        nix-index
        zsh
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

        archive-tools
        bat
        btop
        direnv
        fzf
        git
        nix-index
        nix-your-shell
        nvim
        ssh
        yazi
        zellij
      ])
      ++ [ inputs.self.modules.generic.constants ];

    home.sessionPath = [ "$HOME/.local/bin" ];
  };
}
