{ inputs, ... }:
{
  flake.modules.nixos.vm =
    {
      config,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/virtualisation/qemu-vm.nix")
      ]
      ++ (with inputs.self.modules.nixos; [
        desktop

        boatette
      ]);

      users.users.${config.constants.username} = {
        initialPassword = "vm";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHfQrNy88CREKCCfBwnwHnfrqWBgvlTCphXAYnvf3AzJ boatette@gmail.com"
        ];
      };

      services = {
        openssh.enable = true;

        btrfs.autoScrub.enable = lib.mkForce false;
        smartd.enable = lib.mkForce false;
      };

      networking.hostName = "vm";
      system.stateVersion = config.constants.stateVersion;
    };
}
