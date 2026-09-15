{ inputs, ... }:
{
  flake.modules.nixos.vm-install =
    {
      config,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/profiles/qemu-guest.nix")
        inputs.self.modules.nixos.base
      ];

      home-manager.users.${config.constants.username} = {
        imports = [ inputs.self.modules.homeManager.base ];
        home.stateVersion = config.constants.stateVersion;
      };

      services = {
        openssh.enable = true;
        smartd.enable = lib.mkForce false;
      };

      networking.hostName = "vm-install";
      system.stateVersion = config.constants.stateVersion;
    };
}
