{ inputs, ... }:
{
  flake.modules.nixos.aspire =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (inputs.self.constants) flakeDir repo username;
    in
    {
      options.install = {
        notes = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Reminders install and finish-install print";
        };

        plan = lib.mkOption {
          type = lib.types.attrsOf lib.types.unspecified;
          readOnly = true;
          description = "What install and finish-install do, read from the config";
        };
      };

      config = {
        install.plan = {
          host = config.networking.hostName;
          disks = lib.mapAttrsToList (_: disk: disk.device) config.disko.devices.disk;

          tpm = map (device: device.device) (
            lib.filter (device: lib.any (lib.hasPrefix "tpm2-device=") device.crypttabExtraOpts) (
              lib.attrValues config.boot.initrd.luks.devices
            )
          );

          inherit (config.boot.lanzaboote) pkiBundle;
          esp = config.boot.loader.efi.efiSysMountPoint;

          passwordFiles = lib.mapAttrs (_: user: user.hashedPasswordFile) (
            lib.filterAttrs (_: user: user.hashedPasswordFile != null) config.users.users
          );

          inherit flakeDir repo username;
          inherit (config.users.users.${username}) home;

          substituters = config.nix.settings.extra-substituters;
          trustedPublicKeys = config.nix.settings.extra-trusted-public-keys;

          inherit (config.install) notes;
        };

        environment = {
          etc."install-plan.json".text = builtins.toJSON config.install.plan;

          systemPackages = [ pkgs.local.finish-install ];
        };

        programs.ssh.knownHosts."github.com".publicKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      };
    };
}
