{ inputs, ... }:
{
  flake.modules.nixos.iso =
    {
      lib,
      modulesPath,
      pkgs,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
      ]
      ++ (with inputs.self.modules.nixos; [
        console
        locale
        nix-settings
        zram
      ])
      ++ [ inputs.self.modules.generic.constants ];

      environment.systemPackages = [
        pkgs.local.install-host
        pkgs.local.nvim-minimal
        inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko

        pkgs.cryptsetup
      ];

      # replaces the installer profile's text; \e{...} is agetty's issue-file colour escape
      services.getty.helpLine = lib.mkForce ''

        \e{bold}Install\e{reset}
          sudo install-host              pick a host, erase its disks, install it
          install-host --dry-run HOST    show the plan and disko script, change nothing
          finish-install                 run on the new system after its first boot

        \e{bold}Network\e{reset}
          nmtui                          join wifi (install-host opens it when offline)
          ip -br addr                    show this machine's addresses
          passwd                         set a password, then ssh nixos@ADDRESS

        \e{bold}Disks\e{reset}
          lsblk -o NAME,SIZE,MODEL       list disks
          ls -l /dev/disk/by-id          stable names, for a host's disko.nix

        \e{bold}Editing the flake\e{reset}
          /etc/nixos-config is read-only; copy it, edit with nvim, install the copy:
            cp -r --no-preserve=mode /etc/nixos-config /tmp/nix
            sudo install-host --flake /tmp/nix HOST
      '';

      environment.etc."nixos-config".source = inputs.self;

      isoImage = {
        volumeID = "nixos-boatette";
        squashfsCompression = "zstd -Xcompression-level 6";
      };

      networking.hostName = "iso";
    };
}
