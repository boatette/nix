{ inputs, ... }:
{
  flake-file.inputs.preservation.url = "github:nix-community/preservation";

  flake.modules.nixos.impermanence =
    {
      config,
      lib,
      pkgs,
      utils,
      ...
    }:
    let
      cfg = config.impermanence;
      inherit (config.constants) username;

      persist = "/persist";
      root = config.fileSystems."/".device;
      rootUnit = "${utils.escapeSystemdPath root}.device";
    in
    {
      # FIX: drop this once nix-community/preservation#36 lands
      # preservation still asserts on boot.initrd.systemd.enable
      imports = [
        (
          args:
          import inputs.preservation.nixosModules.default (
            args
            // {
              config = lib.recursiveUpdateUntil (
                path: _: _:
                path == [
                  "boot"
                  "initrd"
                  "systemd"
                  "enable"
                ]
              ) args.config { boot.initrd.systemd.enable = true; };
            }
          )
        )
      ];

      options.impermanence.wipe = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Start every boot on a fresh root subvolume, archiving the last one under old_roots";
      };

      config = {
        fileSystems.${persist}.neededForBoot = true;
        fileSystems."/var/log".neededForBoot = true;

        # the old root is moved aside rather than deleted, so anything that should
        # have been persisted can still be copied out for a month
        boot.initrd.systemd.services.rollback-root = lib.mkIf cfg.wipe {
          description = "Archive the previous root subvolume and create a fresh one";
          wantedBy = [ "initrd.target" ];
          requires = [ rootUnit ];
          after = [
            rootUnit
            # a resumed image still uses the old root
            "systemd-hibernate-resume.service"
          ];
          before = [ "sysroot.mount" ];
          unitConfig.DefaultDependencies = false;
          serviceConfig.Type = "oneshot";
          script = ''
            mkdir -p /btrfs
            mount -t btrfs -o subvol=/ ${root} /btrfs

            if [[ -e /btrfs/root ]]; then
              mkdir -p /btrfs/old_roots
              stamp=$(date --date="@$(stat -c %Y /btrfs/root)" +%Y-%m-%d_%H:%M:%S)
              mv /btrfs/root "/btrfs/old_roots/$stamp"
            fi

            delete_subvolume() {
              local child
              while IFS= read -r child; do
                delete_subvolume "/btrfs/$child"
              done < <(btrfs subvolume list -o "$1" | cut -f 9- -d ' ')
              btrfs subvolume delete "$1"
            }

            cutoff=$(($(date +%s) - 30 * 24 * 60 * 60))
            for old in /btrfs/old_roots/*; do
              if [[ -e "$old" ]] && (($(stat -c %Y "$old") < cutoff)); then
                delete_subvolume "$old"
              fi
            done

            btrfs subvolume create /btrfs/root
            umount /btrfs
          '';
        };

        preservation = {
          enable = true;

          preserveAt.${persist} = {
            files = [
              # systemd refuses to create the id through a dangling symlink, so the
              # target exists from the start and the first boot fills it in
              {
                file = "/etc/machine-id";
                inInitrd = true;
                how = "symlink";
                configureParent = true;
                createLinkTarget = true;
              }
              {
                file = "/var/lib/systemd/random-seed";
                inInitrd = true;
                how = "symlink";
                configureParent = true;
              }
              # names the boot entries on the ESP
              "/etc/kernel/entry-token"
              {
                file = "/var/lib/systemd/credential.secret";
                mode = "0400";
              }
            ];

            directories = [
              # stable uids and gids for users that are not declared with one
              {
                directory = "/var/lib/nixos";
                inInitrd = true;
              }
              # lanzaboote's keys, generated on first boot and enrolled in the firmware
              {
                directory = "/var/lib/sbctl";
                inInitrd = true;
              }

              "/var/lib/systemd/timers"
              "/var/lib/systemd/backlight"
              "/var/lib/systemd/rfkill"

              "/var/lib/NetworkManager"
              {
                directory = "/etc/NetworkManager/system-connections";
                mode = "0700";
              }
              {
                directory = "/var/lib/bluetooth";
                mode = "0700";
              }

              {
                directory = "/var/lib/AccountsService";
                mode = "0775";
              }
              "/var/lib/upower"
              "/var/lib/power-profiles-daemon"
            ]
            ++ lib.optional config.services.fwupd.enable {
              directory = "/var/lib/fwupd";
              user = "fwupd-refresh";
              group = "fwupd-refresh";
            }
            # what noctalia's greeter sync copies over: wallpaper, colours and monitor layout
            ++ lib.optional config.services.displayManager.noctalia-greeter.enable {
              directory = "/var/lib/noctalia-greeter";
              user = config.services.greetd.settings.default_session.user;
              group = config.services.greetd.settings.default_session.user;
              mode = "0750";
            }
            # the tailnet login, so it survives a reboot
            ++ lib.optional config.services.tailscale.enable "/var/lib/tailscale";
          };
        };

        # if systemd ever falls back to a transient id, save it through the symlink
        systemd.services.systemd-machine-id-commit = {
          unitConfig.ConditionPathIsMountPoint = [
            ""
            "${persist}/etc/machine-id"
          ];
          serviceConfig.ExecStart = [
            ""
            "systemd-machine-id-setup --commit --root ${persist}"
          ];
        };

        # /etc/shadow is wiped with the root, so passwords live on the persistent volume
        users = {
          mutableUsers = false;
          users = {
            ${username}.hashedPasswordFile = "${persist}/passwords/${username}";
            root.hashedPassword = "!";
          };
        };

        # it would lecture again after every boot
        security.sudo.extraConfig = "Defaults lecture=never";

        install.notes = lib.mkIf cfg.wipe [
          "/ starts empty on every boot; state that survives is listed in modules/system/impermanence.nix and lives in ${persist}"
          "previous roots are kept for 30 days: sudo mount -o subvol=/ ${root} /mnt, then look in /mnt/old_roots"
          "change ${username}'s password with: mkpasswd | sudo tee ${persist}/passwords/${username}"
        ];

        environment.systemPackages = [ pkgs.mkpasswd ];
      };
    };
}
