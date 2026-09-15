{
  flake.modules.nixos.install =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (config.install) plan;

      luks = lib.attrValues config.boot.initrd.luks.devices;

      hasPassword =
        user:
        lib.any (attr: user.${attr} != null) [
          "hashedPassword"
          "hashedPasswordFile"
          "password"
          "initialPassword"
          "initialHashedPassword"
        ];
    in
    {
      options.install = {
        notes = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Host-specific reminders printed by install-host and finish-install";
        };

        plan = lib.mkOption {
          type = lib.types.attrsOf lib.types.unspecified;
          readOnly = true;
          description = "What install-host and finish-install do for this host, derived from its config";
        };
      };

      config = {
        install.plan = {
          host = config.networking.hostName;

          uefi = config.boot.loader.systemd-boot.enable || (config.boot.lanzaboote.enable or false);
          disks = lib.mapAttrsToList (_: disk: disk.device) (config.disko.devices.disk or { });

          luks = map (device: device.device) luks;
          tpm = map (device: device.device) (
            lib.filter (device: lib.any (lib.hasPrefix "tpm2-device=") device.crypttabExtraOpts) luks
          );

          secureBoot = config.boot.lanzaboote.enable or false;
          pkiBundle = config.boot.lanzaboote.pkiBundle or null;
          esp = config.boot.loader.efi.efiSysMountPoint;

          users = lib.attrNames (
            lib.filterAttrs (_: user: user.isNormalUser && !hasPassword user) config.users.users
          );

          inherit (config.constants) username flakeDir repo;

          substituters = config.nix.settings.extra-substituters or [ ];
          trustedPublicKeys = config.nix.settings.extra-trusted-public-keys or [ ];

          inherit (config.install) notes;
        };

        environment = {
          etc."install-plan.json".text = builtins.toJSON plan;

          systemPackages = lib.mkIf (plan.secureBoot || plan.tpm != [ ]) [ pkgs.local.finish-install ];
        };
      };
    };
}
