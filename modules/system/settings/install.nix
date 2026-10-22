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
          # hashes install-host writes into the new system, for users whose password lives in a file
          passwordFiles = lib.mapAttrs (_: user: user.hashedPasswordFile) (
            lib.filterAttrs (_: user: user.isNormalUser && user.hashedPasswordFile != null) config.users.users
          );
          rootPassword = config.users.users.root.hashedPassword == null;

          inherit (config.constants) username flakeDir repo;
          home = config.users.users.${config.constants.username}.home;

          substituters = config.nix.settings.extra-substituters or [ ];
          trustedPublicKeys = config.nix.settings.extra-trusted-public-keys or [ ];

          inherit (config.install) notes;
        };

        environment = {
          etc."install-plan.json".text = builtins.toJSON plan;

          systemPackages = [ pkgs.local.finish-install ];
        };

        programs.ssh.knownHosts."github.com".publicKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      };
    };
}
