{ inputs, ... }:
{
  flake.modules.nixos.vm-install =
    { config, modulesPath, ... }:
    {
      imports = [
        (modulesPath + "/profiles/qemu-guest.nix")
      ]
      ++ (with inputs.self.modules.nixos; [
        boot
        btrfs
        install
        locale
        networking
        nix-settings
        users
        zram
        zsh
      ])
      ++ [ inputs.self.modules.generic.constants ];

      networking.hostName = "vm-install";
      system.stateVersion = config.constants.stateVersion;
    };
}
