{ inputs, ... }:
{
  flake-file.inputs.nixos-hardware = {
    url = "github:NixOS/nixos-hardware/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.aspire =
    { pkgs, ... }:
    {
      imports = with inputs.nixos-hardware.nixosModules; [
        # common-cpu-intel minus its gpu module, which bundles the ~400M OpenCL runtime
        "${inputs.nixos-hardware}/common/cpu/intel/cpu-only.nix"

        common-pc-laptop

        common-pc-laptop-ssd
      ];

      # what common/gpu/intel sets for vaapiDriver = "intel-media-driver", without intel-compute-runtime
      boot.initrd.kernelModules = [ "i915" ];

      hardware.graphics = {
        extraPackages = [
          pkgs.intel-media-driver
          pkgs.vpl-gpu-rt
        ];
        extraPackages32 = [ pkgs.driversi686Linux.intel-media-driver ];
      };
    };
}
