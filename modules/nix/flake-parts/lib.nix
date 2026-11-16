{
  inputs,
  lib,
  withSystem,
  ...
}:
{
  options.flake.lib = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
    description = "Helper functions shared across the flake";
  };

  config.flake.lib = rec {
    qtFont = font: "${font.name},${toString font.size},-1,5,50,0,0,0,0,0";

    # runs a program on the nvidia gpu under prime offload, like nvidia-offload
    nvidiaOffloadEnv = {
      __NV_PRIME_RENDER_OFFLOAD = "1";
      __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      __VK_LAYER_NV_optimus = "NVIDIA_only";
    };

    # pkg with bin/<bin> started under nvidiaOffloadEnv, when the host uses prime offload
    nvidiaOffloadWrap =
      pkgs: osConfig: pkg: bin:
      if osConfig.hardware.nvidia.prime.offload.enable or false then
        pkgs.symlinkJoin {
          inherit (pkg)
            name
            pname
            version
            meta
            ;
          paths = [ pkg ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/${bin} ${
              lib.concatStringsSep " " (
                lib.mapAttrsToList (name: value: "--set ${name} ${value}") nvidiaOffloadEnv
              )
            }
          '';
        }
      else
        pkg;

    mkNixos = system: name: {
      ${name} = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          inputs.self.modules.nixos.${name}
          {
            nixpkgs = {
              hostPlatform = lib.mkDefault system;
              pkgs = withSystem system ({ pkgs, ... }: pkgs);
            };
          }
        ];
      };
    };
  };
}
