{ inputs, ... }:
{
  flake-file.inputs.nixos-hardware = {
    url = "github:NixOS/nixos-hardware/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.aspire = {
    imports = with inputs.nixos-hardware.nixosModules; [
      common-cpu-intel

      common-pc-laptop

      common-pc-laptop-ssd
    ];

    hardware.intelgpu.vaapiDriver = "intel-media-driver";
  };
}
