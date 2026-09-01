{ inputs, ... }:
{
  flake.modules.nixos.iso =
    { modulesPath, pkgs, ... }:
    {
      imports = [
        (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
      ]
      ++ (with inputs.self.modules.nixos; [
        locale
        nix-settings
        zram
      ])
      ++ [ inputs.self.modules.generic.constants ];

      environment.systemPackages = [
        pkgs.local.nvim-minimal
        inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko
      ];

      environment.etc."nixos-config".source = inputs.self;

      isoImage = {
        volumeID = "nixos-boatette";
        squashfsCompression = "zstd -Xcompression-level 6";
      };

      networking.hostName = "iso";
    };
}
